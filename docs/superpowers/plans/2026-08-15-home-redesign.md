# Home iapo.cl — Rediseño estilo "edición impresa" — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rediseñar el index de iapo.cl replicando la estructura, proporciones y animaciones de Daily Dispatch (loader de entrada, hoja de periódico sobre fondo oscuro, masthead, headline con reveal por línea, ilustración en overlap, copy editorial en 2 columnas), conservando la identidad visual propia.

**Architecture:** El index pasa a un layout `variant="sheet"`: fondo tinta oscura + hoja de periódico centrada (max-width 840px) que contiene todo. `Base.astro` gana una prop `variant` para omitir el Header global y cambiar el fondo/footer. Los estilos de la hoja son scoped en `index.astro`; `global.css` solo swap de fuentes y overrides del footer oscuro. Nueva ilustración `HeroArt.astro` (SVG inline, patrón del Mascot existente). Data de blog intacta.

**Tech Stack:** Astro 7 (SSG), CSS puro, SVG inline, Google Fonts (Playfair Display, Inter, JetBrains Mono).

## Global Constraints

- **Verificación:** no hay test runner en el proyecto. Cada tarea verifica con `npm run build` (exit 0) y, cuando corresponde, `npm run preview` (visual manual). NO inventar framework de tests.
- **Commits:** un commit por tarea con mensaje conciso en español, estilo del repo (`docs:`, `feat:`, `style:`). Push a GitHub solo en la tarea final (repo `LeonardoPS1/iapo`, branch `main`); Dokploy auto-despliega.
- **prefers-reduced-motion:** reducir. Sin loader, contenido visible directo, sin reveals.
- **Sin comentarios en el código** salvo los que ya existen en el archivo.
- **Tipografías exactas:** display/nameplate `'Playfair Display'`, body `'Inter'`, mono `'JetBrains Mono'`.
- **Fuera de alcance:** blog, prompts, repos, casos, sobre; schema de posts; RSS/sitemap/favicon.

---

### Task 1: Swap de tipografías en global.css

**Files:**
- Modify: `src/styles/global.css` (línea 5 del @import y tokens 29-32)

**Interfaces:**
- Consumes: nada.
- Produces: tokens `--font-display`, `--font-nameplate` = Playfair Display; `--font-mono` = JetBrains Mono. Resto del plan usa estos tokens.

- [ ] **Step 1: Actualizar el @import de Google Fonts**

Reemplazar la línea 5 (la del `@import` actual con Fraunces + Inter + Space Mono) por:

```css
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400..900;1,400..900&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;700&display=swap');
```

- [ ] **Step 2: Actualizar los tokens de fuente en `:root`**

En `src/styles/global.css`, cambiar las líneas 29-32:

```css
  --font-nameplate: 'Playfair Display', 'Iowan Old Style', serif;
  --font-display: 'Playfair Display', 'Iowan Old Style', serif;
  --font-body: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-mono: 'JetBrains Mono', ui-monospace, 'SFMono-Regular', monospace;
```

- [ ] **Step 3: Verificar build**

Run: `npm run build`
Expected: exit 0, sin errores, generado en `dist/`.

- [ ] **Step 4: Commit**

```bash
git add src/styles/global.css
git commit -m "style: swap tipografías a Playfair Display / Inter / JetBrains Mono"
```

---

### Task 2: Prop `variant="sheet"` en Base.astro + fondo oscuro y footer

**Files:**
- Modify: `src/layouts/Base.astro`
- Modify: `src/styles/global.css` (al final del archivo)

**Interfaces:**
- Consumes: nada.
- Produces: `Base` acepta prop opcional `variant: 'default' | 'sheet'` (default `'default'`). Cuando es `sheet`: `<body data-variant="sheet">`, NO renderiza `<Header />`, y `<main>` usa clase `sheet-stage` (sin `.wrap`). El `<script>` de data-reveal se mantiene igual.

- [ ] **Step 1: Agregar prop variant a Base.astro**

Modificar `src/layouts/Base.astro`:

