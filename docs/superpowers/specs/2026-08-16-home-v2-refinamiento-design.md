# Home iapo.cl v2 — Refinamiento editorial, sin robot, ilustraciones por pilar

Fecha: 2026-08-16
Estado: Aprobado (secciones 1–4)

## Contexto

El rediseño v1 del home (edición impresa estilo Daily Dispatch) está en producción
(HEAD `a4ad893`, deploy automático por GitHub Actions + SSH). Este rediseño v2 refina:

1. Quitar el robot SVG del hero (`HeroArt.astro`).
2. Mejorar el copy del hero y del editorial.
3. Arreglar la sección editorial "IA aplicada, sin traducciones genéricas" — hoy se ve
   mal alineada y no sigue un patrón de diseño.
4. Ser más fiel a la página de ejemplo `https://www.dailydispatch.app/?ref=onepagelove`.
5. Usar imágenes del mismo estilo del ejemplo (vectorial flat) en el home y en las
   entradas del blog.

## Decisiones del usuario

- Hero: **ilustración nueva sin robot** — una tablet/diario abierto con la UI de iapo.cl.
- Blog: **ilustraciones SVG por pilar** (estilo flat del ejemplo, paleta iapo, sin
  dependencias externas ni generación IA).
- Editorial: **replicar el patrón del ejemplo** — h3 serif + grid 2 columnas de párrafos
  con lead-in subrayado en negrita, sin números ni labels, parejo.
- Alcance de imágenes: **home + blog completo** (listado y artículos).
- Mantener el encuadre v1: fondo tinta oscuro + hoja centrada + loader + masthead +
  reveal por línea. Identidad iapo: paleta, wordmark, acentos teal/rojo cómic.

## 1. Hero y copy

- Eliminar `HeroArt.astro` y su uso en `index.astro`.
- Nuevo componente `DispatchArt.astro` (SVG inline, estilo flat del ejemplo): tablet/diario
  abierto con mini-mockup de la UI de iapo.cl (mini-masthead: wordmark + regla punteada,
  titular corto, botón), sombra de imprenta, en overlap sobre el headline (z-10, margen
  negativo). Rol visual equivalente al robot del ejemplo, sin robot. Hereda float sutil
  de HeroArt (blink/wobble/float) gated por `prefers-reduced-motion`.
- Headline: mantener reveal por línea en 3 líneas ("Menos hype," / "más iapo." /
  "directo.") con `hl-accent` rojo cómic; ajustar widths/peso para que el overlap respire.
- Agregar un deck periodístico de 1-2 líneas bajo el headline (hoy no existe):
  "Tips, prompts y skills de IA aplicada, probados en negocios reales. Desde Chile."

## 2. Editorial (patrón del ejemplo) + copy

Reemplazar el editorial v1 por el patrón del ejemplo:

- h3 serif "IA aplicada, sin traducciones genéricas."
- Grid 2 columnas de párrafos; cada párrafo con **lead-in subrayado en negrita**
  (`<span class="underline font-medium">`), sin números, sin labels. Los 3 párrafos
  ocupan el grid parejo (el tercero ya NO abarca `grid-column: 1/-1`).
- Copy mejorado:
  1. **Automatización real.** *Herramientas que corremos en negocios reales — no demos.
     Cada workflow se explica paso a paso, con código, capturas y casos.*
  2. **Salud primero.** *IA aplicada a clínicas y consultorios: menos carga administrativa,
     más tiempo para pacientes. Sin inventos, sin promesas de otro planeta.*
  3. **Probado antes de recomendar.** *Cada skill, prompt y repo que publicamos pasó por
     pruebas reales antes de llegar a esta hoja.*

## 3. Sistema de ilustraciones del blog

Nuevo componente `PilarArt.astro` (SVG inline, estilo flat, paleta iapo). Un solo
componente con prop `pilar: 'salud' | 'automatizacion' | 'ia-general'` y 3 motivos:

- `salud` → cruz + corazón + pulso (teal `--salud` #2f8f5b)
- `automatizacion` → engranaje + nodos + flechas de flujo (rojo cómic `--automatizacion` #e6432a)
- `ia-general` → red neuronal / ondas (púrpura `--ia-general` #7454d1)

Uso (home + blog completo):
- Home: thumbnail del post destacado (Portada) y de los posts de la lista.
- `blog/index.astro`: tarjeta de cada post con su ilustración de pilar.
- `blog/[id].astro`: ilustración del pilar al inicio del artículo.

El schema del blog ya tiene `pilar` — no se toca `content.config.ts`.

## 4. Técnica y alcance

Archivos:
- `src/pages/index.astro` — quitar HeroArt, agregar DispatchArt, refinar hero/headline,
  reemplazar editorial por patrón del ejemplo, thumbnails PilarArt en Portada y lista.
- `src/components/DispatchArt.astro` — NUEVO.
- `src/components/PilarArt.astro` — NUEVO.
- `src/components/HeroArt.astro` — ELIMINAR (y sus referencias).
- `src/pages/blog/index.astro` — thumbnails PilarArt en cada tarjeta.
- `src/pages/blog/[id].astro` — PilarArt al inicio del artículo.
- `src/styles/global.css` — solo si hace falta un token/utilidad compartida (opcional).

Data intacta: `getCollection`, `featured`, `pilarLabel`, `dateFmt`, form newsletter,
masthead/nav. Animaciones v1 (loader, reveal por línea, scroll reveals) se mantienen.

## Verificación

- `npm run build` exit 0.
- Push a GitHub main → workflow 3 jobs (build + GHCR + deploy SSH) → https://iapo.cl 200.
- Visual (preview/manual): hero con DispatchArt en overlap, editorial parejo 2 col,
  thumbnails por pilar en home + blog.

## Fuera de alcance (YAGNI)

- No cambiar schema ni contenido de posts.
- No tocar layout de otras páginas (prompts, repos, casos, sobre).
- No agregar dependencias ni generación de imágenes.