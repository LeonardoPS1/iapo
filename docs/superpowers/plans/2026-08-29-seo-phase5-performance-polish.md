# SEO Phase 5 — Performance & Technical Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement performance and technical polish: resource hints, image optimization, HTTP headers validation, Lighthouse SEO score target.

**Architecture:** Phase 5 adds resource hints to BaseHead.astro, verifies og.png optimization, documents nginx/Cloudflare headers, runs Lighthouse audit.

**Tech Stack:** Astro 5.x, BaseHead.astro for resource hints, nginx/Cloudflare for HTTP headers

## Global Constraints

- Site URL: `https://iapo.cl`
- Output: `static` (pre-rendered)
- Language: `es-CL`
- Organization: Aicore Agency (https://aicorebots.com)
- No breaking changes to existing build
- All new files must pass `npm run build` (exit 0)
- Design system: ink #15171c, core #0e8a76, paper #edeee7

---

### Task 1: Add resource hints to BaseHead.astro

**Files:**
- Modify: `src/components/BaseHead.astro`

**Interfaces:**
- Consumes: BaseHead props
- Produces: dns-prefetch and preload hints

- [ ] **Step 1: Read current BaseHead.astro**

```bash
cat src/components/BaseHead.astro
```

- [ ] **Step 2: Add resource hints**

Add after existing preconnect links:
```astro
<!-- DNS Prefetch for external domains -->
<link rel="dns-prefetch" href="https://fonts.gstatic.com" />
<link rel="dns-prefetch" href="https://db52c710.sibforms.com" />
<link rel="dns-prefetch" href="https://aicorebots.com" />

<!-- Preload critical resources -->
<link rel="preload" as="font" type="font/woff2" crossorigin href="https://fonts.gstatic.com/s/playfairdisplay/v30/nuFvD-vYSZviVYUb_rj3ij__anPXJzDwcbmjWBN2PKdFvXDXbtAU.woff2" />
<link rel="preload" as="font" type="font/woff2" crossorigin href="https://fonts.gstatic.com/s/inter/v19/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfAZ9hjp-Ek-_EeA.woff2" />
<link rel="preload" as="image" href="/og.png" />
```

- [ ] **Step 3: Verify build passes**

```bash
npm run build
```

- [ ] **Step 4: Commit**

```bash
git add src/components/BaseHead.astro
git commit -m "seo: add resource hints (dns-prefetch, preload) to BaseHead"
```

---

### Task 2: Verify og.png optimization

**Files:**
- Verify: `public/og.png`

**Interfaces:**
- Consumes: Existing og.png
- Produces: Validation report

- [ ] **Step 1: Check og.png exists and dimensions**

```bash
# Use ImageMagick or similar to check
file public/og.png
```

- [ ] **Step 2: Verify size < 200KB, dimensions 1200x630**

- [ ] **Step 3: If needed, optimize or document**

- [ ] **Step 4: Commit if changes**

```bash
git add public/og.png
git commit -m "seo: optimize og.png for social sharing"
```

---

### Task 3: Document HTTP headers (nginx/Cloudflare)

**Files:**
- Create: `docs/nginx-headers.md` (documentation)
- Verify: Existing nginx.conf

**Interfaces:**
- Consumes: Existing nginx configuration
- Produces: Documentation of headers

- [ ] **Step 1: Read current nginx.conf**

```bash
cat nginx.conf
```

- [ ] **Step 2: Document required headers**

Create documentation with:
- X-Robots-Tag for non-HTML
- Cache headers (already: 7d assets, 1h xml/txt)
- Security headers (CSP, HSTS, X-Frame-Options, X-Content-Type-Options)

- [ ] **Step 3: Commit**

```bash
git add docs/nginx-headers.md
git commit -m "docs: document nginx/Cloudflare HTTP headers for SEO"
```

---

### Task 4: Run Lighthouse audit and validate SEO score

**Files:**
- None (verification only)

**Interfaces:**
- Consumes: Built site in dist/
- Produces: Lighthouse report

- [ ] **Step 1: Run Lighthouse on local build**

```bash
# Using lighthouse CLI or Chrome DevTools
npx lighthouse http://localhost:4321 --output=json --output-path=lighthouse-report.json
```

- [ ] **Step 2: Verify SEO score ≥ 95**

- [ ] **Step 3: Verify all audits pass**

- [ ] **Step 4: Fix any issues if needed**

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "seo: phase 5 complete - resource hints, image optimization, headers docs, Lighthouse validation"
```

---

## Phase 5 Success Criteria Checklist

- [ ] `npm run build` exits 0
- [ ] Resource hints present in BaseHead (dns-prefetch, preload)
- [ ] og.png optimized (1200x630, <200KB)
- [ ] nginx/Cloudflare headers documented
- [ ] Lighthouse SEO score ≥ 95
- [ ] Core Web Vitals maintained (LCP < 2.5s, CLS < 0.1)
- [ ] No regression in existing pages (12 pages built)

---

## Complete SEO Project Summary

After Phase 5, all 5 phases complete:

| Phase | Commit | Key Features |
|-------|--------|--------------|
| 1. Core Technical | 1fb0863 | robots.txt (AI crawlers), llms.txt, favicon.svg, sitemap with per-page lastmod |
| 2. Advanced Structured Data | 7ca1bbe | WebSite, BreadcrumbList, enhanced BlogPosting, CollectionPage/AboutPage, OG article:* |
| 3. Content SEO & Internal Linking | bc91bce | Visual breadcrumbs, prev/next nav, pillar clusters, meta keywords, cross-references |
| 4. AI/LLM Optimizations | f8db03e | llms-full.txt generation, speakable validation, content structure verification |
| 5. Performance & Technical Polish | TBD | Resource hints, og.png optimization, headers docs, Lighthouse ≥ 95 |