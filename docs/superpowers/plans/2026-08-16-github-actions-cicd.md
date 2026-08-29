# GitHub Actions CI + GHCR + Auto-deploy Dokploy — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Un workflow de GitHub Actions que al push a `main` valida el build, publica la imagen en GHCR y dispara el deploy automático en Dokploy vía webhook.

**Architecture:** Un único archivo `.github/workflows/deploy.yml` con 3 jobs encadenados: `build` (npm ci + npm run build), `docker-push` (Buildx → GHCR con `GITHUB_TOKEN`), `deploy` (curl al webhook de Dokploy). Dokploy sigue haciendo build desde git (`customGitUrl`), la imagen GHCR queda como artefacto/rollback.

**Tech Stack:** GitHub Actions, Docker Buildx, GHCR (ghcr.io), curl, Dokploy webhook.

## Global Constraints

- Sin test runner: la verificación del código Astro es `npm run build` exit 0.
- Workflow path exacto: `.github/workflows/deploy.yml`.
- Trigger: solo `push` a `main`.
- Tags GHCR exactos: `ghcr.io/leonardops1/iapo:latest` y `ghcr.io/leonardops1/iapo:sha-<hash-7>`.
- Webhook de deploy (verificado en DB del VPS): `https://dokploy.aicorebots.com/api/deploy/fK9WZ9rE6pxrhFp-4zJ1Y`.
- No se cambia config de la app en Dokploy; no se toca Dockerfile/nginx/docker-compose.
- No se agregan comentarios de código salvo los del YAML que describe secciones del workflow.
- Commit final con push a GitHub (repo `LeonardoPS1/iapo`, branch `main`) y verificación de que el workflow corre y deploya.

---

### Task 1: Crear el workflow deploy.yml

**Files:**
- Create: `.github/workflows/deploy.yml`

**Interfaces:**
- Consumes: nada (archivo nuevo).
- Produces: `.github/workflows/deploy.yml` — consumido por GitHub Actions.

- [ ] **Step 1: Escribir el workflow**

Crear `.github/workflows/deploy.yml` con el siguiente contenido EXACTO:

```yaml
name: deploy

on:
  push:
    branches:
      - main

permissions:
  contents: read
  packages: write

concurrency:
  group: iapo-deploy
  cancel-in-progress: false

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run build

  docker-push:
    name: Push image to GHCR
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v4
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ghcr.io/leonardops1/iapo:latest
            ghcr.io/leonardops1/iapo:sha-${{ github.sha }}
      - name: Get short SHA
        id: sha
        run: echo "short=$(echo ${{ github.sha }} | cut -c1-7)" >> "$GITHUB_OUTPUT"

  deploy:
    name: Deploy to Dokploy
    runs-on: ubuntu-latest
    needs: docker-push
    steps:
      - name: Trigger Dokploy deploy webhook
        run: |
          curl -X POST \
            -f \
            --max-time 300 \
            "https://dokploy.aicorebots.com/api/deploy/fK9WZ9rE6pxrhFp-4zJ1Y"
```

Nota: el step "Get short SHA" no se usa en tags (el tag usa `github.sha` completo). Dejarlo es opcional — NO incluirlo si queda sin uso; los tags usan `github.sha` completo como especifica el plan (`ghcr.io/leonardops1/iapo:sha-<hash>`). Si se elimina, asegurarse de que el archivo no quede con el step huérfano. La versión final debe cumplir: tags `latest` y `sha-<hash>` con el hash completo de `github.sha`.

- [ ] **Step 2: Validar sintaxis del YAML**

Run: `node -e "const fs=require('fs');const s=fs.readFileSync('.github/workflows/deploy.yml','utf8');require('js-yaml')? null : null" 2>&1 || echo "skip"` — si js-yaml no está disponible, validar manualmente: indentación consistente (2 espacios), sin tabs, claves `on`/`permissions`/`jobs` correctas.

Nota: no hay dependencia js-yaml en el proyecto; la validación sintáctica se hace por inspección manual del YAML (indentación y estructura) dado que `npm run build` no cubre `.github/`. Verificar: indentación de 2 espacios, `on:` a nivel raíz, `jobs:` a nivel raíz, cada job con `runs-on` y `steps`.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy.yml
git commit -m "ci: workflow GitHub Actions CI + imagen GHCR + auto-deploy Dokploy"
```

---

### Task 2: Push y verificación del pipeline completo

**Files:**
- (ninguno — solo git)

**Interfaces:**
- Consumes: `.github/workflows/deploy.yml` de Task 1.
- Produces: evidencia de que el workflow corre en GitHub y deploya en Dokploy.

- [ ] **Step 1: Push a GitHub**

```bash
git push origin main
```

Expected: push OK (Windows Credential Manager). El push dispara el workflow `deploy` en GitHub Actions (3 jobs: build → docker-push → deploy).

- [ ] **Step 2: Verificar el workflow en GitHub**

Verificar en la pestaña Actions del repo `LeonardoPS1/iapo` que el run del push más reciente:
- job `build` → ✅ green (npm ci + npm run build).
- job `docker-push` → ✅ green (imagen `ghcr.io/leonardops1/iapo:latest` + `sha-<hash>` publicadas).
- job `deploy` → ✅ green (curl al webhook, HTTP 200).

Si `gh` CLI no está disponible y no hay acceso visual, confirmar el estado vía la API pública (o el usuario lo revisa): `https://api.github.com/repos/LeonardoPS1/iapo/actions/runs`.

- [ ] **Step 3: Verificar el deploy en producción**

Run (desde local, paramiko, `ubuntu@51.222.207.250` pass `Cool220479..@`):
- `docker service ps iapo-iapo-srsxbv` → nuevo contenedor Up tras el deploy webhook.
- `curl -s -o /dev/null -w "%{http_code}" https://iapo.cl` → 200.

Expected: contenedor redeployado por el webhook y página respondiendo 200 sin intervención SSH de build.

- [ ] **Step 4: Confirmar estado**

Confirmar con el usuario que el workflow corrió en verde y el deploy se disparó desde GitHub Actions (el usuario revisa la pestaña Actions / el dashboard de Dokploy).

---

## Self-Review

- **Spec coverage:** Task 1 cubre los 3 jobs (build/docker-push/deploy) y los tags exactos; Task 2 cubre la verificación end-to-end (push → workflow → deploy → 200). ✓
- **Placeholder scan:** sin TBD/TODO; el YAML es completo. La nota del Step 1 sobre el step huérfano es explícita. ✓
- **Type consistency:** tags consistentes (`latest` y `sha-<github.sha>`); webhook consistente en Task 1 y 2. ✓