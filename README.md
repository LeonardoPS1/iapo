# iapo.cl

Sitio de contenido de Aicore Agency: tips, prompts, repos y casos de IA aplicada,
con foco en automatización y salud digital en Chile.

Stack: **Astro** (SSG) + Markdown como content collection + Nginx en producción.
Cero backend corriendo, cero costo incremental sobre el VPS existente.

## Desarrollo local

```bash
npm install
npm run dev       # http://localhost:4321
```

## Escribir un artículo nuevo

1. Crea un archivo en `src/content/blog/mi-slug.md`.
2. Frontmatter requerido:

```yaml
---
title: "Título del artículo"
description: "Bajada de 1-2 líneas, aparece en el listado y en meta description."
pubDate: 2026-08-21
pilar: "salud" | "automatizacion" | "ia-general"
tags: ["whatsapp", "n8n"]
draft: false   # true lo oculta de listados y build de producción
---
```

3. El slug del artículo (`mi-slug`) define la URL: `/blog/mi-slug`.
4. `npm run build` valida el frontmatter contra el schema en `src/content.config.ts` —
   si falta un campo obligatorio, el build falla ahí mismo (mejor que en producción).

## Escribir una nota Extra ("Último momento")

Las notas **Extra** son las urgencias/novedades que se publican sin esperar al
calendario editorial del blog. Viven en su propia sección (`/extra`) y son la
**única** sección del sitio con comentarios.

1. Crea un archivo en `src/content/extra/mi-slug.md` (mismo slug para la URL y
   para el archivo). La URL queda como `/extra/mi-slug`.
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
(El cuerpo va en Markdown, igual que en el blog. Los enlaces externos abren
en pestaña nueva automáticamente; no hay que agregarles nada.)
```

`title`, `headline` e `intro` cumplen funciones distintas y las tres son
obligatorias: el layout las usa en lugares diferentes (`headline` es el texto
grande del diario, `intro` la bajada, `title` el encabezado de la página).
El array `sources` alimenta el bloque "Fuentes y enlaces" al pie de la nota.

3. `featured: true` marca la nota como **candidata** al diario flotante de la
   home: ese diario muestra la nota featured más reciente. Si hay varias, gana
   la de `pubDate` mayor. Poner `featured: false` retira la nota del diario
   **sin** sacarla de `/extra`.
4. El diario flotante aparece ~1,2 s después de cargar la home, se puede cerrar
   con la ×, y no vuelve a aparecer en ese navegador (se recuerda en
   `localStorage` bajo la clave `iapo:extra-dismissed:<slug>`). Si querés
   volver a verlo para probar, borrá esa clave desde las DevTools.
5. Los comentarios (Giscus, sobre GitHub Discussions) se cargan **solo** en
   `/extra/<slug>`, nunca en el blog ni en la home. Están desactivados hasta
   que se completen los dos IDs en `src/components/GiscusComments.astro`
   (ver "Activar los comentarios" abajo).

## Estructura

```
src/
  content/blog/       ← artículos en Markdown (esto es lo que se edita día a día)
  content/extra/      ← notas "Último momento" en Markdown (mismo patrón)
  content/rankings/    ← ranking semanal (JSON-ish en Markdown, lo genera el agente)
  content.config.ts   ← schema de validación del frontmatter
  layouts/             Base.astro (shell), Post.astro (artículo)
  components/          Header.astro, Footer.astro, ExtraFlash.astro, GiscusComments.astro
  pages/
    index.astro         home
    blog/index.astro     listado
    blog/[id].astro       ruta dinámica de artículo
    extra/index.astro       listado de notas Extra
    extra/[id].astro         ruta dinámica de nota Extra (única con comentarios)
    prompts.astro         directorio de prompts (contenido inline por ahora)
    repos.astro            curaduría de repos (contenido inline por ahora)
    casos.astro              casos de estudio (placeholder hasta primer testimonio)
    sobre.astro                conecta el sitio con Aicore Agency / AiCoreMed
```

## Activar los comentarios (Giscus)

El componente `src/components/GiscusComments.astro` viene con dos marcadores
(`REEMPLAZAR_REPO_ID` y `REEMPLAZAR_CATEGORY_ID`) y, mientras estén sin
completar, muestra el aviso "Los comentarios se activan muy pronto." en vez de
cargar el iframe. Para activarlos (lo hace el dueño del sitio, una sola vez):

1. Habilitar **Discussions** en el repo de GitHub del sitio.
2. Crear una categoría llamada `Extra` (tipo Announcements) en Discussions.
3. Instalar la app de **giscus** en ese repo: <https://github.com/apps/giscus>.
4. Obtener los IDs reales en <https://giscus.app> (repo + categoría) y pegarlos
   en las dos constantes del componente. Nada más: no hace falta build aparte.

`prompts.astro` y `repos.astro` tienen el contenido hardcodeado como arreglos JS
por simplicidad inicial. Cuando haya más de ~15 items en cualquiera de las dos,
migrar a content collections igual que `blog` (mismo patrón, otra carpeta en
`src/content/`).

## Deploy en Dokploy

El repo incluye `Dockerfile` (build Astro → sirve estático con Nginx) y `nginx.conf`.

1. En Dokploy, crear una nueva app tipo **Dockerfile** apuntando a este repo (o subir
   por Git si ya está en tu remoto).
2. Puerto interno: `80` (definido en el Dockerfile).
3. Dominio: `iapo.cl` (+ `www.iapo.cl` con redirect si corresponde), certificado
   Let's Encrypt automático vía Dokploy/Traefik, igual que el resto de tus servicios
   bajo `aicorebots.com`.
4. No requiere variables de entorno ni base de datos — es un sitio 100% estático.
   El único servicio externo es Listmonk (newsletter), que se referencia por URL
   absoluta en el formulario de suscripción (`newsletter.iapo.cl`), no por env var.

## Newsletter (Listmonk)

El formulario en `index.astro` apunta a `https://newsletter.iapo.cl/subscription/form`.
Falta:
1. Desplegar un contenedor Listmonk en el VPS (Docker, igual patrón que el resto del stack).
2. Crear la lista de suscripción y reemplazar el `action` del form con la URL real
   que entrega Listmonk para esa lista.
3. Apuntar el subdominio `newsletter.iapo.cl` al contenedor vía Dokploy.

## Pendientes conocidos

- Favicon es el placeholder de Astro — reemplazar en `public/favicon.svg`.
- No hay feed RSS ni sitemap todavía (fácil de agregar con `@astrojs/rss` y
  `@astrojs/sitemap` cuando haya volumen de contenido que lo justifique).
- `prompts.astro` y `repos.astro` son listas estáticas — pasar a Markdown cuando
  crezcan.
