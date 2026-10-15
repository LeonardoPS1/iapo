# HTTP headers for iapo.cl (nginx + Cloudflare)

The site is served by nginx (`nginx:alpine` in the Swarm service `iapo-iapo-srsxbv`) with
Cloudflare in front. Security headers are applied by nginx, not by Cloudflare.

## Files

| File | Role |
|------|------|
| `nginx.conf` | Server block baked into the image (`/etc/nginx/conf.d/default.conf`). |
| `nginx-security-headers.conf` | Security headers, copied to `/etc/nginx/snippets/security-headers.conf` by the `Dockerfile`. |

`nginx.conf` includes the snippet at the `server` level **and** inside every `location` that
declares its own `add_header`. nginx drops inherited headers in a block as soon as that block
declares one, so the include has to be repeated — keep that in mind when adding a location.

CI validates the config on every push: the `build` job runs
`docker run --rm -v "$PWD/nginx.conf":/etc/nginx/conf.d/default.conf:ro \
 -v "$PWD/nginx-security-headers.conf":/etc/nginx/snippets/security-headers.conf:ro nginx:alpine nginx -t`.

## Cache headers

| Match | Header |
|-------|--------|
| `css`, `js`, images, fonts | `Cache-Control: public, max-age=604800, immutable` |
| `xml`, `txt` (sitemap, robots, llms.txt) | `Cache-Control: public, max-age=3600` |

Use a single `add_header Cache-Control` per block: `expires 7d` together with
`add_header Cache-Control` emits two `Cache-Control` headers.

## Security headers applied

| Header | Value |
|--------|-------|
| `Content-Security-Policy` | see `nginx-security-headers.conf` |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload` |
| `X-Frame-Options` | `SAMEORIGIN` |
| `X-Content-Type-Options` | `nosniff` |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | camera, microphone, geolocation, payment, usb, etc. disabled |

Third-party origins the CSP has to allow (each one is used by the page):

- `https://giscus.app` — comments on `/extra/<slug>` (`script-src`, `connect-src`, `frame-src`).
- `https://static.cloudflareinsights.com` (`script-src`) and `https://cloudflareinsights.com`
  (`connect-src`) — Cloudflare Web Analytics beacon, injected by Cloudflare at the edge, not in the repo.
- `https://db52c710.sibforms.com` — Brevo newsletter iframe on the home (`frame-src`).
- `https://fonts.googleapis.com` / `fonts.gstatic.com` — Playfair Display, Inter, JetBrains Mono.
- `'unsafe-inline'` for `script-src`/`style-src`: Astro emits inline scripts and inline JSON-LD,
  and component styles are inlined in the head.

## 404

`error_page 404 /404.html;` is served by `src/pages/404.astro`, so the file exists in `dist/`.

## Verification

```bash
curl -sI https://iapo.cl/ | grep -iE 'content-security|strict-transport|x-frame|x-content-type|referrer-policy'
curl -sI https://iapo.cl/og.png                      # cache + nosniff
curl -sI https://iapo.cl/sitemap-index.xml           # cache 1h
curl -sI https://iapo.cl/this-does-not-exist         # 404 body
```

Before this change production returned **none** of the security headers (they were only
documented here). If any of the greps above come back empty after a deploy, the snippet is
not reaching the location block that serves that path.

## Cloudflare notes

Cloudflare sits in front of nginx, so the client sees Cloudflare's response. Keep these in mind:

- The Web Analytics beacon is injected at the edge; `cloudflareinsights.com` must stay in the CSP.
- If a Cloudflare transform rule ever adds headers, verify they do not duplicate the nginx ones.
- HSTS: Cloudflare SSL/TLS can also send it; set it in one place only.