```astro
interface Props {
  title: string;
  description?: string;
  variant?: 'default' | 'sheet';
}

const { title, description = 'Tips, prompts, skills y repos de IA aplicada, desde Chile.', variant = 'default' } = Astro.props;
```

- [ ] **Step 2: Render condicional en Base.astro**

Modificar el `<body>` para aplicar el variant, omitir Header y cambiar la clase del main:

```astro
  <body data-variant={variant}>
    {variant !== 'sheet' && <Header />}
    <main class={variant === 'sheet' ? 'sheet-stage' : 'wrap'}>
      <slot />
    </main>
    <Footer />
```

Mantener el `<script>` de data-reveal tal cual.

- [ ] **Step 3: Fondo oscuro y footer en global.css**

Agregar al final de `src/styles/global.css`:

```css
/* ===== Sheet variant — index como "edición impresa" ===== */
body[data-variant="sheet"] {
  background: var(--ink);
}
.sheet-stage {
  width: 100%;
  padding: 0;
}
body[data-variant="sheet"] .footer {
  border-top-color: rgba(237, 238, 231, 0.2);
  margin-top: 0;
  padding-top: 40px;
}
body[data-variant="sheet"] .footer .credit { color: var(--ink-faint); }
```

- [ ] **Step 4: Verificar build**

Run: `npm run build`
Expected: exit 0. (El index aún no usa `variant="sheet"`, así que nada cambia visualmente todavía.)

- [ ] **Step 5: Commit**

```bash
git add src/layouts/Base.astro src/styles/global.css
git commit -m "feat: prop variant=sheet en Base.astro con fondo oscuro"
```

---

### Task 3: Componente HeroArt.astro (robot con tablet mini-mockup)

**Files:**
- Create: `src/components/HeroArt.astro`

**Interfaces:**
- Consumes: tokens CSS existentes (`--ink`, `--paper`, `--paper-raised`, `--core`, `--comic-red`, `--rule`, `--ink-faint`).
- Produces: componente `<HeroArt size={number} />` (default 300) — misma interfaz que `Mascot.astro`. `aria-hidden`, clases propias `ha-*`, animaciones `ha-blink`, `ha-wobble`, `ha-float` (solo con `prefers-reduced-motion: no-preference`). `index.astro` lo monta en `.hero-art` y controla el ancho vía prop `size`.

- [ ] **Step 1: Crear el componente**

Crear `src/components/HeroArt.astro` con este contenido:

