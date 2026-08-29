import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import matter from 'gray-matter';
import { DOMParser, XMLSerializer } from 'xmldom';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '..');

function parseFrontmatter(content) {
  const { data } = matter(content);
  return data;
}

function getBlogPosts() {
  const blogDir = path.join(projectRoot, 'src', 'content', 'blog');
  const files = fs.readdirSync(blogDir).filter(f => f.endsWith('.md'));
  const posts = [];

  for (const file of files) {
    const filePath = path.join(blogDir, file);
    const content = fs.readFileSync(filePath, 'utf-8');
    const frontmatter = parseFrontmatter(content);

    if (!frontmatter.draft) {
      const id = file.replace('.md', '');
      posts.push({
        id,
        pubDate: new Date(frontmatter.pubDate),
      });
    }
  }

  return posts;
}

async function updateSitemapLastmod() {
  const distDir = path.join(projectRoot, 'dist');
  const sitemapIndexPath = path.join(distDir, 'sitemap-index.xml');
  const sitemap0Path = path.join(distDir, 'sitemap-0.xml');

  if (!fs.existsSync(sitemap0Path)) {
    console.log('No sitemap-0.xml found, skipping');
    return;
  }

  const posts = getBlogPosts();
  const pubDateMap = new Map();

  for (const post of posts) {
    const url = `https://iapo.cl/blog/${post.id}/`;
    pubDateMap.set(url, post.pubDate.toISOString());
  }

  const sitemapContent = fs.readFileSync(sitemap0Path, 'utf-8');
  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(sitemapContent, 'application/xml');
  const urlElements = Array.from(xmlDoc.getElementsByTagName('url'));

  let updated = 0;
  for (const urlEl of urlElements) {
    const locEl = urlEl.getElementsByTagName('loc')[0];
    const lastmodEl = urlEl.getElementsByTagName('lastmod')[0];
    if (locEl && lastmodEl) {
      const url = locEl.textContent;
      if (pubDateMap.has(url)) {
        lastmodEl.textContent = pubDateMap.get(url);
        updated++;
      }
    }
  }

  const serializer = new XMLSerializer();
  const updatedXml = serializer.serializeToString(xmlDoc);
  fs.writeFileSync(sitemap0Path, updatedXml);
  console.log(`Updated ${updated} blog post URLs with correct lastmod`);

  if (fs.existsSync(sitemapIndexPath)) {
    const indexContent = fs.readFileSync(sitemapIndexPath, 'utf-8');
    const indexDoc = parser.parseFromString(indexContent, 'application/xml');
    const sitemapElements = Array.from(indexDoc.getElementsByTagName('sitemap'));
    for (const sitemapEl of sitemapElements) {
      const locEl = sitemapEl.getElementsByTagName('loc')[0];
      const lastmodEl = sitemapEl.getElementsByTagName('lastmod')[0];
      if (locEl && lastmodEl && locEl.textContent.includes('sitemap-0.xml')) {
        const latestDate = [...pubDateMap.values()].sort().reverse()[0] || new Date().toISOString();
        lastmodEl.textContent = latestDate;
      }
    }
    const updatedIndexXml = serializer.serializeToString(indexDoc);
    fs.writeFileSync(sitemapIndexPath, updatedIndexXml);
    console.log('Updated sitemap-index.xml lastmod');
  }
}

updateSitemapLastmod().catch(console.error);