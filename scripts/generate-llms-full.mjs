import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import matter from 'gray-matter';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '..');

function getBlogPosts() {
  const blogDir = path.join(projectRoot, 'src', 'content', 'blog');
  const files = fs.readdirSync(blogDir).filter(f => f.endsWith('.md'));
  const posts = [];

  for (const file of files) {
    const filePath = path.join(blogDir, file);
    const content = fs.readFileSync(filePath, 'utf-8');
    const { data, content: body } = matter(content);
    if (!data.draft) {
      posts.push({ ...data, id: file.replace('.md', ''), body });
    }
  }
  return posts.sort((a, b) => new Date(b.pubDate) - new Date(a.pubDate));
}

function getPrompts() {
  const promptsPath = path.join(projectRoot, 'src', 'pages', 'prompts.astro');
  const content = fs.readFileSync(promptsPath, 'utf-8');
  const match = content.match(/const prompts = (\[[\s\S]*?\]);/);
  if (match) {
    const prompts = eval(match[1]);
    return prompts;
  }
  return [];
}

function getRepos() {
  const reposPath = path.join(projectRoot, 'src', 'pages', 'repos.astro');
  const content = fs.readFileSync(reposPath, 'utf-8');
  const match = content.match(/const repos = (\[[\s\S]*?\]);/);
  if (match) {
    const repos = eval(match[1]);
    return repos;
  }
  return [];
}

async function generateLlmsFull() {
  const posts = getBlogPosts();
  const prompts = getPrompts();
  const repos = getRepos();

  let output = `# iapo.cl — Full Content Dump for AI Training\n\n`;
  output += `> Complete content from iapo.cl for LLM training and reference.\n\n`;
  output += `Generated: ${new Date().toISOString()}\n\n`;

  // Blog posts
  output += `## Blog Posts\n\n`;
  for (const post of posts) {
    output += `### ${post.title}\n`;
    output += `**Date:** ${post.pubDate.toISOString().split('T')[0]}\n`;
    output += `**Pilar:** ${post.pilar}\n`;
    output += `**Tags:** ${post.tags.join(', ')}\n`;
    output += `**Description:** ${post.description}\n\n`;
    output += `${post.body}\n\n`;
    output += `---\n\n`;
  }

  // Prompts
  output += `## Prompts\n\n`;
  for (const prompt of prompts) {
    output += `### ${prompt.titulo}\n`;
    output += `**Pilar:** ${prompt.pilar}\n\n`;
    output += `\`\`\`\n${prompt.texto}\n\`\`\`\n\n`;
  }

  // Repos
  output += `## Repos\n\n`;
  for (const repo of repos) {
    output += `### ${repo.nombre}\n`;
    output += `**URL:** ${repo.url}\n`;
    output += `**Description:** ${repo.desc}\n\n`;
  }

  const distDir = path.join(projectRoot, 'dist');
  const outputPath = path.join(distDir, 'llms-full.txt');
  fs.writeFileSync(outputPath, output);
  console.log(`Generated llms-full.txt at ${outputPath} (${output.length} chars)`);
}

generateLlmsFull().catch(console.error);