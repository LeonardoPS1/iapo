# Ranking Semanal + Agente Recurrente — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publicar en iapo.cl un ranking semanal (5 repos GitHub trending, 5 agent skills, 5 MCP servers) con colección Astro dedicada, y crear un agente OpenCode que regenere/actualice el ranking cada semana sin prompts adicionales.

**Architecture:** Nueva colección `rankings` en `src/content.config.ts` + layout `Ranking.astro` (sobre `Base.astro`, JSON-LD `Article`) + listing `/rankings` + detalle `/rankings/[id]` + contenido `src/content/rankings/ranking-2026-09-25.md` + enlace en nav Header + agente `.opencode/agent/weekly-ranking.md` + job semanal del scheduler.

**Tech Stack:** Astro 7.2.2, TypeScript, Zod (astro:content), motion, Docker/Dokploy deploy vía GitHub Actions push a `main`.

## Global Constraints

- **Validación ante todo:** `npm run build` debe terminar con exit 0. El repo NO tiene test runner; el build es la puerta de calidad.
- **Sin replicar Post.astro:** `src/layouts/Post.astro` está atado a `CollectionEntry<'blog'>` y a `pilar`. NO reutilizarlo; crear `Ranking.astro`.
- **Colección dedicada** `rankings`; no guardar el ranking en `blog`. `src/content/config.ts` (raíz antigua) NO se toca.
- **Frontmatter exacto** del ranking: `title`, `description`, `pubDate: z.coerce.date()`, `snapshotDate: z.coerce.date()`, `period` objeto `{ repos, skills, mcp }`, `draft` boolean default false. Rich content vía `render()` y `<Content />`.
- **15 ítems exactos** (5+5+5), sin duplicados entre categorías, con métrica + ventana temporal + fuente primaria enlazada + descripción + «por qué importa».
- **Veracidad:** NO inventar métricas ni URLs. Etiquetar la ventana real: repos = GitHub Trending `?since=weekly`; skills = skills.sh Trending (24h, explicitar que no es delta semanal); MCP = mcp.so «Trending this week». Advertir que los 4 primeros skills provienen del mismo repo fork (`101-skills/superpowers`).
- **SEO:** anchors descriptivos, no «click aquí»; sección final «Fuentes y metodología»; enlaces internos a `/blog`, `/repos`, `/blog/repos-de-la-semana-1`; `rel="noopener noreferrer"` cuando haya `target="_blank"`.
- **Fecha snapshot:** ranking inicial `2026-09-25`. El agente recurrente computa la fecha en runtime y usa `ranking-YYYY-MM-DD.md`.
- **Commit:** commit con mensaje tipo `feat(rankings): ranking semanal #1 + colección + agente`. No push ni merge a main salvo autorización explícita del usuario.

## Datos fuente (archivados 2026-09-25 — el agente debe re-consultar cada semana)

### GitHub Trending `https://github.com/trending?since=weekly` (orden de página, estrellas ganadas esta semana)
1. `cloudflare/security-audit-skill` — JavaScript — 11.262 — skill de auditorías de seguridad multifase con findings machine-readable verificables.
2. `anthropics/financial-services` — Python — 2.382 — reference agents/skills/connectors de servicios financieros (Pitch Agent, Market Researcher, GL Reconciler…) como plugins Claude Cowork/Code + templates Managed Agents + conectores MCP.
3. `anthropics/claude-code` — TypeScript — 2.384 — agente de coding en terminal que entiende codebases, ejecuta tareas, explica código y maneja git.
4. `alibaba/open-code-review` — Go — 6.920 — revisión híbrida determinista + LLM, comentarios por línea y análisis de seguridad multi-lenguaje.
5. `affaan-m/ECC` — JavaScript — 6.193 — harness de optimización de agentes (skills, instincts, memory, security, research-first) para Claude Code/Codex/OpenCode/Cursor.

### skills.sh Trending 24h `https://www.skills.sh/trending` (installs últimas 24h; NO es delta semanal)
1. `ai-image-generation` (`101-skills/superpowers`) — 38.144
2. `ai-video-generation` (`101-skills/superpowers`) — 38.143
3. `ai-avatar-video` (`101-skills/superpowers`) — 38.136
4. `twitter-automation` (`101-skills/superpowers`) — 38.132
5. `google-agents-cli-adk-code` (`google/agents-cli`) — 36.766

### mcp.so «Trending this week» `https://mcp.so/`
1. Medplum — 2.5K — `https://mcp.so/servers/medplum`
2. Atomic Mail Agentic — 255 — `https://mcp.so/servers/atomic-mail-agentic-4fde98`
3. PLUR — 226 — `https://mcp.so/servers/plur`
4. Termany — 174 — `https://mcp.so/servers/termany`
5. Hostinger — 148 — `https://mcp.so/servers/hostinger`

### Fuentes secundarias/contexto cualitativo
- skills.sh docs/API: `https://www.skills.sh/docs/api` (trending = 24h, hot = 1h; API requiere OIDC).
- Glama reference: `https://glama.ai/mcp/reference` (API requiere Bearer; weekly no expuesto sin auth).
- Smithery `/servers`: `https://smithery.ai/docs/api-reference/servers/list-all-servers` (useCount = conectores totales acumulados, no semanal).
- Substack cualitativo: Addy Osmani «Audit your Agent files» (2026-08-27, `https://addyo.substack.com/p/audit-your-agent-files`) y Paul Goldsmith-Pinkham «Skills: Specifying How an Agent Should Think» (2026-05-24, `https://paulgp.substack.com/p/skills-specifying-how-an-agent-should`). NO usar cifras de Substack.
- Snyk ToxicSkills: advertencia de seguridad, no ranking (`https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub/`).

