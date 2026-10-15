# iapo.cl

Sitio de contenido de Aicore Agency: tips, prompts, skills y repos de IA aplicada,
con foco en automatización y salud digital en Chile.

Es un sitio **estático** (Astro SSG, `output: 'static'`) que se sirve desde un
contenedor `nginx:alpine` en el VPS de Aicore, con Cloudflare adelante. Sin backend,
sin base de datos y sin proceso propio corriendo: el contenido es Markdown validado
en el build.

## Desarrollo local

```bash
npm install
npm run dev       # http://localhost:4321
npm run build     # genera dist/ y corre el postbuild (sitemap + llms-full.txt)
npm run preview   # sirve dist/ tal cual, para revisar antes de pushear
```

No hay test runner. La verificación es que `npm run build` termine con **código 0** y
que la lista de páginas que imprime incluya la que tocaste (el proyecto está en 22).
Si el contenido no valida, el build falla ahí y no en producción.

## Qué se publica dónde

| Contenido | Archivo | URL |
|---|---|---|
| Artículo de blog | `src/content/blog/<slug>.md` | `/blog/<slug>` |
| Nota Extra («Último momento») | `src/content/extra/<slug>.md` | `/extra/<slug>` |
| Edición del ranking | `src/content/rankings/ranking-<fecha>.md` | `/rankings/ranking-<fecha>` |

Las tres colecciones se validan contra el schema de `src/content.config.ts`: si a un
archivo le falta un campo obligatorio, el build se corta con el error a la vista.

## Escribir un artículo (blog)

1. Creá `src/content/blog/mi-slug.md`. El slug del archivo define la URL: `/blog/mi-slug`.
2. Frontmatter:

```yaml
---
title: "Título del artículo"
description: "Bajada de 1-2 líneas, aparece en el listado y en meta description."
pubDate: 2026-08-21
pilar: "salud" | "automatizacion" | "ia-general"
tags: ["whatsapp", "n8n"]
draft: false   # true lo oculta de listados y del build de producción
---
```

3. El cuerpo va en Markdown. El layout `Post.astro` dibuja solo el schema
   `BlogPosting`, los artículos relacionados y la lista de enlaces al pie.

## Escribir una nota Extra ("Último momento")

Las notas **Extra** son las urgencias/novedades que se publican sin esperar al
calendario editorial del blog. Viven en su propia sección (`/extra`) y son la
**única** sección del sitio con comentarios.

1. Creá `src/content/extra/mi-slug.md` (mismo slug para el archivo y para la URL).
   La URL queda como `/extra/mi-slug`.
2. Frontmatter:

```yaml
---
title: "Título completo de la nota, el que aparece en la página y en el <title>"
headline: "Titular corto y grande del diario flotante (máx. unas 60 letras)"
intro: "1 o 2 frases de bajada para el diario flotante de la home."
description: "Meta description para buscadores y vistas previas."
pubDate: 2026-10-14
featured: true    # true = candidata a salir en el diario flotante de la home
draft: false      # true la oculta de listados y del build de producción
sources:
  - label: "Título del enlace o de la fuente"
    url: "https://ejemplo.com/nota"
---
```

3. `title`, `headline` e `intro` cumplen funciones distintas y las tres son
   obligatorias: el layout las usa en lugares diferentes (`headline` es el texto
   grande del diario, `intro` la bajada, `title` el encabezado de la página). El
   array `sources` alimenta el bloque "Fuentes y enlaces" al pie de la nota.
4. El cuerpo va en Markdown, igual que en el blog. Los enlaces externos abren en
   pestaña nueva automáticamente (`target="_blank"` + `rel="noopener noreferrer"`
   los agrega un script de la página); no hay que agregarles nada.
5. `featured: true` marca la nota como **candidata** al diario flotante de la home:
   ese diario muestra la nota featured más reciente. Si hay varias, gana la de
   `pubDate` mayor. Poner `featured: false` retira la nota del diario **sin**
   sacarla de `/extra`.
6. El diario flotante aparece ~1,2 s después de cargar la home, se puede cerrar con
   la ×, y no vuelve a aparecer en ese navegador (se recuerda en `localStorage` bajo
   la clave `iapo:extra-dismissed:<slug>`). Para volver a verlo, borrá esa clave
   desde las DevTools.

Los comentarios se cargan **solo** en `/extra/<slug>`, nunca en el blog ni en la
home (ver "Comentarios" abajo).

## Ranking semanal (lo publica un agente)

`/rankings` y sus ediciones **no se escriben a mano**: las publica un agente de IA
que corre solo, una vez por semana, dentro del VPS.

