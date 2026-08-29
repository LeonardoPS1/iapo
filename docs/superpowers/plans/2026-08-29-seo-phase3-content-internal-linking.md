# SEO Phase 3 — Content SEO & Internal Linking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement content SEO enhancements: visual breadcrumbs UI, Previous/Next navigation in blog posts, pillar-based topic clusters in Sidebar, meta keywords for blog posts, enhanced internal linking.

**Architecture:** Phase 3 modifies UI components (Post.astro, Sidebar.astro, Base.astro) and page files to add visual breadcrumbs, navigation, and improved internal linking structure.

**Tech Stack:** Astro 5.x, existing CSS variables, semantic HTML

## Global Constraints

- Site URL: `https://iapo.cl`
- Output: `static` (pre-rendered)
- Language: `es-CL`
- Organization: Aicore Agency (https://aicorebots.com)
- No breaking changes to existing build
- All new files must pass `npm run build` (exit 0)
- Maintain existing design system (ink #15171c, core #0e8a76, paper #edeee7)

---

### Task 1: Add visual breadcrumbs UI to Base.astro (matching BreadcrumbList schema)

**Files:**
- Modify: `src/layouts/Base.astro`
- Modify: `src/styles/global.css` (if needed for breadcrumb styles)

**Interfaces:**
- Consumes: Base.astro props, Astro.url.pathname, generateBreadcrumbs function
- Produces: Visual breadcrumb navigation on all pages (except homepage)

- [ ] **Step 1: Read current Base.astro and global.css**

```bash
cat src/layouts/Base.astro
cat src/styles/global.css
```

- [ ] **Step 2: Add visual breadcrumb component to Base.astro**

Add breadcrumb rendering after `<body>` and before `<main>`, conditionally (not on homepage):
```astro
{!variant === 'sheet' && (
  <nav class="breadcrumbs" aria-label="Navegación" data-breadcrumbs>
    <ol>
      {generateBreadcrumbs(Astro.url.pathname).itemListElement.map((item, index) => (
        <li>
          {index < generateBreadcrumbs(Astro.url.pathname).itemListElement.length - 1 ? (
            <a href={item.item}>{item.name}</a>
          ) : (
            <span aria-current="page">{item.name}</span>
          )}
          {index < generateBreadcrumbs(Astro.url.pathname).itemListElement.length - 1 && <span class="sep" aria-hidden="true">/</span>}
        </li>
      ))}
    </ol>
  </nav>
)}
```

- [ ] **Step 3: Add breadcrumb styles to global.css**

```css
.breadcrumbs { padding: 16px 0 8px; font-size: 13px; color: var(--ink-dim); }
.breadcrumbs ol { display: flex; flex-wrap: wrap; gap: 4px; margin: 0; padding: 0; list-style: none; }
.breadcrumbs li { display: flex; align-items: center; gap: 4px; }
.breadcrumbs a { color: var(--ink-dim); text-decoration: none; transition: color 0.15s; }
.breadcrumbs a:hover { color: var(--core); }
.breadcrumbs span[aria-current="page"] { color: var(--ink); font-weight: 500; }
.breadcrumbs .sep { color: var(--ink-faint); }
```

- [ ] **Step 4: Verify build passes**

```bash
npm run build
```

- [ ] **Step 5: Commit**

```bash
git add src/layouts/Base.astro src/styles/global.css
git commit -m "seo: add visual breadcrumbs UI to all pages"
```

---

### Task 2: Add Previous/Next navigation to Post.astro

**Files:**
- Modify: `src/layouts/Post.astro`

**Interfaces:**
- Consumes: Post.astro props (allPosts, currentId)
- Produces: Previous/Next article navigation at bottom of blog posts

- [ ] **Step 1: Read current Post.astro**

```bash
cat src/layouts/Post.astro
```

- [ ] **Step 2: Add Previous/Next logic**

After related posts section, add:
```js
const currentIndex = allPosts.findIndex((p) => p.id === currentId);
const prevPost = currentIndex > 0 ? allPosts[currentIndex - 1] : null;
const nextPost = currentIndex < allPosts.length - 1 ? allPosts[currentIndex + 1] : null;
```

- [ ] **Step 3: Add Previous/Next UI**

```astro
{prevPost || nextPost && (
  <nav class="post-nav" data-reveal>
    {prevPost && (
      <a href={`/blog/${prevPost.id}`} class="post-nav-link prev">
        <span class="post-nav-label">← Anterior</span>
        <span class="post-nav-title">{prevPost.data.title}</span>
      </a>
    )}
    {nextPost && (
      <a href={`/blog/${nextPost.id}`} class="post-nav-link next">
        <span class="post-nav-label">Siguiente →</span>
        <span class="post-nav-title">{nextPost.data.title}</span>
      </a>
    )}
  </nav>
)}
```

- [ ] **Step 4: Add post-nav styles to Post.astro style block**

```css
.post-nav { display: flex; gap: 24px; margin-top: 48px; padding-top: 24px; border-top: 1px solid var(--rule); }
.post-nav-link { flex: 1; display: flex; flex-direction: column; gap: 6px; text-decoration: none; color: var(--ink); padding: 16px; background: var(--paper-raised); border-radius: 2px; transition: transform 0.2s, box-shadow 0.2s; }
.post-nav-link:hover { transform: translateY(-2px); box-shadow: 0 8px 16px rgba(0,0,0,0.1); text-decoration: none; }
.post-nav-link.prev { border-left: 3px solid var(--core); }
.post-nav-link.next { border-right: 3px solid var(--core); text-align: right; }
.post-nav-label { font-size: 11px; font-weight: 700; letter-spacing: 0.1em; text-transform: uppercase; color: var(--core); font-family: var(--font-mono); }
.post-nav-title { font-size: 1rem; font-weight: 500; line-height: 1.4; color: var(--ink); }
@media (max-width: 640px) { .post-nav { flex-direction: column; } .post-nav-link.next { text-align: left; } }
```

- [ ] **Step 5: Verify build passes**

```bash
npm run build
```

- [ ] **Step 6: Commit**

```bash
git add src/layouts/Post.astro
git commit -m "seo: add Previous/Next navigation to blog posts"
```

---

### Task 3: Add pillar-based topic clusters to Sidebar.astro

**Files:**
- Modify: `src/components/Sidebar.astro`

**Interfaces:**
- Consumes: Sidebar props (posts, currentId)
- Produces: Sidebar with posts grouped by pillar, highlighted current pillar

- [ ] **Step 1: Read current Sidebar.astro**

```bash
cat src/components/Sidebar.astro
```

- [ ] **Step 2: Add pillar grouping logic**

Group posts by pilar, show pillar headers with counts, highlight current post's pillar.

- [ ] **Step 3: Update Sidebar UI**

```astro
<aside class="sidebar" data-reveal>
  <div class="sidebar-head">
    <span class="eyebrow">// Archivo</span>
    <h3>Por tema</h3>
  </div>
  <ul class="sidebar-list">
    {Object.entries(postsByPilar).map(([pilar, pilarPosts]) => (
      <li class="sidebar-pilar-group">
        <span class="sidebar-pilar-label" data-pilar={pilar}>{pilarLabel[pilar]}</span>
        <ul class="sidebar-pilar-posts">
          {pilarPosts.map((post) => (
            <li class="sidebar-item">
              <a href={`/blog/${post.id}`} class={post.id === currentId ? 'active' : ''}>
                <span class="sidebar-num">{pilarPosts.indexOf(post) + 1}</span>
                <span class="sidebar-body">
                  <span class="sidebar-title">{post.data.title}</span>
                  <span class="sidebar-date">{dateFmt(post.data.pubDate)}</span>
                </span>
              </a>
            </li>
          ))}
        </ul>
      </li>
    ))}
  </ul>
</aside>
```

- [ ] **Step 4: Add pillar styles to Sidebar.astro style block**

- [ ] **Step 5: Verify build passes**

```bash
npm run build
```

- [ ] **Step 6: Commit**

```bash
git add src/components/Sidebar.astro
git commit -m "seo: add pillar-based topic clusters to Sidebar"
```

---

### Task 4: Add meta keywords to blog posts

**Files:**
- Modify: `src/layouts/Post.astro` (already has tags, add meta keywords)
- Modify: `src/components/BaseHead.astro` (add keywords meta for article type)

**Interfaces:**
- Consumes: tags array from blog post frontmatter
- Produces: `<meta name="keywords" content="...">` for blog posts

- [ ] **Step 1: Read BaseHead.astro**

```bash
cat src/components/BaseHead.astro
```

- [ ] **Step 2: Add keywords meta tag for article type**

```astro
{type === 'article' && tags && tags.length > 0 && (
  <meta name="keywords" content={tags.join(', ')} />
)}
```

- [ ] **Step 3: Ensure tags passed through (already done in Phase 2)**

- [ ] **Step 4: Verify build passes**

```bash
npm run build
```

- [ ] **Step 5: Commit**

```bash
git add src/components/BaseHead.astro
git commit -m "seo: add meta keywords to blog posts"
```

---

### Task 5: Enhanced internal linking - cross-reference prompts/repos from blog posts

**Files:**
- Modify: `src/layouts/Post.astro` (add "Recursos mencionados" section)

**Interfaces:**
- Consumes: Blog post content (could parse for references), or static mapping
- Produces: "Recursos mencionados" section linking to relevant prompts/repos

- [ ] **Step 1: Read Post.astro**

```bash
cat src/layouts/Post.astro
```

- [ ] **Step 2: Add resources section after related posts**

For now, add static mapping based on pilar:
```js
const relatedResources = {
  automatizacion: [
    { type: 'prompt', title: 'Calificación de leads por WhatsApp', url: '/prompts#calificacion-leads-whatsapp' },
    { type: 'repo', title: 'n8n-io/n8n', url: 'https://github.com/n8n-io/n8n' },
    { type: 'repo', title: 'evolution-api/evolution-api', url: 'https://github.com/EvolutionAPI/evolution-api' },
  ],
  salud: [
    { type: 'prompt', title: 'Resumen de ficha clínica', url: '/prompts#resumen-ficha-clinica' },
    { type: 'prompt', title: 'Recordatorio de cita con reprogramación', url: '/prompts#recordatorio-cita' },
    { type: 'prompt', title: 'Explicación de resultados de examen', url: '/prompts#explicacion-resultados-examen' },
  ],
  'ia-general': [
    { type: 'prompt', title: 'Resumen de hilo largo en decisiones y pendientes', url: '/prompts#resumen-hilo-largo' },
    { type: 'repo', title: 'open-webui/open-webui', url: 'https://github.com/open-webui/open-webui' },
    { type: 'repo', title: 'Dokploy/dokploy', url: 'https://github.com/Dokploy/dokploy' },
  ],
};
```

- [ ] **Step 3: Add UI for resources section**

```astro
{relatedResources[pilar] && (
  <section class="resources" data-reveal>
    <h2 class="resources-title">Recursos mencionados</h2>
    <ul class="resources-list">
      {relatedResources[pilar].map((resource) => (
        <li>
          <a href={resource.url} target="_blank" rel="noopener" class="resource-link">
            <span class="resource-type">{resource.type === 'prompt' ? 'Prompt' : 'Repo'}</span>
            <span class="resource-title">{resource.title}</span>
          </a>
        </li>
      ))}
    </ul>
  </section>
)}
```

- [ ] **Step 4: Add resource styles**

- [ ] **Step 5: Verify build passes**

```bash
npm run build
```

- [ ] **Step 6: Commit**

```bash
git add src/layouts/Post.astro
git commit -m "seo: add cross-reference resources section to blog posts"
```

---

### Task 6: Verify Phase 3 build and validation

**Files:**
- None (verification only)

**Interfaces:**
- Consumes: All Phase 3 outputs
- Produces: Validation that build passes and features work

- [ ] **Step 1: Full build**

```bash
npm run build
```

- [ ] **Step 2: Verify features in generated HTML**

```bash
# Check breadcrumbs on blog post
cat dist/blog/n8n-ollama-flujo-calificacion-leads/index.html | findstr "breadcrumbs"

# Check Previous/Next on blog post
cat dist/blog/n8n-ollama-flujo-calificacion-leads/index.html | findstr "post-nav"

# Check meta keywords
cat dist/blog/n8n-ollama-flujo-calificacion-leads/index.html | findstr "keywords"

# Check resources section
cat dist/blog/n8n-ollama-flujo-calificacion-leads/index.html | findstr "Recursos"
```

- [ ] **Step 3: Commit any remaining changes**

```bash
git add -A
git commit -m "seo: phase 3 complete - breadcrumbs UI, prev/next nav, pillar clusters, meta keywords, cross-references"
```

---

## Phase 3 Success Criteria Checklist

- [ ] `npm run build` exits 0
- [ ] Visual breadcrumbs on all pages (except homepage), matching schema hierarchy
- [ ] Previous/Next navigation on all blog posts
- [ ] Sidebar shows posts grouped by pillar with current pillar highlighted
- [ ] Blog posts have meta keywords from tags
- [ ] Blog posts have "Recursos mencionados" section linking to relevant prompts/repos
- [ ] No regression in existing pages (12 pages built)
- [ ] Design system consistency maintained

---

## Next Phase Preview (Phase 4)

After Phase 3 approval, Phase 4 will cover:
- AI/LLM specific optimizations (llms-full.txt generation)
- Content structure improvements for AI consumption
- Speakable schema validation
- Performance polish