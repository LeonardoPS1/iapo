# SEO Phase 4 — AI/LLM Specific Optimizations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement AI/LLM specific optimizations: llms-full.txt generation, validate speakable schema, content structure improvements for AI consumption.

**Architecture:** Phase 4 adds a postbuild script to generate llms-full.txt from content collections, validates existing speakable schema, and ensures content structure is optimal for AI training/consumption.

**Tech Stack:** Astro 5.x, Node.js script for llms-full.txt generation, existing content collections

## Global Constraints

- Site URL: `https://iapo.cl`
- Output: `static` (pre-rendered)
- Language: `es-CL`
- Organization: Aicore Agency (https://aicorebots.com)
- No breaking changes to existing build
- All new files must pass `npm run build` (exit 0)
- Design system: ink #15171c, core #0e8a76, paper #edeee7

---

### Task 1: Create llms-full.txt generation script

**Files:**
- Create: `scripts/generate-llms-full.mjs`
- Modify: `package.json` (add postbuild step)

**Interfaces:**
- Consumes: Blog collection (posts), prompts array, repos array
- Produces: `public/llms-full.txt` with full content dump for AI training

- [ ] **Step 1: Create generation script**

```js
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
  // Read from src/pages/prompts.astro
  const promptsPath = path.join(projectRoot, 'src', 'pages', 'prompts.astro');
  const content = fs.readFileSync(promptsPath, 'utf-8');
  // Extract prompts array using regex
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
```

- [ ] **Step 2: Update package.json to run script in postbuild**

Add after existing postbuild: `"postbuild": "node scripts/update-sitemap-lastmod.mjs && node scripts/generate-llms-full.mjs"`

- [ ] **Step 3: Verify build passes**

```bash
npm run build
```

- [ ] **Step 4: Verify llms-full.txt in dist/**

```bash
head -100 dist/llms-full.txt
```

- [ ] **Step 5: Commit**

```bash
git add scripts/generate-llms-full.mjs package.json
git commit -m "seo: add llms-full.txt generation for AI training"
```

---

### Task 2: Validate speakable schema and content structure

**Files:**
- Verify: `src/layouts/Post.astro` (speakable cssSelector matches actual HTML)
- Verify: `src/components/BaseHead.astro` (speakable in JSON-LD)

**Interfaces:**
- Consumes: Existing speakable implementation
- Produces: Validation report

- [ ] **Step 1: Verify speakable cssSelector matches Post.astro HTML structure**

Check that `.post-head h1`, `.deck`, `.content > p:first-of-type` exist in generated HTML.

- [ ] **Step 2: Verify speakable is included in BlogPosting JSON-LD**

Already done in Phase 2 - confirm it's present.

- [ ] **Step 3: Verify heading hierarchy (h1 → h2 → h3) in blog posts**

Check Post.astro content structure.

- [ ] **Step 4: Verify semantic HTML5 (article, section, aside, nav)**

Check Base.astro, Post.astro, Sidebar.astro.

- [ ] **Step 5: Verify code blocks have language annotations**

Check blog post markdown content.

- [ ] **Step 6: Commit if any fixes needed**

```bash
git add -A
git commit -m "seo: validate speakable schema and content structure"
```

---

### Task 3: Verify Phase 4 build and validation

**Files:**
- None (verification only)

**Interfaces:**
- Consumes: All Phase 4 outputs
- Produces: Validation that build passes and features work

- [ ] **Step 1: Full build**

```bash
npm run build
```

- [ ] **Step 2: Verify llms-full.txt in dist/**

```bash
ls -la dist/llms-full.txt
head -50 dist/llms-full.txt
```

- [ ] **Step 3: Verify speakable in JSON-LD**

```bash
cat dist/blog/n8n-ollama-flujo-calificacion-leads/index.html | findstr "speakable"
```

- [ ] **Step 4: Commit any remaining changes**

```bash
git add -A
git commit -m "seo: phase 4 complete - llms-full.txt, speakable validation, content structure"
```

---

## Phase 4 Success Criteria Checklist

- [ ] `npm run build` exits 0
- [ ] `dist/llms-full.txt` exists with full content dump (blog posts + prompts + repos)
- [ ] Speakable schema present in BlogPosting JSON-LD with correct cssSelector
- [ ] Heading hierarchy correct (h1 → h2 → h3) in blog posts
- [ ] Semantic HTML5 structure maintained
- [ ] Code blocks have language annotations
- [ ] No regression in existing pages (12 pages built)

---

## Next Phase Preview (Phase 5)

After Phase 4 approval, Phase 5 will cover:
- Resource hints (dns-prefetch, preload)
- Image optimization (og.png)
- HTTP headers via nginx/Cloudflare
- Lighthouse SEO score validation