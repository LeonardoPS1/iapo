# Home iapo.cl — Rediseño estilo "edición impresa" (referencia Daily Dispatch)

Fecha: 2026-08-15
Estado: Aprobado (secciones 1–3)

## Contexto

El index actual de iapo.cl usa un hero centrado ("Menos hype, más iapo"), tear-lines y
un mag-grid con post destacado + sidebar, todo sobre fondo papel frío (`--paper`).

Se rediseña **solo el index** replicando la estructura, proporciones y animaciones de
`https://www.dailydispatch.app/` (una landing de "diario impreso"): loader de entrada,
hoja de periódico centrada sobre fondo oscuro, masthead con fecha, headline gigante con
reveal por línea, ilustración en overlap y copy editorial en 2 columnas.

Se conserva la **identidad propia de iapo.cl** (paleta, wordmark, robot mascot, acentos
teal Aicore y rojo cómic). Se adopta la **tipografía del ejemplo**: Playfair Display
(display), Inter (body), JetBrains Mono (mono).

## Decisiones del usuario

- Nivel de fidelidad: **más fiel al ejemplo de Daily Dispatch** (encuadre, proporciones,
  animaciones), manteniendo identidad iapo en acentos y colores.
- Alcance: **solo el index**; las demás páginas no se tocan (solo heredan las fuentes nuevas).
- Loader de entrada: **sí, overlay fullscreen completo**.
- Ilustración hero: **nueva** (robot de iapo sosteniendo una tablet con un mini-mockup de la UI).
- Copy: mantener leitmotiv **"Menos hype, más iapo"** + copy editorial nuevo con tono periodístico.

## 1. Encuadre global

- Fondo de la página: tinta oscura (`--ink: #15171c`, no marrón), con la **hoja centrada**.
- Hoja de periódico: `--paper` (#edeee7), `max-width ≈ 820px`, `margin: 0 auto`, sombra suave
  y borde fino tipo papel impreso.
- Loader fullscreen: fondo tinta oscuro con el **wordmark de iapo centrado** → transición
  ~700ms → revela la hoja con animación de escala (`transform-origin: center`, ~0.96→1) + opacity.
- `prefers-reduced-motion: reduce`: sin loader, contenido visible directo.

## 2. Tipografía (global.css)

Swap en `:root`:

- `--font-display` / `--font-nameplate`: `'Playfair Display', serif`
- `--font-body`: `'Inter', ...` (sin cambio)
- `--font-mono`: `'JetBrains Mono', ...`

Import de Google Fonts actualizado. Las demás páginas solo cambian de fuente, sin cambios
de layout.

## 3. Estructura de la hoja (index.astro)

1. **Masthead**: fecha "EDICIÓN N°1 · AGO 2026" izquierda · nameplate **iapo** centrado
   (Playfair ~56px) · "20/26" derecha → separador punteado → nav (Blog · Prompts · Repos ·
   Casos · Sobre) en JetBrains Mono con underline animado.
2. **Headline**: 3 líneas gigantes en Playfair con reveal por línea y widths ~55–75%:
   - "Menos hype," (~62%)
   - "más iapo." (~50%, con "iapo" en rojo cómic)
   - "directo." (~45%)
3. **Ilustración hero** (nuevo `HeroArt.astro`): robot mascot de iapo sosteniendo una tablet
   con mini-mockup de la UI (masthead mini de iapo). Overlap sobre el texto con margen
   negativo (`-mt-[19%]` aprox), borde derecho, `z-10`. Animaciones blink/wobble del mascot
   + float sutil.
4. **Copy editorial**: h3 serif "IA aplicada, sin traducciones genéricas." + grid 2 columnas
   de párrafos con lead-ins subrayados (teal/ink): "Automatización real.", "Salud primero.",
   "Probado antes de recomendar.".
5. **CTAs**: "Suscribirme" (teal, `--core`) + "Ver el blog →" (ghost), bajo el copy.
6. **Contenido del diario** (dentro de la misma hoja):
   - **Portada**: post destacado (`featured`) como artículo de portada.
   - **Últimas**: lista numerada (reutiliza `Sidebar.astro` o su patrón).
   - **Cupón/contraportada**: caja de suscripción con el form de newsletter existente
     (`https://newsletter.iapo.cl/subscription/form`).

## 4. Animaciones

- Loader + entrada de la hoja (sección 1).
- Headline reveal por línea: cada línea `visibility:hidden` → visible con stagger ~150ms.
- Scroll reveals: `[data-reveal]` existente para Portada, Últimas, newsletter (stagger 60ms).
- Mascot: blink/wobble existentes + float sutil en HeroArt.
- Todo respeta `prefers-reduced-motion: reduce`.

## 5. Técnica

- La hoja + loader viven en `src/pages/index.astro` con `<style>` scoped y `<script>` local.
- `src/styles/global.css`: solo swap de fuentes + tokens necesarios.
- Nueva ilustración: `src/components/HeroArt.astro` (SVG inline, mismo patrón que `Mascot.astro`).
- Data intacta: `getCollection('blog', !draft)`, `featured` = primer post, `pilarLabel` map,
  form newsletter igual.
- Componentes no usados (CoastalArt, NeuralCore, etc.) no se tocan.
- Se mantiene el Header/Footer actuales? → El index pasa a tener su propio masthead dentro de
  la hoja; el Footer/Header globales de `Base.astro` se evalúan durante implementación (el
  index puede no usar el Header global y reemplazarlo por el masthead de la hoja).

## 6. Verificación

- `npm run build` sin errores.
- `npm run preview` visual: loader → hoja, headline reveal, overlap, responsive 320/768/1024.
- `prefers-reduced-motion` activo: sin loader, contenido visible.
- Deploy: commit + push a GitHub (repo `LeonardoPS1/iapo`, branch `main`) → Dokploy auto-deploy.

## Fuera de alcance (YAGNI)

- No rediseñar blog/prompts/repos/casos/sobre.
- No cambiar contenido de posts ni schema.
- No agregar RSS/sitemap/favicon (pendientes conocidos, fuera de este trabajo).