# Home v2 Refinamiento iapo.cl Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Quitar el robot del hero, reemplazarlo por una ilustración de tablet/diario con la UI, crear ilustraciones SVG por pilar para home y blog, y refinar el copy/editorial para replicar el patrón de dailydispatch.app.

**Architecture:** El index y las páginas de blog son páginas Astro SSR/SSG estáticas que importan componentes SVG inline (`DispatchArt.astro` para el hero, `PilarArt.astro` para thumbnails por pilar). Se elimina `HeroArt.astro`. El copy editorial se reemplaza por el patrón del ejemplo (h3 serif + grid 2 cols con lead-in subrayado en negrita, sin números ni labels).

**Tech Stack:** Astro 7, CSS scoped en cada componente, SVG inline, tokens CSS existentes en `global.css`.

## Global Constraints

- `npm run build` debe dar exit 0 (no hay test runner; el build es la verificación).
- Commit mensajes en español, estilo repo (`feat:`, `style:`, `docs:`).
- No agregar comentarios de código nuevos salvo los marcadores SVG planificados en los componentes nuevos.
- Respetar `prefers-reduced-motion: reduce` en toda animación nueva.
- Los tokens de color provienen de `global.css` (`--salud`, `--automatizacion`, `--ia-general`, `--core`, `--comic-red`, `--paper`, `--paper-raised`, `--ink`, `--ink-dim`, `--ink-faint`, `--rule`).
- `content.config.ts` NO se toca (el schema ya tiene `pilar`).
- Push a main dispara el workflow 3 jobs (build + GHCR + deploy SSH) — solo el commit final del plan debe hacer push (o dejarlo en manos del usuario si se prefiere).

---

### Task 1: Componente DispatchArt.astro (ilustración hero sin robot)

**Files:**
- Create: `src/components/DispatchArt.astro`
- Test: `npm run build`

**Interfaces:**
- Consumes: tokens CSS de `global.css`; prop `size` (opcional, default 340).
- Produces: componente `DispatchArt` con props `{ size?: number }`, wrapper `<div class="dispatch-art">`, clases de animación `da-*`.

- [ ] **Step 1: Escribir el componente**

Crear `src/components/DispatchArt.astro`:

```astro
---
interface Props {
  size?: number;
}
const { size = 340 } = Astro.props;
---
<div class="dispatch-art" style={`width:${size}px`} aria-hidden="true">
  <svg viewBox="0 0 260 220" xmlns="http://www.w3.org/2000/svg">
    <!-- sombra de imprenta -->
    <rect x="18" y="22" width="224" height="176" rx="10" fill="var(--ink)" opacity="0.16" />
    <!-- tablet / diario abierto -->
    <g class="da-tablet">
      <rect x="10" y="10" width="224" height="176" rx="10" fill="var(--paper-raised)" stroke="var(--ink)" stroke-width="4" />
      <!-- bisagra central -->
      <line x1="122" y1="10" x2="122" y2="186" stroke="var(--rule)" stroke-width="2" />
      <!-- página izquierda: mini-masthead -->
      <rect x="24" y="26" width="86" height="146" rx="4" fill="var(--paper)" stroke="var(--rule)" stroke-width="1.5" />
      <circle cx="52" cy="44" r="6" fill="var(--comic-red)" />
      <rect x="66" y="40" width="34" height="8" rx="2" fill="var(--ink)" />
      <line x1="24" y1="60" x2="110" y2="60" stroke="var(--ink-faint)" stroke-width="1.5" stroke-dasharray="3 4" />
      <rect x="30" y="72" width="70" height="7" rx="2" fill="var(--ink)" opacity="0.85" />
      <rect x="30" y="84" width="52" height="7" rx="2" fill="var(--ink)" opacity="0.6" />
      <rect x="30" y="100" width="66" height="26" rx="3" fill="var(--paper-raised)" stroke="var(--rule)" stroke-width="1.5" />
      <rect x="36" y="112" width="28" height="6" rx="2" fill="var(--core)" />
      <rect x="30" y="134" width="58" height="5" rx="2" fill="var(--ink-faint)" />
      <rect x="30" y="143" width="44" height="5" rx="2" fill="var(--ink-faint)" />
      <!-- página derecha: regla + titular -->
      <rect x="150" y="26" width="86" height="146" rx="4" fill="var(--paper)" stroke="var(--rule)" stroke-width="1.5" />
      <rect x="158" y="36" width="56" height="30" rx="3" fill="var(--core)" opacity="0.12" />
      <rect x="158" y="42" width="44" height="6" rx="2" fill="var(--core)" />
      <rect x="158" y="52" width="30" height="6" rx="2" fill="var(--core)" />
      <line x1="150" y1="76" x2="236" y2="76" stroke="var(--ink-faint)" stroke-width="1.5" stroke-dasharray="3 4" />
      <rect x="158" y="88" width="66" height="7" rx="2" fill="var(--ink)" opacity="0.85" />
      <rect x="158" y="100" width="48" height="7" rx="2" fill="var(--ink)" opacity="0.6" />
      <rect x="158" y="112" width="58" height="5" rx="2" fill="var(--ink-faint)" />
      <rect x="158" y="121" width="50" height="5" rx="2" fill="var(--ink-faint)" />
      <rect x="158" y="130" width="54" height="5" rx="2" fill="var(--ink-faint)" />
      <!-- botón CTA en página derecha -->
      <rect x="158" y="146" width="52" height="16" rx="8" fill="var(--comic-red)" />
    </g>
  </svg>
</div>

<style>
  .dispatch-art {
    max-width: 100%;
    aspect-ratio: 260 / 220;
  }
  .dispatch-art svg { width: 100%; height: 100%; display: block; overflow: visible; }
  .da-tablet {
    transform-box: fill-box;
    transform-origin: center;
  }
  @media (prefers-reduced-motion: no-preference) {
    .da-tablet { animation: da-wobble 3.4s ease-in-out infinite; }
    .dispatch-art { animation: da-float 5.5s ease-in-out infinite; }
  }
  @keyframes da-wobble {
    0%, 100% { transform: rotate(0deg); }
    50% { transform: rotate(-2deg); }
  }
  @keyframes da-float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-6px); }
  }
</style>
```