```astro
---
interface Props {
  size?: number;
}
const { size = 300 } = Astro.props;
---
<div class="hero-art" style={`width:${size}px`} aria-hidden="true">
  <svg viewBox="0 0 240 260" xmlns="http://www.w3.org/2000/svg">
    <!-- antenna -->
    <line x1="110" y1="18" x2="110" y2="42" stroke="var(--ink)" stroke-width="4" stroke-linecap="round" />
    <circle class="ha-ball" cx="110" cy="16" r="7" fill="var(--comic-red)" stroke="var(--ink)" stroke-width="3" />

    <!-- head -->
    <circle cx="110" cy="96" r="58" fill="var(--paper-raised)" stroke="var(--ink)" stroke-width="4.5" />
    <circle cx="92" cy="92" r="9" fill="var(--core)" />
    <circle cx="128" cy="92" r="9" fill="var(--comic-red)" />
    <path d="M86 118c8 8 40 8 48 0" stroke="var(--ink)" stroke-width="4" stroke-linecap="round" fill="none" />

    <!-- body -->
    <rect x="64" y="150" width="92" height="64" rx="12" fill="var(--paper-raised)" stroke="var(--ink)" stroke-width="4.5" />
    <line x1="80" y1="170" x2="140" y2="170" stroke="var(--ink-faint)" stroke-width="2.5" />
    <line x1="80" y1="182" x2="128" y2="182" stroke="var(--ink-faint)" stroke-width="2.5" />

    <!-- arm -->
    <path d="M156 178c16 0 30 8 34 22" stroke="var(--ink)" stroke-width="4.5" stroke-linecap="round" fill="none" />

    <!-- tablet con mini-mockup de la UI -->
    <g class="ha-tablet">
      <rect x="148" y="96" width="86" height="116" rx="10" fill="var(--paper)" stroke="var(--ink)" stroke-width="4" transform="rotate(7 191 154)" />
      <rect x="154" y="102" width="74" height="104" rx="4" fill="var(--paper-raised)" transform="rotate(7 191 154)" />
      <circle cx="202" cy="112" r="4" fill="var(--comic-red)" transform="rotate(7 191 154)" />
      <rect x="160" y="110" width="62" height="3" fill="var(--ink)" transform="rotate(7 191 154)" />
      <rect x="160" y="118" width="40" height="3" fill="var(--core)" transform="rotate(7 191 154)" />
      <rect x="160" y="128" width="62" height="2" fill="var(--rule)" transform="rotate(7 191 154)" />
      <rect x="160" y="136" width="54" height="4" fill="var(--ink)" opacity="0.85" transform="rotate(7 191 154)" />
      <rect x="160" y="146" width="60" height="2" fill="var(--rule)" transform="rotate(7 191 154)" />
      <rect x="160" y="152" width="48" height="2" fill="var(--rule)" transform="rotate(7 191 154)" />
    </g>
  </svg>
</div>

<style>
  .hero-art { max-width: 100%; aspect-ratio: 240 / 260; }
  .hero-art svg { width: 100%; height: 100%; display: block; overflow: visible; }
  .ha-ball, .ha-tablet { transform-box: fill-box; transform-origin: center; }
  @media (prefers-reduced-motion: no-preference) {
    .ha-ball { animation: ha-blink 2.6s ease-in-out infinite; }
    .ha-tablet { animation: ha-wobble 3.4s ease-in-out infinite; }
    .hero-art { animation: ha-float 5.5s ease-in-out infinite; }
  }
  @keyframes ha-blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.35; } }
  @keyframes ha-wobble { 0%, 100% { transform: rotate(0deg); } 50% { transform: rotate(-3deg); } }
  @keyframes ha-float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }
</style>
```

- [ ] **Step 2: Verificar build**

Run: `npm run build`
Expected: exit 0. (Aún no se importa en ninguna página; el componente se compila igualmente porque está en `src/components`.)

- [ ] **Step 3: Commit**

```bash
git add src/components/HeroArt.astro
git commit -m "feat: componente HeroArt con robot y tablet mini-mockup"
```

---

### Task 4: Rediseño completo del index (loader + hoja + masthead + hero + editorial + contenido)

**Files:**
- Modify: `src/pages/index.astro` (reescritura completa)

**Interfaces:**
- Consumes: `Base` con `variant="sheet"` (Task 2), `Wordmark` (size prop), `HeroArt` (Task 3), `Sidebar` (props `posts`), `getCollection` de `astro:content`, `pilarLabel` y `dateFmt` (ya existentes), tokens globales (`.eyebrow`, `.tag`, `.panel`, `.btn`, `.lede`).
- Produces: página `/` con la edición impresa; usa `data-reveal` (script de Base) en las secciones de contenido y `data-loader`/`data-sheet`/`.hl-line` para el script local.

- [ ] **Step 1: Reescribir el frontmatter**

Mantener el frontmatter actual pero agregar `HeroArt` y un array `nav`:

```astro
---
import Base from '../layouts/Base.astro';
import Wordmark from '../components/Wordmark.astro';
import HeroArt from '../components/HeroArt.astro';
import Sidebar from '../components/Sidebar.astro';
import { getCollection } from 'astro:content';

const allPosts = await getCollection('blog', ({ data }) => !data.draft);
const posts = allPosts.sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());
const [featured, ...rest] = posts;

const pilarLabel: Record<string, string> = {
  salud: 'IA en salud',
  automatizacion: 'Automatización',
  'ia-general': 'IA general',
};
const dateFmt = (d: Date) => new Intl.DateTimeFormat('es-CL', { day: 'numeric', month: 'short', year: 'numeric' }).format(d);

const nav = [
  { href: '/blog', label: 'Blog' },
  { href: '/prompts', label: 'Prompts' },
  { href: '/repos', label: 'Repos' },
  { href: '/casos', label: 'Casos' },
  { href: '/sobre', label: 'Sobre' },
];
---
```

