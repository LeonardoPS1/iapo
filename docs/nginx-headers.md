# nginx/Cloudflare HTTP Headers for iapo.cl SEO

## Current nginx.conf Configuration

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/index.html $uri.html =404;
    }

    error_page 404 /404.html;

    location ~* \.(?:css|js|png|jpe?g|webp|avif|svg|ico|woff2?|ttf)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    location ~* \.(?:xml|txt)$ {
        add_header Cache-Control "public, max-age=3600";
    }

    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;
}
```

## Cache Headers (Already Configured)
- Static assets (images, CSS, JS): `Cache-Control: public, max-age=604800` (7 days)
- XML/TXT (sitemap, robots): `Cache-Control: public, max-age=3600` (1 hour)

## Required Additional Headers

### Security Headers (to add in nginx or Cloudflare)
```nginx
# Content Security Policy
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://fonts.gstatic.com https://db52c710.sibforms.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://db52c710.sibforms.com; frame-src https://db52c710.sibforms.com;" always;

# HSTS (enable after SSL verified)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Prevent clickjacking
add_header X-Frame-Options "SAMEORIGIN" always;

# Prevent MIME sniffing
add_header X-Content-Type-Options "nosniff" always;

# Referrer policy
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### X-Robots-Tag for Non-HTML Resources
```nginx
# For PDFs, images, etc.
location ~* \.(pdf|jpg|jpeg|png|gif|webp|svg|ico|woff|woff2)$ {
    add_header X-Robots-Tag "index, follow" always;
}
```

### Permissions Policy
```nginx
add_header Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()" always;
```

## Cloudflare Configuration (Alternative)
If using Cloudflare Workers/Pages, configure in Cloudflare dashboard:
- Security > WAF > Managed Rules
- Speed > Optimization > Auto Minify (CSS, JS, HTML)
- Network > HTTP/3 (QUIC)
- SSL/TLS > Always Use HTTPS, HSTS
- Scrape Shield > Email Obfuscation, Server-side Excludes

## Verification
Test headers with:
```bash
curl -I https://iapo.cl/
curl -I https://iapo.cl/og.png
curl -I https://iapo.cl/sitemap-index.xml
```