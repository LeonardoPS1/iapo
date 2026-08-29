# SEO Phase 2 — Advanced Structured Data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement advanced structured data: WebSite schema (homepage), BreadcrumbList schema (all pages), enhanced BlogPosting (articleSection, keywords, speakable, hasPart), CollectionPage schema (/blog, /prompts, /repos, /casos, /sobre), Open Graph article enhancements.

**Architecture:** Phase 2 modifies layout components (Base.astro, BaseHead.astro, Post.astro) and page files to add JSON-LD schemas. Each task produces independently verifiable structured data.

**Tech Stack:** Astro 5.x, JSON-LD via BaseHead.astro structuredData prop, schema.org vocabularies

## Global Constraints

- Site URL: `https://iapo.cl`
- Output: `static` (pre-rendered)
- Language: `es-CL`
- Organization: Aicore Agency (https://aicorebots.com)
- No breaking changes to existing build
- All new files must pass `npm run build` (exit 0)
- JSON-LD must validate via Google Rich Results Test

---

### Task 1: Add WebSite schema to Base.astro (homepage only)

**Files:**
- Modify: `src/layouts/Base.astro`

**Interfaces:**
- Consumes: Base.astro props (title, description, variant)
- Produces: WebSite schema with SearchAction on homepage (variant === 'sheet')

- [ ] **Step 1: Read current Base.astro**

```bash
cat src/layouts/Base.astro
```

- [ ] **Step 2: Add WebSite schema for homepage (variant === 'sheet')**

Add WebSite schema object to the existing `organization` schema array when `variant === 'sheet'`:
```js
const websiteSchema = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  '@id': 'https://iapo.cl/#website',
  url: 'https://iapo.cl/',
  name: 'iapo.cl',
  description: 'Diario impreso de IA aplicada — tips, prompts, skills y repos desde Chile.',
  publisher: { '@id': 'https://iapo.cl/#organization' },
  // SearchAction omitted - no search implementation yet
  inLanguage: 'es-CL',
};
```

Add to `allData` array conditionally:
```js
const allData = variant === 'sheet' 
  ? [organization, websiteSchema, ...(Array.isArray(structuredData) ? structuredData : [structuredData])]
  : [organization, ...(Array.isArray(structuredData) ? structuredData : [structuredData])];
```

- [ ] **Step 3: Verify build passes**

```bash
npm run build
```

- [ ] **Step 4: Commit**

```bash
git add src/layouts/Base.astro
git commit -m "seo: add WebSite schema to homepage"
```

---

### Task 2: Add BreadcrumbList schema to Base.astro (all pages)

**Files:**
- Modify: `src/layouts/Base.astro`

**Interfaces:**
- Consumes: Base.astro props (title, variant), current URL path
- Produces: BreadcrumbList schema for all pages

- [ ] **Step 1: Read current Base.astro**

```bash
cat src/layouts/Base.astro
```

- [ ] **Step 2: Create breadcrumb generator function**

Add helper function to generate BreadcrumbList from URL pathname:
```js
function generateBreadcrumbs(pathname) {
  const segments = pathname.split('/').filter(Boolean);
  const items = [
    { '@type': 'ListItem', position: 1, name: 'Inicio', item: 'https://iapo.cl/' },
  ];
  
  let currentPath = '';
  segments.forEach((segment, index) => {
    currentPath += `/${segment}`;
    // Clean up segment name (remove trailing slashes, decode)
    const name = segment.charAt(0).toUpperCase() + segment.slice(1).replace(/-/g, ' ');
    items.push({
      '@type': 'ListItem',
      position: index + 2,
      name,
      item: `https://iapo.cl${currentPath}`,
    });
  });
  
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items,
  };
}
```

- [ ] **Step 3: Add breadcrumb schema to allData**

Call `generateBreadcrumbs(Astro.url.pathname)` and add to `allData` array.

- [ ] **Step 4: Verify build passes and check JSON-LD output**

```bash
npm run build
# Check dist/ for JSON-LD in HTML
```

- [ ] **Step 5: Commit**

```bash
git add src/layouts/Base.astro
git commit -m "seo: add BreadcrumbList schema to all pages"
```

---

### Task 3: Enhance BlogPosting schema in Post.astro

**Files:**
- Modify: `src/layouts/Post.astro`
- Modify: `src/pages/blog/[id].astro` (to pass tags to layout)

**Interfaces:**
- Consumes: Post.astro props (title, description, pubDate, pilar, allPosts, currentId, tags)
- Produces: Enhanced BlogPosting with articleSection, keywords, author as Person, speakable, hasPart

- [ ] **Step 1: Read current Post.astro and blog/[id].astro**

```bash
cat src/layouts/Post.astro
cat src/pages/blog/[id].astro
```

- [ ] **Step 2: Update blog/[id].astro to pass tags**

Add `tags` to Post component props from `post.data.tags`.

- [ ] **Step 3: Enhance BlogPosting in Post.astro**

```js
const blogPosting = {
  '@context': 'https://schema.org',
  '@type': 'BlogPosting',
  '@id': `${postUrl}#article`,
  headline: title,
  description,
  image: 'https://iapo.cl/og.png',
  author: { 
    '@type': 'Person', 
    name: 'Aicore Agency', 
    url: 'https://aicorebots.com',
    sameAs: ['https://aicorebots.com', 'https://med.aicorebots.com'],
  },
  publisher: { '@type': 'Organization', '@id': 'https://iapo.cl/#organization' },
  datePublished: pubDate.toISOString(),
  dateModified: pubDate.toISOString(),
  mainEntityOfPage: postUrl,
  inLanguage: 'es-CL',
  articleSection: pilar,
  keywords: tags?.join(', ') || '',
  speakable: {
    '@type': 'SpeakableSpecification',
    cssSelector: ['.post-head h1', '.deck', '.content > p:first-of-type'],
  },
  hasPart: [
    // Will be populated from h2 headers if needed
  ],
};
```

- [ ] **Step 4: Verify build passes**

```bash
npm run build
```

- [ ] **Step 5: Commit**

```bash
git add src/layouts/Post.astro src/pages/blog/[id].astro
git commit -m "seo: enhance BlogPosting with articleSection, keywords, author Person, speakable"
```

---

### Task 4: Add CollectionPage schema to listing pages

**Files:**
- Modify: `src/pages/blog.astro`
- Modify: `src/pages/prompts.astro`
- Modify: `src/pages/repos.astro`
- Modify: `src/pages/casos.astro`
- Modify: `src/pages/sobre.astro`

**Interfaces:**
- Consumes: Page-specific data (posts, prompts, repos arrays)
- Produces: CollectionPage / ItemList schema for each listing page

- [ ] **Step 1: Read each listing page**

```bash
cat src/pages/blog.astro
cat src/pages/prompts.astro
cat src/pages/repos.astro
cat src/pages/casos.astro
cat src/pages/sobre.astro
```

- [ ] **Step 2: Add CollectionPage schema to each page**

For `/blog`:
```js
const collectionPage = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  '@id': 'https://iapo.cl/blog#collection',
  name: 'Blog — iapo.cl',
  description: 'Artículos técnicos sobre automatización, salud y IA general.',
  url: 'https://iapo.cl/blog',
  mainEntity: {
    '@type': 'ItemList',
    itemListElement: posts.map((post, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      url: `https://iapo.cl/blog/${post.id}`,
      name: post.data.title,
    })),
  },
};
```

For `/prompts`:
```js
const collectionPage = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  '@id': 'https://iapo.cl/prompts#collection',
  name: 'Prompts — iapo.cl',
  description: 'Prompts probados en producción para clínicas y automatización con IA.',
  url: 'https://iapo.cl/prompts',
  mainEntity: {
    '@type': 'ItemList',
    itemListElement: prompts.map((prompt, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      url: `https://iapo.cl/prompts#${prompt.titulo.toLowerCase().replace(/\s+/g, '-')}`,
      name: prompt.titulo,
    })),
  },
};
```

For `/repos`, `/casos`, `/sobre` — similar pattern with appropriate type (CollectionPage or AboutPage).

- [ ] **Step 3: Pass schema via Base structuredData prop**

Each page passes its schema to `<Base structuredData={[collectionPage]} />`

- [ ] **Step 4: Verify build passes**

```bash
npm run build
```

- [ ] **Step 5: Commit**

```bash
git add src/pages/blog.astro src/pages/prompts.astro src/pages/repos.astro src/pages/casos.astro src/pages/sobre.astro
git commit -m "seo: add CollectionPage/ItemList schema to listing pages"
```

---

### Task 5: Add Open Graph article enhancements to BaseHead.astro

**Files:**
- Modify: `src/components/BaseHead.astro`

**Interfaces:**
- Consumes: BaseHead props (type, author, publishedTime, modifiedTime, tags, pilar)
- Produces: Enhanced OG meta tags for article type

- [ ] **Step 1: Read current BaseHead.astro**

```bash
cat src/components/BaseHead.astro
```

- [ ] **Step 2: Add article-specific OG tags**

For `type === 'article'`, add:
```astro
{type === 'article' && author && (
  <meta property="article:author" content={author} />
)}
{type === 'article' && publishedTime && (
  <meta property="article:published_time" content={publishedTime} />
)}
{type === 'article' && modifiedTime && (
  <meta property="article:modified_time" content={modifiedTime} />
)}
{type === 'article' && tags && tags.length > 0 && (
  <meta property="article:tag" content={tags.join(', ')} />
)}
{type === 'article' && pilar && (
  <meta property="article:section" content={pilar} />
)}
```

- [ ] **Step 3: Update Base.astro to pass new props**

Pass `tags` and `pilar` from Post.astro to BaseHead.

- [ ] **Step 4: Verify build passes**

```bash
npm run build
```

- [ ] **Step 5: Commit**

```bash
git add src/components/BaseHead.astro src/layouts/Base.astro src/layouts/Post.astro
git commit -m "seo: add OG article enhancements (article:author, section, tag, published_time, modified_time)"
```

---

### Task 6: Verify Phase 2 build and structured data validation

**Files:**
- None (verification only)

**Interfaces:**
- Consumes: All Phase 2 outputs
- Produces: Validation that build passes and JSON-LD is valid

- [ ] **Step 1: Full build**

```bash
npm run build
```

- [ ] **Step 2: Verify JSON-LD in generated HTML**

```bash
# Check homepage for WebSite schema
grep -A 20 'WebSite' dist/index.html