- [ ] **Step 2: Escribir el markup (loader + hoja)**

Reemplazar el cuerpo entre `<Base ...>` y `</Base>` por:

```astro
<Base title="Inicio" variant="sheet">

  <div class="loader" data-loader aria-hidden="true">
    <Wordmark size={40} />
    <span class="loader-kicker mono">IMPRIMIENDO EDICIÓN N°1…</span>
  </div>

  <article class="sheet" data-sheet>

    <header class="sheet-masthead">
      <div class="mast-row">
        <div class="mast-date mono">
          <span class="mast-day">AGO</span>
          <span class="mast-year">2026</span>
        </div>
        <a href="/" class="mast-nameplate" aria-label="iapo.cl — inicio">
          <Wordmark size={56} />
        </a>
        <div class="mast-edition mono">
          <span class="mast-no">N°1</span>
          <span class="mast-loc">VIÑA DEL MAR</span>
        </div>
      </div>
      <div class="mast-rule" aria-hidden="true"></div>
      <nav class="mast-nav" aria-label="Principal">
        {nav.map((item) => <a href={item.href}>{item.label}</a>)}
      </nav>
    </header>

    <section class="hero">
      <h1 class="hero-h1">
        <span class="hl-line" style="width:62%">Menos hype,</span>
        <span class="hl-line" style="width:52%">más <span class="hl-accent">iapo</span>.</span>
        <span class="hl-line" style="width:44%">directo.</span>
      </h1>
      <div class="hero-art">
        <HeroArt size={300} />
      </div>
    </section>

    <section class="editorial">
      <h3 class="ed-h3">IA aplicada, sin traducciones genéricas.</h3>
      <div class="ed-grid">
        <p><span class="ed-lead">Automatización real.</span> Herramientas que hacemos correr en tu negocio y las explicamos paso a paso, con código y casos.</p>
        <p><span class="ed-lead">Salud primero.</span> IA aplicada a clínicas y consultorios: menos carga administrativa, sin inventos.</p>
        <p><span class="ed-lead">Probado antes de recomendar.</span> Cada skill y repo que publicamos pasó por pruebas reales antes de llegar a esta hoja.</p>
      </div>
      <div class="hero-actions">
        <a class="btn" href="#suscribir">Suscribirme</a>
        <a class="btn btn-ghost" href="/blog">Ver todo el blog →</a>
      </div>
    </section>

    <hr class="sheet-rule" aria-hidden="true" />

    <div class="mag-grid">
      <section class="mag-main">
        <div class="section-head" data-reveal>
          <span class="eyebrow">// Portada</span>
          <h2>Última transmisión</h2>
        </div>

        {featured && (
          <a href={`/blog/${featured.id}`} class="featured panel" data-reveal>
            <div class="featured-meta">
              <span class="tag" data-pilar={featured.data.pilar}>{pilarLabel[featured.data.pilar]}</span>
              <span class="eyebrow">{dateFmt(featured.data.pubDate)}</span>
            </div>
            <h3 class="featured-title">{featured.data.title}</h3>
            <p class="featured-desc">{featured.data.description}</p>
            <span class="featured-cta mono">Leer artículo →</span>
          </a>
        )}

        {rest.length > 0 && (
          <div class="more-list">
            {rest.map((post) => (
              <a href={`/blog/${post.id}`} class="post-row" data-reveal>
                <span class="tag" data-pilar={post.data.pilar}>{pilarLabel[post.data.pilar]}</span>
                <span class="post-row-title">{post.data.title}</span>
                <span class="eyebrow">{dateFmt(post.data.pubDate)}</span>
              </a>
            ))}
          </div>
        )}

        {posts.length === 0 && <p class="empty">Todavía no hay publicaciones. Vuelve pronto.</p>}
      </section>

      <Sidebar posts={posts} />
    </div>

    <hr class="sheet-rule" aria-hidden="true" />

    <section id="suscribir" class="subscribe panel" data-reveal>
      <div class="subscribe-inner">
        <span class="eyebrow">// Frecuencia semanal</span>
        <h2>No te pierdas la próxima señal</h2>
        <p class="lede">Un correo a la semana: 3 tips, 1 repo curado, 1 caso de uso real.</p>
        <form class="subscribe-form" action="https://newsletter.iapo.cl/subscription/form" method="post">
          <input type="email" name="email" placeholder="tu@correo.cl" required aria-label="Correo electrónico" />
          <button type="submit">Suscribirme</button>
        </form>
      </div>
    </section>

  </article>
</Base>
```