- [ ] **Step 2: Verificar build**

Run: `npm run build`
Expected: exit 0, sin errores.

- [ ] **Step 3: Commit**

```bash
git add src/components/DispatchArt.astro
git commit -m "feat: componente DispatchArt con tablet y mini-mockup de la UI"
```

---

### Task 2: Componente PilarArt.astro (ilustración SVG por pilar)

**Files:**
- Create: `src/components/PilarArt.astro`
- Test: `npm run build`

**Interfaces:**
- Consumes: tokens CSS de `global.css`.
- Produces: componente `PilarArt` con props `{ pilar: 'salud' | 'automatizacion' | 'ia-general'; size?: number }`. Clases `pa-*`. Es el thumbnail que se muestra en home (featured + more-list) y en las post-cards del blog.

- [ ] **Step 1: Escribir el componente**

Crear `src/components/PilarArt.astro`:

```astro
---
interface Props {
  pilar: 'salud' | 'automatizacion' | 'ia-general';
  size?: number;
}
const { pilar, size = 120 } = Astro.props;
---
<div class="pilar-art" style={`width:${size}px`} data-pilar={pilar} aria-hidden="true">
  <svg viewBox="0 0 120 90" xmlns="http://www.w3.org/2000/svg">
    {pilar === 'salud' && (
      <>
        <!-- cruz médica -->
        <rect x="28" y="24" width="8" height="34" rx="2" fill="var(--salud)" />
        <rect x="16" y="36" width="32" height="8" rx="2" fill="var(--salud)" />
        <!-- latido -->
        <path d="M6 58 h18 l8 -14 10 22 8 -12 10 4 h20" stroke="var(--salud)" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
        <!-- corazón -->
        <path d="M104 46 c-3 -4 -9 -3 -9 2 0 3 4 5 9 8 5 -3 9 -5 9 -8 0 -5 -6 -6 -9 -2 z" fill="var(--salud)" />
      </>
    )}
    {pilar === 'automatizacion' && (
      <>
        <!-- engranaje -->
        <g class="pa-gear">
          <circle cx="44" cy="44" r="14" fill="none" stroke="var(--automatizacion)" stroke-width="6" />
          <path d="M44 12 v10 M44 66 v10 M12 44 h10 M66 44 h10 M21 21 l7 7 M60 60 l7 7 M21 67 l7 -7 M60 30 l7 -7" stroke="var(--automatizacion)" stroke-width="6" stroke-linecap="round" />
        </g>
        <!-- nodos y flechas -->
        <circle cx="92" cy="24" r="8" fill="var(--automatizacion)" />
        <circle cx="92" cy="66" r="8" fill="none" stroke="var(--automatizacion)" stroke-width="4" />
        <path d="M84 30 l-14 12 M84 60 l-14 -12" stroke="var(--automatizacion)" stroke-width="3" stroke-linecap="round" />
      </>
    )}
    {pilar === 'ia-general' && (
      <>
        <!-- red neuronal -->
        <g class="pa-net">
          <circle cx="24" cy="22" r="6" fill="var(--ia-general)" />
          <circle cx="52" cy="16" r="6" fill="var(--ia-general)" />
          <circle cx="80" cy="22" r="6" fill="var(--ia-general)" />
          <circle cx="36" cy="46" r="6" fill="var(--ia-general)" />
          <circle cx="66" cy="46" r="6" fill="var(--ia-general)" />
          <circle cx="24" cy="70" r="6" fill="var(--ia-general)" />
          <circle cx="56" cy="72" r="6" fill="var(--ia-general)" />
          <circle cx="86" cy="66" r="6" fill="var(--ia-general)" />
          <path d="M24 22 L36 46 M52 16 L36 46 L66 46 M80 22 L66 46 M36 46 L24 70 L56 72 M66 46 L86 66 M24 70 L56 72 M56 72 L86 66" stroke="var(--ia-general)" stroke-width="2.5" fill="none" />
        </g>
      </>
    )}
  </svg>
</div>

<style>
  .pilar-art { display: block; max-width: 100%; }
  .pilar-art svg { width: 100%; height: 100%; display: block; }
  .pa-gear, .pa-net {
    transform-box: fill-box;
    transform-origin: center;
  }
  @media (prefers-reduced-motion: no-preference) {
    .pa-gear { animation: pa-spin 10s linear infinite; }
    .pa-net { animation: pa-pulse 3.2s ease-in-out infinite; }
  }
  @keyframes pa-spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }
  @keyframes pa-pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.55; }
  }
</style>
```

