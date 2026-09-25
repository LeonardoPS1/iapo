# Progress Ledger — Weekly Ranking

**Track:** `2026-09-25-weekly-ranking-agente`

Session protocol: `<dv-summary/>` before exits, `<dv-checkpoint/>` after each block, `<dv-resume>` operacional.

## TL;DR / Current State
Plan `docs/superpowers/plans/2026-09-25-weekly-ranking.md` es la fuente de verdad de verificación. Rama `feat/weekly-ranking-agent`, worktree en `C:\Users\Leonardo\.local\share\opencode\worktree\84dafe527d997a6b40cfa348a6485e8b16e14dbb\feat\weekly-ranking-agent`. Implementación en curso. Validación = `npm run build` exit 0.

## Task Status

| Task | Status |
| --- | --- |
| T1 Colección `rankings` (content.config.ts) | [x] |
| T2 Layout `Ranking.astro` | [x] |
| T3 Listing `/rankings/index.astro` | [x] |
| T4 Detalle `/rankings/[id].astro` | [x] |
| T5 Contenido `ranking-2026-09-25.md` | [x] |
| T6 Nav Header | [x] |
| T7 Agente `.opencode/agent/weekly-ranking.md` | [x] |
| T8 Job scheduler semanal | [x] |
| T9 Verificación final | [x] |

## Checkpoints

<dv-checkpoint id="cp-2026-09-25-1" status="completed">
- Datos fuente live verificados: hrefs mcp.so extraídos del HTML (`/servers/medplum`, `/servers/atomic-mail-agentic-4fde98`, `/servers/plur`, `/servers/termany`, `/servers/hostinger`).
- Plan escrito: `docs/superpowers/plans/2026-09-25-weekly-ranking.md`.
- `npm run build` EXIT 0 — 15 páginas, ambas rutas `/rankings` generadas y en sitemap.
- `npm run install` necesario en el worktree (node_modules no versionada); 6 vulnerabilities de terceros preexistentes.
- Contenido: 15 ítems (5+5+5), 4 secciones, 5 `mcp.so/servers/` links exactos, sin `target=_blank`.
- Links skills.sh verificados con webfetch (ai-image-generation y google-agents-cli-adk-code resuelven).
- Agente `.opencode/agent/weekly-ranking.md` (mode all, temperature 0.1).
- Job scheduler `weekly-ranking` registrado: `0 7 * * 1` (lunes 07:00), workdir `D:\OPENCODE\IAPO`, agent weekly-ranking. OJO: schtasks limita `/TR` a 261 chars → prompt reducido a una línea.
- `git diff --check` limpio. NO commit aún (sin autorización explícita).
</dv-checkpoint>

## Decisions
- Colección dedicada `rankings` (no blog). Métrica skills = skills.sh Trending 24h (explicitar ventana).