| Pieza | Dónde |
|---|---|
| Definición del agente | `.opencode/agent/weekly-ranking.md` |
| Runner, timer e instalación | `ops/weekly-ranking/` |
| Estado de la última corrida | `/estado` (noindex, sin link en el footer) |
| Detalle de una falla, sin SSH | workflow **Diagnóstico agente VPS** |

Si la última corrida falla, o pasaron más de 8 días, `/estado` lo publica: es la
primera parada antes de entrar por SSH. El detalle completo del sistema (bootstrap,
permisos, parámetros, cómo forzar una corrida) está en `ops/weekly-ranking/README.md`.

> **Ojo al pushear**: el agente commitea y pushea directo a `main` cada domingo. Hacé
> `git fetch origin` antes de pushear — si no, estás trabajando sobre una referencia
> vieja y el push te lo rechaza.

## Comentarios (Giscus)

Los comentarios viven en GitHub Discussions, vía [Giscus](https://giscus.app), y se
muestran **solo** en `/extra/<slug>`. El componente
`src/components/GiscusComments.astro` tiene dos constantes sin completar
(`REEMPLAZAR_REPO_ID` y `REEMPLAZAR_CATEGORY_ID`) y, mientras estén así, muestra el
aviso "Los comentarios se activan muy pronto." en vez de cargar el iframe.

Para activarlos, en el repo `LeonardoPS1/iapo`:

| Paso | Dónde |
|---|---|
| 1. Habilitar **Discussions** | Settings → General → Features |
| 2. Crear la categoría `Extra` (tipo **Announcements**) | pestaña Discussions → ⚙️ → New category |
| 3. Instalar la app de giscus **en este repo** | <https://github.com/apps/giscus> |
| 4. Pegar los dos IDs en las constantes del componente | `src/components/GiscusComments.astro` (líneas 5 y 7) |

El `data-repo-id` de este repo es `R_kgDOT4YBlA`. El `data-category-id` (`DIC_kwDO…`)
se obtiene de <https://giscus.app> —o por GraphQL, `repository { discussionCategories }`—
una vez que la categoría existe. Cuando las dos constantes están completas,
`configured` pasa a `true` y el iframe se carga solo: no hace falta ningún cambio de
build ni variable de entorno.

Nada de esto se puede automatizar: habilitar Discussions requiere el permiso
`administration: write` sobre el repo, y la API de GitHub **no expone** ni mutación
para crear categorías de Discussion ni forma de instalar una app. Son los tres pasos
de UI, una sola vez.

Con `data-mapping="pathname"` cada nota tiene su propio hilo, y el bot de giscus lo
crea la primera vez que alguien comenta. El repo tiene que ser público y la app tener
acceso, si no el iframe carga vacío.

## Newsletter

El boletín se maneja con **Brevo** (no hay servicio propio). La home tiene el
formulario embebido en `#suscribir` (`src/pages/index.astro`): un iframe a
`db52c710.sibforms.com`.

El script `initSubscribeRef()` le agrega `?ref=` a ese iframe para saber desde qué
página se suscribió la persona: usa el `?ref=` de la URL y, si no hay, el
`document.referrer` interno (y si no, `directo`). Es solo atribución — sin JS el
formulario funciona igual.

El ancla `/#suscribir` es el destino de todos los CTA del sitio: el botón de la home,
el pie del layout de ranking y el cierre de los artículos del blog.

## Deploy

Push a `main` dispara `.github/workflows/deploy.yml`. No hay deploy manual:

1. **Build** — `npm ci` + `npm run build` en GitHub Actions. Si el contenido está
   roto, el pipeline se corta acá y el sitio sigue sirviendo la versión anterior.
2. **Push image to GHCR** — publica `ghcr.io/leonardops1/iapo:latest` y `:sha-<sha>`.
3. **Deploy to VPS (Dokploy)** — por SSH a `ubuntu@51.222.207.250` con el secret
   `VPS_SSH_KEY`: `git pull` en `/etc/dokploy/applications/iapo-iapo-srsxbv/code`,
   `docker build` y `docker service update --force iapo-iapo-srsxbv` (Swarm).

El sitio lo sirve un contenedor `nginx:alpine` (`Dockerfile` + `nginx.conf`: cache de
7 días para assets, gzip, `try_files` para las rutas sin `.html`), con Cloudflare
adelante para HTTPS.

`deploy.sh` y `docker-compose.yml` son del flujo viejo (crear la app a mano en la UI
de Dokploy) y ya no se usan: quedan como referencia.

## SEO y contenido para LLMs

Todo sale del build, sin servicio externo:

| Archivo | Qué hace |
|---|---|
| `astro.config.mjs` (`@astrojs/sitemap`) | `sitemap-index.xml` + `sitemap-0.xml` |
| `scripts/update-sitemap-lastmod.mjs` | corrige el `lastmod` de los posts y del índice |
| `scripts/generate-llms-full.mjs` | arma `dist/llms-full.txt` (blog + prompts) |
| `public/robots.txt` | permite explícitamente los crawlers de IA y apunta al sitemap |
| `public/llms.txt` | índice curado del sitio para asistentes |
| `src/components/BaseHead.astro` | canonical, Open Graph/Twitter, JSON-LD, preloads |

Todas las fechas se formatean con `timeZone: 'UTC'`: la fecha de un content
collection es un día, no un instante, y sin eso el día se corre para atrás en Chile.

### Legal y analítica

`/aviso-legal`, `/privacidad` y `/terminos`, enlazadas desde el footer. Declaran la
Ley 19.628 de Chile, Brevo para el boletín y la analítica de Cloudflare (agregada, sin
cookies y sin IP). El beacon de Cloudflare Web Analytics lo inyecta Cloudflare en el
borde: no está en el repo.

## Estructura

```
src/
  content/blog/        artículos en Markdown (lo que se edita día a día)
  content/extra/       notas "Último momento" en Markdown (mismo patrón)
  content/rankings/    ediciones del ranking (las genera el agente semanal)
  content.config.ts    schema de las tres colecciones
  data/agent-status.json   estado de la última corrida del agente (lo escribe el runner)
  layouts/             Base.astro (shell), Post.astro (artículo), Ranking.astro
  components/          Header, Footer, Sidebar, BaseHead, ExtraFlash, GiscusComments,
                       InkCursor, Wordmark y arte (Mascot, CoastalArt, ...), rank/
  styles/global.css    tokens de diseño (colores, tipografías, easings, duraciones)
  pages/
    index.astro          home (variant="sheet": arma su propio masthead y nav)
    blog/index.astro     listado
    blog/[id].astro      artículo
    extra/index.astro    listado de notas Extra
    extra/[id].astro     nota Extra (la única ruta con comentarios)
    rankings/index.astro listado de rankings
    rankings/[id].astro  edición del ranking
    prompts.astro        directorio de prompts (contenido inline por ahora)
    repos.astro          curaduría de repos (contenido inline por ahora)
    casos.astro          casos de estudio (placeholder hasta el primer testimonio)
    sobre.astro          conecta el sitio con Aicore Agency / Aicoremed
    estado.astro         estado del agente semanal (noindex)
    privacidad.astro  terminos.astro  aviso-legal.astro
ops/weekly-ranking/    runner, timer systemd y bootstrap del agente semanal
scripts/               postbuild: sitemap lastmod + llms-full.txt
.github/workflows/     deploy.yml + bootstrap/diagnóstico del agente
docs/                  planes, specs y notas de headers HTTP
```

## Pendientes conocidos

- **Sin feed RSS.** El sitemap y `llms.txt`/`llms-full.txt` ya están; falta
  `@astrojs/rss` si se quiere feed.
- **`prompts.astro`, `repos.astro` y `casos.astro` tienen el contenido hardcodeado**
  (arrays JS o placeholder). Cuando alguna pase de ~15 items, migrarla a content
  collection con el mismo patrón que `blog`.
- **`src/content/config.ts` es un resto del esquema viejo**: define solo `blog`, sin
  `rankings` ni `extra`. Astro lo ignora (la fuente real es `src/content.config.ts`),
  pero conviene borrarlo para que nadie edite el archivo equivocado.
- **Los headers de seguridad de `docs/nginx-headers.md` no están aplicados**: no están
  en `nginx.conf` ni llegan en la respuesta de producción.
- **`nginx.conf` apunta `error_page 404 /404.html`, pero no existe
  `src/pages/404.astro`**: la 404 la sirve nginx con su página por defecto.
- **El job `docker-push` es redundante**: publica la imagen en GHCR y después el VPS la
  reconstruye desde el código, en vez de pullearla. Queda como artefacto de rollback.
- **`.atl/` (cache del skill registry) está sin trackear y no figura en `.gitignore`**:
  o se ignora, o se commitea a propósito, pero no por accidente.
- **Los sellos de goma** (`.stamp-edit`, `.stamp-core`, `.stamp-sub`) se salen de la
  hoja en viewports de ~500 px o menos: hay un scroll horizontal chico en la home.