- [ ] **Step 2: Verificar build**

Run: `npm run build`
Expected: exit 0, sin errores.

- [ ] **Step 3: Commit**

```bash
git add src/components/PilarArt.astro
git commit -m "feat: componente PilarArt con ilustración SVG por pilar"
```

---

### Task 3: Index — quitar HeroArt, agregar DispatchArt y nuevo copy editorial

**Files:**
- Modify: `src/pages/index.astro`
- Delete: `src/components/HeroArt.astro`
- Test: `npm run build`

**Interfaces:**
- Consumes: `DispatchArt` (Task 1), `PilarArt` (Task 2), `Wordmark`, `Sidebar`, `getCollection`, tokens CSS.
- Produces: index con editorial al patrón del ejemplo (3 párrafos con `.ed-lead` subrayado, 2 cols, sin `grid-column: 1/-1`), deck periodístico bajo el headline, thumbnails `PilarArt` en featured y more-list.

- [ ] **Step 1: Actualizar frontmatter**

En `src/pages/index.astro`, reemplazar el import `HeroArt` por:

```astro
import DispatchArt from '../components/DispatchArt.astro';
import PilarArt from '../components/PilarArt.astro';
```

- [ ] **Step 2: Reemplazar el hero-art**

Reemplazar:

```astro
      <div class="hero-art">
        <HeroArt size={300} />
      </div>
```

por:

```astro
      <div class="hero-art">
        <DispatchArt size={340} />
      </div>
```

- [ ] **Step 3: Agregar deck y refinar headline**

Inmediatamente después de `</h1>` (cierre del hero-h1), agregar:

```astro
      <p class="hero-deck">Tips, prompts y skills de IA aplicada, probados en negocios reales. Desde Chile.</p>
```

- [ ] **Step 4: Reemplazar el editorial**

Reemplazar TODO el bloque `<section class="editorial">...</section>` por:

```astro
    <section class="editorial">
      <h3 class="ed-h3">IA aplicada, sin traducciones genéricas.</h3>
      <div class="ed-grid">
        <p><span class="ed-lead">Automatización real.</span> Herramientas que corremos en negocios reales — no demos. Cada workflow se explica paso a paso, con código, capturas y casos.</p>
        <p><span class="ed-lead">Salud primero.</span> IA aplicada a clínicas y consultorios: menos carga administrativa, más tiempo para pacientes. Sin inventos, sin promesas de otro planeta.</p>
        <p><span class="ed-lead">Probado antes de recomendar.</span> Cada skill, prompt y repo que publicamos pasó por pruebas reales antes de llegar a esta hoja.</p>
      </div>
      <div class="hero-actions">
        <a class="btn" href="#suscribir">Suscribirme</a>
        <a class="btn btn-ghost" href="/blog">Ver todo el blog →</a>
      </div>
    </section>
```

- [ ] **Step 5: Agregar PilarArt al featured**

En el bloque `{featured && (...)}`, agregar el thumbnail dentro del panel, justo después de `<div class="featured-meta">`:

```astro
            <div class="featured-art"><PilarArt pilar={featured.data.pilar} size={110} /></div>
```

- [ ] **Step 6: Agregar PilarArt a las post-rows**

En el bloque `{rest.map((post) => (...))}`, agregar el thumbnail antes del `<span class="tag" ...>`:

```astro
              <span class="post-row-art"><PilarArt pilar={post.data.pilar} size={40} /></span>
```

