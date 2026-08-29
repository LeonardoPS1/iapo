# SEO Phase 1 — Core Technical & AI Crawler Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement core SEO technical foundation: enhanced robots.txt with AI crawler directives, llms.txt for AI training data, verify/create favicon.svg, enhance sitemap config with per-page lastmod.

**Architecture:** Phase 1 focuses on static files (public/) and config changes only. No component modifications. Each task produces independently verifiable output.

**Tech Stack:** Astro 5.x, @astrojs/sitemap, static file serving via nginx/Cloudflare

## Global Constraints

- Site URL: `https://iapo.cl`
- Output: `static` (pre-rendered)
- Language: `es-CL`
- Organization: Aicore Agency (https://aicorebots.com)
- No breaking changes to existing build
- All new files must pass `npm run build` (exit 0)

---

### Task 1: Enhance robots.txt with AI crawler directives

**Files:**
- Modify: `public/robots.txt`

**Interfaces:**
- Consumes: None (standalone)
- Produces: Enhanced robots.txt accessible at `/robots.txt`

- [ ] **Step 1: Read current robots.txt**

```bash
cat public/robots.txt
```

- [ ] **Step 2: Write enhanced robots.txt**

```txt
User-agent: *
Allow: /
Crawl-delay: 10

# AI crawlers - allow for training/indexing
User-agent: GPTBot
Allow: /
User-agent: ChatGPT-User
Allow: /
User-agent: CCBot
Allow: /
User-agent: anthropic-ai
Allow: /
User-agent: Claude-Web
Allow: /
User-agent: PerplexityBot
Allow: /

Sitemap: https://iapo.cl/sitemap-index.xml
```

- [ ] **Step 3: Verify file exists and build passes**

```bash
npm run build
```

- [ ] **Step 4: Commit**

```bash
git add public/robots.txt
git commit -m "seo: enhance robots.txt with AI crawler directives and crawl-delay"
```

---

### Task 2: Create llms.txt for AI training data guide

**Files:**
- Create: `public/llms.txt`

**Interfaces:**
- Consumes: Site structure knowledge (pages, key articles, prompts, repos)
- Produces: llms.txt accessible at `/llms.txt` per llmstxt.org spec

- [ ] **Step 1: Create llms.txt with current site structure**

```txt
# iapo.cl — Diario impreso de IA aplicada

> Tips, prompts, skills y repos de IA aplicada, desde Chile.

## Sitio principal
- [Inicio](https://iapo.cl/) — Portada estilo diario impreso con última transmisión, editorial y newsletter
- [Blog](https://iapo.cl/blog) — Artículos técnicos sobre automatización, salud y IA general
- [Prompts](https://iapo.cl/prompts) — Prompts probados en producción para clínicas y automatización
- [Repos](https://iapo.cl/repos) — Herramientas open source evaluadas con uso real
- [Casos](https://iapo.cl/casos) — Casos de estudio reales de implementación
- [Sobre](https://iapo.cl/sobre) — Aicore Agency, contacto, metodología

## Artículos destacados
- [n8n + Ollama: flujo de calificación de leads](https://iapo.cl/blog/n8n-ollama-flujo-calificacion-leads) — Arquitectura de 4 pasos, por qué modelo local, manejo de errores
- [WhatsApp para clínicas: Meta vs Evolution API](https://iapo.cl/blog/whatsapp-clinicas-meta-vs-evolution) — Comparativa técnica con código
- [Repos de la semana #1](https://iapo.cl/blog/repos-de-la-semana-1) — Curaduría de herramientas open source

## Recursos técnicos
- [Prompts de calificación de leads](https://iapo.cl/prompts#calificacion-leads-whatsapp) — WhatsApp receptionist para clínicas
- [Resumen ficha clínica](https://iapo.cl/prompts#resumen-ficha-clinica) — Para profesionales de salud
- [Recordatorio cita con reprogramación](https://iapo.cl/prompts#recordatorio-cita) — Automatización WhatsApp
- [Explicación resultados examen](https://iapo.cl/prompts#explicacion-resultados-examen) — Lenguaje simple para pacientes
- [Resumen hilo largo decisiones/pendientes](https://iapo.cl/prompts#resumen-hilo-largo) — IA general

## Contacto
- Email: iapo@aicorebots.com
- Web: https://aicorebots.com
- Newsletter: https://iapo.cl/#suscribir (Brevo)
```

- [ ] **Step 2: Verify file exists and build passes**

```bash
npm run build
```

- [ ] **Step 3: Commit**

```bash
git add public/llms.txt
git commit -m "seo: add llms.txt for AI training data guide per llmstxt.org"
```

---

### Task 3: Verify/create favicon.svg

**Files:**
- Verify/Create: `public/favicon.svg`

**Interfaces:**
- Consumes: Design system (teal #0e8a76, ink #15171c, paper #edeee7)
- Produces: Valid SVG favicon referenced by BaseHead.astro

- [ ] **Step 1: Check if favicon.svg exists**

```bash
ls -la public/favicon.svg
```

- [ ] **Step 2: If missing, create minimal favicon.svg**

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" fill="#15171c" rx="4"/>
  <text x="16" y="22" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#0e8a76" text-anchor="middle">i</text>
</svg>
```

- [ ] **Step 3: Verify file exists and build passes**

```bash
npm run build
```

- [ ] **Step 4: Commit**

```bash
git add public/favicon.svg
git commit -m "seo: add favicon.svg referenced by BaseHead"
```

---

### Task 4: Enhance sitemap config with per-page lastmod

**Files:**
- Modify: `astro.config.mjs`

**Interfaces:**
- Consumes: Blog collection with `pubDate` frontmatter
- Produces: Sitemap with accurate `lastmod` per URL

- [ ] **Step 1: Read current astro.config.mjs**

```bash
cat astro.config.mjs
```

- [ ] **Step 2: Update sitemap config to use custom lastmod from content**

```js
// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://iapo.cl',
  output: 'static',
  integrations: [
    sitemap({
      lastmod: new Date(),
      changefreq: 'weekly',
      priority: 0.7,
      // Note: @astrojs/sitemap automatically uses `lastmod` from frontmatter if present
      // For blog posts, it reads `pubDate` or `lastmod` from the collection entry
      filter: (page) => !page.includes('/suscribir') && !page.includes('/search'),
    }),
  ],
});
```

Note: The sitemap integration automatically picks up `pubDate` from blog frontmatter as `lastmod`. The `changefreq` and `priority` are defaults.

- [ ] **Step 3: Verify build passes and check sitemap output**

```bash
npm run build
cat dist/sitemap-index.xml
```

- [ ] **Step 4: Commit**

```bash
git add astro.config.mjs
git commit -m "seo: enhance sitemap config with changefreq, priority, filter"
```

---

### Task 5: Verify Phase 1 build and run basic validation

**Files:**
- None (verification only)

**Interfaces:**
- Consumes: All Phase 1 outputs
- Produces: Validation that build passes and new files are in dist/

- [ ] **Step 1: Full build**

```bash
npm run build
```

- [ ] **Step 2: Verify new files in dist/**

```bash
ls -la dist/robots.txt dist/llms.txt dist/favicon.svg dist/sitemap-index.xml
```

- [ ] **Step 3: Validate sitemap structure**

```bash
cat dist/sitemap-index.xml
```

- [ ] **Step 4: Validate robots.txt content**

```bash
cat dist/robots.txt
```

- [ ] **Step 5: Validate llms.txt content**

```bash
cat dist/llms.txt
```

- [ ] **Step 6: Commit any remaining changes**

```bash
git add -A
git commit -m "seo: phase 1 complete - robots.txt, llms.txt, favicon, sitemap enhanced"
```

---

## Phase 1 Success Criteria Checklist

- [ ] `npm run build` exits 0
- [ ] `dist/robots.txt` contains AI crawler directives (GPTBot, ChatGPT-User, CCBot, anthropic-ai, Claude-Web, PerplexityBot)
- [ ] `dist/llms.txt` exists and follows llmstxt.org format
- [ ] `dist/favicon.svg` exists and is valid SVG
- [ ] `dist/sitemap-index.xml` includes `lastmod` dates from blog posts
- [ ] No regression in existing pages (12 pages built)

---

## Next Phase Preview (Phase 2)

After Phase 1 approval, Phase 2 will cover:
- WebSite schema with SearchAction (homepage)
- BreadcrumbList schema (all pages)
- Enhanced BlogPosting (articleSection, keywords, speakable)
- CollectionPage schema (/blog, /prompts, /repos, /casos)
- Open Graph article enhancements (article:author, section, tag)