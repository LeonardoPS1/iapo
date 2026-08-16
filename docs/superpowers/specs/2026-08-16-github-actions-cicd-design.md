# GitHub Actions — CI + imagen GHCR + auto-deploy a Dokploy

Fecha: 2026-08-16
Estado: Aprobado

## Contexto

Al push a `main`, hoy nada se ejecuta en GitHub Actions y Dokploy no auto-redeploya
(no hay webhook de GitHub configurado). El deploy actual es manual por SSH.

Se agrega un workflow de GitHub Actions que, al push a `main`:
1. Valida el build (`npm ci` + `npm run build`).
2. Publica la imagen Docker en GHCR (pública).
3. Dispara el deploy automático en Dokploy vía webhook.

## Decisiones del usuario

- Rol del workflow: **CI + imagen en GHCR**.
- Visibilidad de la imagen: **pública** (repo público → sin credenciales en Dokploy).
- Disparador del deploy: **webhook de Dokploy**.
- Deploy **automatizado** (no manual desde el dashboard).

## 1. Archivo del workflow

`.github/workflows/deploy.yml` — trigger: `push` a `main`.

## 2. Jobs

### build (gate)
- `npm ci` + `npm run build`.
- Si falla, los siguientes jobs no corren.

### docker-push
- Buildx + `docker/build-push-action`.
- Tags en GHCR:
  - `ghcr.io/leonardops1/iapo:latest`
  - `ghcr.io/leonardops1/iapo:sha-<hash-corto>`
- Auth: `GITHUB_TOKEN`, `permissions: packages: write`.

### deploy
- `curl` al webhook de deploy de Dokploy:
  - `https://dokploy.aicorebots.com/api/deploy/fK9WZ9rE6pxrhFp-4zJ1Y`
- El webhook (verificado en el contenedor: `/api/deploy/[refreshToken]`) hace
  git pull + `docker build` + `docker service update` en Dokploy usando la
  config actual de la app (`customGitUrl https://github.com/LeonardoPS1/iapo`,
  branch `main`, `buildType: dockerfile`).

## 3. Datos de la app en Dokploy (verificados en DB del VPS)

- `applicationId`: `wWAi4lDfSjUN47T7RE_g0`
- `appName`: `iapo-iapo-srsxbv`
- `refreshToken` (webhook deploy): `fK9WZ9rE6pxrhFp-4zJ1Y`
- `sourceType`: git · `customGitUrl`: `https://github.com/LeonardoPS1/iapo` ·
  branch `main` · `buildType`: dockerfile

## 4. Flujo resultante

`git push` → GitHub Actions valida → publica imagen GHCR → llama webhook →
Dokploy redeploya automáticamente. Sin SSH manual, sin secretos guardados.

## 5. Fuera de alcance (YAGNI)

- No cambiar la config de la app en Dokploy (sigue build desde git).
- No tocar `Dockerfile` / `nginx.conf` / `docker-compose.yml`.
- No configurar webhook entrante de GitHub en Dokploy.
- La imagen GHCR queda como artefacto/rollback; el deploy usa el build desde git.

## 6. Verificación

- `npm run build` exit 0 en el job `build`.
- Push de prueba → workflow verde (3 jobs) → https://iapo.cl responde 200 tras redeploy.
- El token del webhook va en texto plano en el workflow (permite solo redeploy de esta app).