- [ ] **Step 7: Estilos — deck, editorial parejo, featured-art, post-row-art**

En el `<style>` scoped, agregar después de la regla `.hero-art`:

```css
  .hero-deck {
    max-width: 52ch;
    margin: 18px 0 0;
    color: var(--ink-dim);
    font-size: 1.05rem;
    line-height: 1.55;
  }
```

Reemplazar la regla existente:

```css
  .ed-grid p:last-child { grid-column: 1 / -1; }
```

por nada (eliminarla) — los 3 párrafos quedan parejos en 2 columnas.

Agregar:

```css
  .featured-art { margin: 0 0 16px; }
  .post-row-art { flex-shrink: 0; display: flex; align-items: center; }
```

- [ ] **Step 8: Eliminar HeroArt.astro**

```bash
git rm src/components/HeroArt.astro
```

- [ ] **Step 9: Verificar build**

Run: `npm run build`
Expected: exit 0, sin errores, 7 páginas.

- [ ] **Step 10: Commit**

```bash
git add src/pages/index.astro src/components/HeroArt.astro
git commit -m "feat: home sin robot, ilustración tablet, nuevo copy editorial y thumbnails por pilar"
```

---

### Task 4: Blog index — thumbnails PilarArt en post-cards

**Files:**
- Modify: `src/pages/blog/index.astro`
- Test: `npm run build`

**Interfaces:**
- Consumes: `PilarArt` (Task 2), `Sidebar`, `getCollection`.
- Produces: cada post-card muestra su ilustración por pilar.

- [ ] **Step 1: Agregar import**

En `src/pages/blog/index.astro`, agregar al frontmatter:

```astro
import PilarArt from '../../components/PilarArt.astro';
```

- [ ] **Step 2: Agregar thumbnail al post-card**

Dentro de `<a ... class="post-card panel" data-reveal>`, justo después de la etiqueta de apertura, agregar:

```astro
            <div class="post-art"><PilarArt pilar={post.data.pilar} size={96} /></div>
```

- [ ] **Step 3: Estilos**

En el `<style>` scoped, agregar:

```css
  .post-art { margin: 0 0 14px; display: flex; }
```

- [ ] **Step 4: Verificar build**

Run: `npm run build`
Expected: exit 0, sin errores.

- [ ] **Step 5: Commit**

```bash
git add src/pages/blog/index.astro
git commit -m "feat: ilustraciones por pilar en las tarjetas del blog"
```

---

### Task 5: Post layout — PilarArt en el artículo

**Files:**
- Modify: `src/layouts/Post.astro`
- Test: `npm run build`

**Interfaces:**
- Consumes: `PilarArt` (Task 2), prop `pilar` del layout, `Sidebar`.
- Produces: el encabezado del artículo muestra la ilustración del pilar correspondiente.

- [ ] **Step 1: Agregar import**

En `src/layouts/Post.astro`, agregar al frontmatter:

```astro
import PilarArt from '../components/PilarArt.astro';
```

- [ ] **Step 2: Agregar ilustración en el encabezado**

Dentro de `<article class="post">`, después de `<div class="post-meta">...</div>` y antes de `<h1>{title}</h1>`, agregar:

```astro
        <div class="post-art"><PilarArt pilar={pilar} size={140} /></div>
```

- [ ] **Step 3: Estilos**

En el `<style>` scoped, agregar:

```css
  .post-art { margin: 0 0 18px; display: flex; }
```

- [ ] **Step 4: Verificar build**

Run: `npm run build`
Expected: exit 0, sin errores.

- [ ] **Step 5: Commit**

```bash
git add src/layouts/Post.astro
git commit -m "feat: ilustración por pilar en el encabezado del artículo"
```

---

### Task 6: Verificación final y push

**Files:**
- Test: `npm run build`

**Interfaces:**
- Consumes: todo lo anterior.

- [ ] **Step 1: Build final**

Run: `npm run build`
Expected: exit 0, sin errores.

- [ ] **Step 2: Revisar git status**

Run: `git status`
Expected: solo los cambios de los Tasks 1-5, sin archivos no relacionados (nota: `docs/superpowers/specs/2026-08-16-home-v2-refinamiento-design.pdf` y `docs/superpowers/plans/2026-08-16-github-actions-cicd.md` quedan untracked — no se commitean).

- [ ] **Step 3: Push**

Run: `git push origin main`
Expected: push OK. Dispara workflow GitHub Actions (build + GHCR + deploy SSH). Verificar https://iapo.cl responde 200 tras ~3-5 min.

- [ ] **Step 4: Actualizar memoria de proyecto (solo si se hizo push)**

Actualizar el bloque `project` con el nuevo HEAD y notas de componentes (DispatchArt/PilarArt, HeroArt eliminado).