## Task 1: Colección `rankings` en content.config.ts

**Files:**
- Modify: `src/content.config.ts`

- [ ] Añadir segunda colección al archivo existente:

```ts
const rankings = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/rankings' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    snapshotDate: z.coerce.date(),
    period: z.object({
      repos: z.string(),
      skills: z.string(),
      mcp: z.string(),
    }),
    draft: z.boolean().default(false),
  }),
});

export const collections = { blog, rankings };
```

- [ ] Validar: `npm run build` exit 0 (el build carga el schema; colección vacía es válida).
- [ ] Commit: `feat(rankings): colección Astro rankings`

## Task 2: Layout `Ranking.astro`

**Files:**
- Create: `src/layouts/Ranking.astro`

- [ ] Crear layout sobre `Base.astro` (type=article, JSON-LD `Article`) con `<slot />` dentro de `.content.prose-col`, metadata (fecha publicación, fecha snapshot, period) y sello `// RANKING`. Reusar clases `panel`, `page-head`, `eyebrow`, `prose-col`, `data-reveal`. Recibir props: `title`, `description`, `pubDate`, `snapshotDate`, `period`.

- [ ] Validar: build exit 0.
- [ ] Commit: `feat(rankings): layout Ranking con JSON-LD Article`

## Task 3: Página listing `/rankings`

**Files:**
- Create: `src/pages/rankings/index.astro`

- [ ] `getCollection('rankings', ({ data }) => !data.draft)` orden desc por `pubDate`; JSON-LD `CollectionPage` + `ItemList`; lista de cards (título, descripción, fecha); estado vacío; uso de `Base` y `transition:name` por id.

- [ ] Validar: build exit 0 y que aparece `dist/rankings/index.html`.
- [ ] Commit: `feat(rankings): listing /rankings`

## Task 4: Página detalle `/rankings/[id]`

**Files:**
- Create: `src/pages/rankings/[id].astro`

- [ ] `getStaticPaths` con rankings sin draft; `params: { id }`, `props: { entry }`; `render(entry)`; pasar frontmatter a `Ranking.astro` y `<Content />`.

- [ ] Validar: build exit 0 y `dist/rankings/ranking-2026-09-25/index.html` presente.
- [ ] Commit: `feat(rankings): detalle /rankings/[id]`

## Task 5: Contenido `ranking-2026-09-25.md`

**Files:**
- Create: `src/content/rankings/ranking-2026-09-25.md`

- [ ] Frontmatter con datos de arriba; cuerpo con 3 secciones (Repos / Agent Skills / MCP Servers), 5 ítems cada una (tabla o lista con métrica, ventana, descripción, enlace primario, por qué importa), advertencia del mismo-repo-fork en skills, sección final «Fuentes y metodología» con todas las URLs y sus fechas/ventanas y la nota de honestidad sobre 24h vs semanal, y enlaces internos.

- [ ] Validar: build exit 0; frontmatter Zod pasa; conteo 5+5+5.
- [ ] Commit: `feat(rankings): contenido ranking 2026-09-25`

## Task 6: Nav en Header

**Files:**
- Modify: `src/components/Header.astro`

- [ ] Añadir `{ href: '/rankings', label: 'Rankings' }` al array `nav`.

- [ ] Validar: build exit 0.
- [ ] Commit: `feat(rankings): link Rankings en nav`

## Task 7: Agente recurrente `.opencode/agent/weekly-ranking.md`

**Files:**
- Create: `.opencode/agent/weekly-ranking.md`

- [ ] Frontmatter: `description` de cuándo usarse, `mode: all`, `temperature: 0.1`, `permission` (read/edit/webfetch/websearch allow; bash: `git *`, `npm *` allow, resto ask).
- [ ] Body: procedimiento completo no interactivo: (1) consultar fecha actual en runtime y comprobar si `src/content/rankings/ranking-<fecha>.md` ya existe (idempotencia: si existe el de hoy, actualizarlo en vez de duplicar); (2) obtener datos live de las 3 fuentes; (3) redactar los 15 ítems con métrica/ventana/enlace/descripción/por qué; (4) sección «Fuentes y metodología»; (5) advertencias de veracidad/ventana; (6) `npm run build` y verificar rutas `dist/rankings/`; (7) commit (mensaje `feat(rankings): ranking semanal <fecha>`) y push solo si el usuario lo autorizó o en ejecución automática programada; (8) resumen final de estado/salidas.
- [ ] Recordar al usuario reiniciar opencode (config no se hot-reload).
- [ ] Commit: `feat(rankings): agente semanal weekly-ranking`

## Task 8: Job semanal del scheduler

**Files:**
- Registro scheduler (global config).

- [ ] Crear job `weekly-ranking` con cron semanal p. ej. `0 7 * * 1`, `agent: weekly-ranking`, `workdir: D:\OPENCODE\IAPO`, prompt mínimo no interactivo que remita al agente y exija resumen de estado.
- [ ] Verificar con `list_jobs` / `get_job`.

## Task 9: Verificación final

- [ ] `npm run build` exit 0.
- [ ] Verificar `dist/rankings/index.html` y `dist/rankings/ranking-2026-09-25/index.html`.
- [ ] `git diff --check` limpio; revisar diff completo.
- [ ] Actualizar memoria de proyecto y session-log.
- [ ] NO push/merge a main hasta autorización del usuario.