# Check blog post for BlogPosting + BreadcrumbList
grep -A 30 'BlogPosting' dist/blog/n8n-ollama-flujo-calificacion-leads/index.html

# Check listing pages for CollectionPage
grep -A 20 'CollectionPage' dist/blog/index.html
```

- [ ] **Step 3: Test with Google Rich Results Test (manual)**
- Deploy to staging or use local validation tool

- [ ] **Step 4: Commit any remaining changes**

```bash
git add -A
git commit -m "seo: phase 2 complete - WebSite, BreadcrumbList, enhanced BlogPosting, CollectionPage, OG article"
```

---

## Phase 2 Success Criteria Checklist

- [ ] `npm run build` exits 0
- [ ] Homepage has WebSite schema (no SearchAction until search implemented)
- [ ] All pages have BreadcrumbList schema matching URL hierarchy
- [ ] Blog posts have enhanced BlogPosting: articleSection, keywords, author as Person, speakable
- [ ] Listing pages (/blog, /prompts, /repos, /casos, /sobre) have CollectionPage/ItemList schema
- [ ] Blog posts have OG article:author, article:section, article:tag, article:published_time, article:modified_time
- [ ] No regression in existing pages (12 pages built)
- [ ] JSON-LD validates (Google Rich Results Test)

---

## Next Phase Preview (Phase 3)

After Phase 2 approval, Phase 3 will cover:
- Visual breadcrumbs UI (matching schema)
- Previous/Next navigation in Post.astro
- Pillar-based topic clusters in Sidebar
- Meta keywords for blog posts
- Enhanced internal linking