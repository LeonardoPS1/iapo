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

## Estructura

```
src/
  content/blog/       ← artículos en Markdown (esto es lo que se edita día a día)
  content.config.ts   ← schema de validación del frontmatter
  layouts/             Base.astro (shell), Post.astro (artículo)
  components/          Header.astro, Footer.astro
  pages/
    index.astro         home
    blog/index.astro     listado
    blog/[id].astro       ruta dinámica de artículo
    prompts.astro         directorio de prompts (contenido inline por ahora)
    repos.astro            curaduría de repos (contenido inline por ahora)
    casos.astro              casos de estudio (placeholder hasta primer testimonio)
    sobre.astro                conecta el sitio con Aicore Agency / AiCoreMed
```

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