- [ ] **Step 3: Escribir los estilos scoped**

Reemplazar el bloque `<style>` completo de `index.astro` por:

```css
  .loader {
    position: fixed; inset: 0; z-index: 50;
    display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 18px;
    background: var(--ink); color: var(--paper);
    opacity: 1; visibility: visible;
    transition: opacity 0.7s ease, visibility 0.7s ease;
  }
  .loader.is-gone { opacity: 0; visibility: hidden; }
  .loader-kicker {
    font-size: 11px; letter-spacing: 0.22em; text-transform: uppercase;
    color: var(--ink-faint);
  }

  .sheet {
    position: relative;
    background: var(--paper);
    color: var(--ink);
    max-width: 840px;
    margin: 0 auto;
    padding: 44px 56px 52px;
    border-radius: 2px;
    box-shadow: 0 24px 64px rgba(0, 0, 0, 0.45), 0 2px 8px rgba(0, 0, 0, 0.3);
    opacity: 0;
    transform: scale(0.97);
    transform-origin: center;
    transition: opacity 0.7s cubic-bezier(0.23, 1, 0.32, 1), transform 0.7s cubic-bezier(0.23, 1, 0.32, 1);
  }
  .sheet.is-revealed { opacity: 1; transform: scale(1); }

  .mast-row { display: grid; grid-template-columns: 1fr auto 1fr; align-items: center; }
  .mast-nameplate { text-align: center; text-decoration: none; }
  .mast-nameplate:hover { text-decoration: none; }
  .mast-date, .mast-edition { display: flex; flex-direction: column; gap: 2px; }
  .mast-date { align-items: flex-start; }
  .mast-edition { align-items: flex-end; }
  .mast-day { font-size: 13px; font-weight: 700; letter-spacing: 0.14em; }
  .mast-year { font-size: 11px; color: var(--ink-faint); letter-spacing: 0.2em; }
  .mast-no { font-size: 11px; color: var(--comic-red); font-weight: 700; letter-spacing: 0.14em; }
  .mast-loc { font-size: 11px; color: var(--ink-faint); letter-spacing: 0.1em; }
  .mast-rule {
    height: 2px; margin: 18px 0 0;
    background-image: repeating-linear-gradient(90deg, var(--ink) 0 2px, transparent 2px 7px);
  }
  .mast-nav {
    display: flex; justify-content: center; gap: 26px; padding: 12px 0 4px;
    font-family: var(--font-mono); font-size: 12px; font-weight: 700;
  }
  .mast-nav a { color: var(--ink-dim); letter-spacing: 0.04em; text-decoration: none; position: relative; }
  .mast-nav a::after {
    content: ''; position: absolute; left: 0; bottom: -3px;
    width: 0; height: 1.5px; background: var(--core);
    transition: width 0.2s ease;
  }
  .mast-nav a:hover { color: var(--ink); text-decoration: none; }
  .mast-nav a:hover::after { width: 100%; }

  .hero { position: relative; padding: 40px 0 8px; }
  .hero-h1 { font-family: var(--font-display); font-weight: 600; line-height: 1.04; letter-spacing: -0.015em; margin: 0; }
  .hl-line { display: block; max-width: 100%; }
  .hl-line:nth-child(1) { font-size: clamp(2.5rem, 6.6vw, 4.1rem); }
  .hl-line:nth-child(2) { font-size: clamp(2.3rem, 6vw, 3.8rem); }
  .hl-line:nth-child(3) { font-size: clamp(1.9rem, 4.8vw, 3.1rem); color: var(--ink-dim); }
  .hl-accent { color: var(--comic-red); display: inline-block; transform: rotate(-3deg); }

  .hl-line {
    opacity: 0;
    transform: translateY(14px);
    transition: opacity 0.5s cubic-bezier(0.16, 1, 0.3, 1), transform 0.5s cubic-bezier(0.16, 1, 0.3, 1);
  }
  .hl-line.is-in { opacity: 1; transform: translateY(0); }

  .hero-art {
    position: relative; z-index: 10;
    margin-top: -58px; margin-right: -8px;
    display: flex; justify-content: flex-end;
    pointer-events: none;
  }

  .editorial { padding: 26px 0 10px; }
  .ed-h3 { font-size: clamp(1.35rem, 3vw, 1.75rem); font-weight: 600; margin: 0 0 18px; }
  .ed-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px 32px; }
  .ed-grid p { margin: 0; color: var(--ink-dim); font-size: 0.97rem; line-height: 1.6; }
  .ed-grid p:last-child { grid-column: 1 / -1; }
  .ed-lead {
    color: var(--ink); font-weight: 600;
    text-decoration: underline; text-underline-offset: 3px;
    text-decoration-color: var(--core); text-decoration-thickness: 2px;
  }

  .hero-actions { display: flex; gap: 14px; flex-wrap: wrap; margin-top: 28px; }

  .btn {
    font-family: var(--font-mono);
    font-size: 13px;
    letter-spacing: 0.02em;
    padding: 12px 22px;
    border-radius: 999px;
    background: var(--core);
    color: var(--paper-raised);
    border: 1px solid var(--core);
    text-decoration: none;
    font-weight: 700;
    transition: transform 0.2s cubic-bezier(0.2, 0.7, 0.3, 1), box-shadow 0.2s ease, filter 0.15s ease;
  }
  .btn:hover { text-decoration: none; transform: translateY(-2px); box-shadow: 0 10px 20px rgba(14, 138, 118, 0.25); filter: brightness(1.05); }
  .btn-ghost { background: transparent; border: 1px solid var(--rule-strong); color: var(--ink); }
  .btn-ghost:hover { box-shadow: none; border-color: var(--ink); background: var(--paper-raised); }

  .sheet-rule {
    border: none; height: 2px; margin: 40px 0;
    background-image: repeating-linear-gradient(90deg, var(--ink) 0 2px, transparent 2px 7px);
    opacity: 0.3;
  }

  .mag-grid { display: grid; grid-template-columns: 1fr 280px; gap: 40px; align-items: start; }

  .section-head { margin-bottom: 22px; }
  .section-head h2 { font-size: 1.4rem; margin-top: 6px; }

  .featured { display: block; padding: 26px; margin-bottom: 28px; }
  .featured-meta { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
  .featured-title { font-size: 1.5rem; margin: 0 0 12px; line-height: 1.25; }
  .featured-desc { color: var(--ink-dim); font-size: 1rem; line-height: 1.6; margin: 0 0 18px; }
  .featured-cta { font-size: 12.5px; font-weight: 700; color: var(--core); }

  .more-list { display: flex; flex-direction: column; }
  .post-row {
    display: flex; align-items: center; gap: 14px;
    padding: 16px 4px;
    border-bottom: 1px solid var(--rule);
    color: var(--ink);
    transition: padding-left 0.2s ease;
  }
  .post-row:hover { text-decoration: none; padding-left: 6px; }
  .post-row:hover .post-row-title { color: var(--core); }
  .post-row-title { flex: 1; font-size: 1rem; font-weight: 500; transition: color 0.15s ease; }
  .empty { color: var(--ink-dim); padding: 20px 0; }

  .subscribe { padding: 0; margin: 0; }
  .subscribe-inner { padding: 36px 32px; }
  .subscribe h2 { font-size: 1.5rem; margin: 10px 0 10px; }
  .subscribe-form { display: flex; gap: 10px; margin-top: 22px; max-width: 440px; flex-wrap: wrap; }
  .subscribe-form input {
    flex: 1; min-width: 200px;
    background: var(--paper);
    border: 1px solid var(--rule);
    border-radius: 999px;
    padding: 11px 16px;
    font-family: var(--font-body);
  }
  .subscribe-form input:focus { outline: 2px solid var(--core); outline-offset: 1px; }
  .subscribe-form button {
    font-family: var(--font-mono); font-weight: 700;
    background: var(--core); color: var(--paper-raised);
    border: none; border-radius: 999px;
    padding: 11px 22px; cursor: pointer;
    transition: filter 0.15s ease, transform 0.2s ease;
  }
  .subscribe-form button:hover { filter: brightness(1.08); transform: translateY(-1px); }

  @media (max-width: 860px) {
    .sheet { padding: 32px 28px 40px; }
    .mast-nav { gap: 16px; flex-wrap: wrap; }
    .hero-art { margin-top: -30px; }
    .mag-grid { grid-template-columns: 1fr; }
  }
```

