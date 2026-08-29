# SEO Comprehensive Design — iapo.cl

**Date:** 2026-08-29
**Status:** Draft for review
**Approach:** Incremental by priority phases

---

## Current State Summary

| Area | Status | Notes |
|------|--------|-------|
| Sitemap | ✅ `@astrojs/sitemap` configured | Basic, no `lastmod` per URL |
| robots.txt | ⚠️ Basic only | No AI crawler directives |
| BaseHead | ✅ Solid foundation | OG, Twitter, JSON-LD (Org + BlogPosting) |
| Structured Data | ✅ Org + BlogPosting | Missing: WebSite, BreadcrumbList, FAQPage, Speakable |
| HTML lang | ✅ `es-CL` | No hreflang/alternate |
| Favicon | ⚠️ Referenced | `/favicon.svg` may not exist |
| og:image | ⚠️ Generic `/og.png` | Could be page-specific |

---

## Phase 1 — Core Technical & AI Crawler Foundation (Highest Impact)

### 1.1 Enhanced robots.txt
Add AI crawler directives and crawl-delay:
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

### 1.2 Create llms.txt (AI Training Data Guide)
Per [llms.txt spec](https://llmstxt.org/), place at `/llms.txt`:
```
# iapo.cl — Diario impreso de IA aplicada

> Tips, prompts, skills y repos de IA aplicada, desde Chile.

## Sitio principal
- [Inicio](https://iapo.cl/) — Portada estilo diario impreso con última transmisión, editorial y newsletter
- [Blog](https://iapo.cl/blog) — Artículos técnicos sobre automatización, salud y IA general
- [Prompts](https://iapo.cl/prompts) — Prompts probados en producción para clínicas y automatización
- [Repos](https://iapo.cl/repos) — Herramientas open source evaluadas con uso real
- [Casos](https://iapo.cl/casos) — Casos de estudio reales de implementación
- [Sobre](https://iapo.cl/sobre) — Aicore Agency, contacto, metodología

## Artículos destacados (actualizar periódicamente)
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

### 1.3 Create llms-full.txt (Optional Extended)
Full content dump for AI training — generate from blog posts + prompts + repos.

### 1.4 Favicon
Ensure `/public/favicon.svg` exists (currently referenced in BaseHead).

### 1.5 Sitemap Enhancement
Configure `@astrojs/sitemap` with `lastmod` from frontmatter:
```js
sitemap({
  lastmod: new Date(),
  changefreq: 'weekly',
  priority: 0.7,
  // Custom lastmod per entry from post.data.pubDate
})
```

---

## Phase 2 — Advanced Structured Data

### 2.1 WebSite Schema with SearchAction
Add to Base.astro (homepage only):
```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "@id": "https://iapo.cl/#website",
  "url": "https://iapo.cl/",
  "name": "iapo.cl",
  "description": "Diario impreso de IA aplicada — tips, prompts, skills y repos desde Chile.",
  "publisher": { "@id": "https://iapo.cl/#organization" },
  "potentialAction": {
    "@type": "SearchAction",
    "target": { "@type": "EntryPoint", "urlTemplate": "https://iapo.cl/search?q={search_term_string}" },
    "query-input": "required name=search_term_string"
  },
  "inLanguage": "es-CL"
}
```
Note: Requires search implementation or remove SearchAction.

### 2.2 BreadcrumbList Schema
Add to all pages (Base.astro or per-page):
```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Inicio", "item": "https://iapo.cl/" },
    { "@type": "ListItem", "position": 2, "name": "Blog", "item": "https://iapo.cl/blog" },
    { "@type": "ListItem", "position": 3, "name": "Título del artículo", "item": "https://iapo.cl/blog/slug" }
  ]
}
```

### 2.3 BlogPosting Enhancements
Current BlogPosting has: headline, description, image, author, publisher, datePublished, dateModified, mainEntityOfPage, inLanguage.

Add:
- `articleSection`: pillar (salud/automatizacion/ia-general)
- `keywords`: from tags array
- `author` as Person (not Organization) with sameAs social profiles
- `speakable` for voice search (CSS selectors for key content)
- `hasPart` for sections (h2 headers)

### 2.4 FAQPage Schema (where applicable)
For posts with FAQ sections, add FAQPage schema.

### 2.5 CollectionPage Schema
For /blog, /prompts, /repos listing pages.

---

## Phase 3 — Content SEO & Internal Linking

### 3.1 Breadcrumbs UI + Schema
Visual breadcrumbs in Post.astro, Blog index, Prompts, Repos, Casos.

### 3.2 Enhanced Internal Linking
- Related posts: already exists (3 posts, same pillar priority)
- Add "Previous/Next" navigation in Post.astro
- Add pillar-based topic clusters in Sidebar
- Cross-link prompts/repos from blog posts (already done in new article)

### 3.3 Open Graph Article Enhancements
Add to BaseHead for article type:
- `article:author` (URL to /sobre or author page)
- `article:section` (pillar)
- `article:tag` (tags array)
- `article:published_time`, `article:modified_time`

### 3.4 Meta Keywords (Optional)
Add `<meta name="keywords" content={tags.join(', ')} />` for blog posts.

---

## Phase 4 — AI/LLM Specific Optimizations

### 4.1 Speakable Schema
For voice assistants, mark key content sections:
```json
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "speakable": {
    "@type": "SpeakableSpecification",
    "cssSelector": [".post-head h1", ".deck", ".content > p:first-of-type"]
  }
}
```

### 4.2 Content Structure for AI
- Clear heading hierarchy (h1 → h2 → h3)
- Semantic HTML5 (article, section, aside, nav)
- Descriptive alt text for all images
- Code blocks with language annotations

### 4.3 llms-full.txt Generation
Script to generate full content dump from collections for AI training.

---

## Phase 5 — Performance & Technical Polish

### 5.1 Resource Hints
Already has preconnect for fonts. Add:
- `dns-prefetch` for external domains (Brevo, fonts.gstatic.com)
- `preload` for critical CSS/fonts

### 5.2 Image Optimization
- Ensure `/og.png` is optimized (1200x630, <200KB)
- Add WebP/AVIF variants if using Astro assets
- Page-specific OG images for key pages

### 5.3 HTTP Headers (via nginx/Cloudflare)
- `X-Robots-Tag` for non-HTML resources
- Cache headers (already in nginx.conf: 7d assets, 1h xml/txt)
- Security headers (CSP, HSTS, etc.)

---

## Files to Modify/Create

| File | Action | Phase |
|------|--------|-------|
| `public/robots.txt` | Enhance with AI crawler rules | 1 |
| `public/llms.txt` | Create new | 1 |
| `public/llms-full.txt` | Create new (generated) | 1/4 |
| `public/favicon.svg` | Verify/create | 1 |
| `astro.config.mjs` | Enhance sitemap config | 1 |
| `src/components/BaseHead.astro` | Add article:author, section, tag, keywords, speakable | 2, 3 |
| `src/layouts/Base.astro` | Add WebSite schema, BreadcrumbList schema | 2 |
| `src/layouts/Post.astro` | Enhance BlogPosting, add breadcrumbs UI, prev/next | 2, 3 |
| `src/pages/blog/[id].astro` | Pass tags to layout | 2 |
| `src/pages/index.astro` | Add CollectionPage schema | 2 |
| `src/pages/prompts.astro` | Add CollectionPage schema, breadcrumbs | 2 |
| `src/pages/repos.astro` | Add CollectionPage schema, breadcrumbs | 2 |
| `src/pages/casos.astro` | Add CollectionPage schema, breadcrumbs | 2 |
| `src/pages/sobre.astro` | Add AboutPage schema | 2 |
| `scripts/generate-llms-full.js` | New script for llms-full.txt | 4 |

---

## Success Criteria

- [ ] Lighthouse SEO score ≥ 95
- [ ] All pages have valid JSON-LD (Google Rich Results Test passes)
- [ ] `llms.txt` accessible at `/llms.txt`
- [ ] `robots.txt` allows major AI crawlers
- [ ] Sitemap includes `lastmod` from content dates
- [ ] Breadcrumbs visible + schema on all deep pages
- [ ] Blog posts have article:author, section, tag OG tags
- [ ] Search console shows no coverage errors
- [ ] Core Web Vitals maintained (LCP < 2.5s, CLS < 0.1)

---

## Out of Scope (Future)

- Search implementation (Algolia/Meilisearch/Typesense)
- Multi-language (hreflang)
- AMP
- NewsArticle schema (unless news-focused)
- VideoObject schema
- Product schema