Nota: el ancho del SVG se controla con la prop `size` de HeroArt (default 300px); su CSS interno `.hero-art { max-width: 100% }` + `aspect-ratio` encoge la ilustración automáticamente en pantallas chicas, por eso el media query solo ajusta el margen negativo.

- [ ] **Step 4: Escribir el script de loader + reveal de líneas**

Agregar al final de `index.astro`:

```html
<script>
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const loader = document.querySelector('[data-loader]');
  const sheet = document.querySelector('[data-sheet]');
  const lines = document.querySelectorAll('.hl-line');

  function revealSheet() {
    if (loader) loader.classList.add('is-gone');
    if (sheet) sheet.classList.add('is-revealed');
    lines.forEach((line, i) => {
      setTimeout(() => line.classList.add('is-in'), 150 + i * 150);
    });
  }

  if (reduceMotion) {
    if (loader) loader.remove();
    if (sheet) sheet.classList.add('is-revealed');
    lines.forEach((line) => line.classList.add('is-in'));
  } else {
    setTimeout(revealSheet, 600);
  }
</script>
```

- [ ] **Step 5: Verificar build + preview visual**

Run: `npm run build`
Expected: exit 0.

Run: `npm run preview` (en otra terminal) y abrir `http://localhost:4321`:
- Loader aparece ~600ms y funde a la hoja.
- Headline revela 3 líneas con stagger.
- HeroArt se superpone con margen negativo, derecha.
- Masthead (fecha / nameplate / año / nav) correcto.
- Editorial en 2 columnas con lead-ins subrayados.
- Portada + Últimas + newsletter dentro de la hoja.
- Responsive en ~375px: sin desbordes, hero-art más chico, mag-grid 1 col.
- DevTools → Rendering → Emulate prefers-reduced-motion: sin loader, todo visible.

- [ ] **Step 6: Commit**

```bash
git add src/pages/index.astro
git commit -m "feat: rediseño del home como edición impresa estilo Daily Dispatch"
```

---

### Task 5: Verificación final y push a GitHub

**Files:**
- Verificación global del repo.

**Interfaces:**
- Consumes: las 4 tareas anteriores.
- Produces: repo `LeonardoPS1/iapo` en `main` con todo commiteado y pusheado; Dokploy auto-despliega `https://iapo.cl`.

- [ ] **Step 1: Build final limpio**

Run: `npm run build`
Expected: exit 0, sin warnings bloqueantes.

- [ ] **Step 2: Verificar estado de git**

Run: `git status`
Expected: working tree limpio (salvo nada). Confirmar los 4 commits de las tareas con `git log --oneline -5`.

- [ ] **Step 3: Push a GitHub**

```bash
git push origin main
```

Expected: push exitoso a `https://github.com/LeonardoPS1/iapo`.

- [ ] **Step 4: Confirmar deploy**

Esperar ~1-2 min y verificar `https://iapo.cl` responde 200 y muestra la edición impresa (loader → hoja).