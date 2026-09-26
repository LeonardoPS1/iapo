#!/usr/bin/env bash
# iapo.cl — runner del agente semanal de rankings.
# Ejecutado por systemd timer en el VPS. Idempotente, con lock y logs.
set -Eeuo pipefail

REPO_DIR="${IAPO_REPO_DIR:-/opt/iapo-agent/repo}"
LOG_DIR="${IAPO_LOG_DIR:-/var/log/iapo-agent}"
LOCK_FILE="${IAPO_LOCK_FILE:-/var/lock/iapo-ranking.lock}"
MODEL="${IAPO_MODEL:-opencode/big-pickle}"
TIMEOUT_MIN="${IAPO_TIMEOUT_MIN:-25}"
BRANCH="${IAPO_BRANCH:-main}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$LOG_DIR"
RUN_LOG="$LOG_DIR/$(date -u +%Y%m%dT%H%M%SZ)-run.log"
export XDG_DATA_HOME

log() { printf '[%s] %s\n' "$(date -u +%FT%TZ)" "$*" | tee -a "$RUN_LOG"; }
fail() { log "ERROR: $*"; exit 1; }

trap 'rc=$?; log "exit=$rc"; exit $rc' EXIT

# ---------------------------------------------------------------- lock
# Sin flock el `exec 9>` + `flock -n` falla y el script se saltearía toda la
# corrida en silencio (parecería un lock ocupado). Tiene que ser fatal.
command -v flock >/dev/null 2>&1 || { log "ERROR: flock no encontrado (paquete util-linux)"; exit 1; }
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  log "SKIP: ya hay una ejecución en curso (lock $LOCK_FILE)"
  exit 0
fi
log "lock tomado"

log "=== iapo weekly-ranking agent — start ==="
log "repo=$REPO_DIR model=$MODEL branch=$BRANCH timeout=${TIMEOUT_MIN}m"

# ------------------------------------------------------- sanity checks
command -v node >/dev/null 2>&1 || fail "node no encontrado"
command -v opencode >/dev/null 2>&1 || fail "opencode no encontrado en PATH"
command -v git >/dev/null 2>&1 || fail "git no encontrado"

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || fail "node >= 22 requerido (tenés $(node -v))"

# --------------------------------------------------- sync del repo
cd "$REPO_DIR"
git fetch --prune origin "$BRANCH" >>"$RUN_LOG" 2>&1 || fail "git fetch falló (ver $RUN_LOG)"
git checkout "$BRANCH" >>"$RUN_LOG" 2>&1
git reset --hard "origin/$BRANCH" >>"$RUN_LOG" 2>&1
git config user.name  "iapo-agent"
git config user.email "agent@iapo.cl"
log "HEAD en $(git rev-parse --short HEAD) ($(git log -1 --pretty=%s))"

# deps solo si el lockfile cambió
if [ ! -d node_modules ] || [ package-lock.json -nt node_modules/.install-stamp ]; then
  log "npm ci…"
  npm ci >>"$RUN_LOG" 2>&1 || fail "npm ci falló (ver $RUN_LOG)"
  touch node_modules/.install-stamp
fi

# --------------------------------------------------- ejecución del agente
PROMPT='Ejecutá el procedimiento completo de ranking semanal de iapo.cl.
Esta es una ejecución AUTOMÁTICA PROGRAMADA: el push a origin/main está autorizado.
Snapshot: usá la fecha actual en runtime. Escribí src/content/rankings/ranking-YYYY-MM-DD.md,
validá con npm run build (exit 0), y hacé commit + push a main.
Al terminar respondé con el formato de salida obligatorio del procedimiento.'

log "corriendo opencode run (máx ${TIMEOUT_MIN} min)…"
set +e
timeout --signal=SIGINT --kill-after=5m "${TIMEOUT_MIN}m" \
  opencode run --agent weekly-ranking --model "$MODEL" --auto --title "Ranking semanal automático" "$PROMPT" \
  >>"$RUN_LOG" 2>&1
AGENT_RC=$?
set -e
log "opencode terminó con rc=$AGENT_RC"

# --------------------------------------------------- verificación post
log "verificando dist…"
DIST_INDEX="dist/rankings/index.html"
[ -f "$DIST_INDEX" ] || fail "no se generó $DIST_INDEX (el agente no commiteó o el build falló)"

TODAY="$(date -u +%F)"
NEW_PAGE="dist/rankings/ranking-${TODAY}/index.html"
[ -f "$NEW_PAGE" ] || log "WARN: no existe la página de hoy ($NEW_PAGE) — puede ser que el snapshot fuera de otra fecha"

# ¿quedó algo sin pushear?
if [ -n "$(git status --porcelain src/content/rankings)" ]; then
  log "cambios sin commitear en src/content/rankings:"
  git status --short src/content/rankings | tee -a "$RUN_LOG"
fi
AHEAD="$(git rev-list --count "origin/$BRANCH..HEAD")"
log "commits sin pushear: $AHEAD"
[ "$AHEAD" -gt 0 ] || log "WARN: el agente no dejó commits nuevos"

log "log completo: $RUN_LOG"
log "=== fin (agent_rc=$AGENT_RC) ==="

# rc 0 del build es lo que importa; un rc distinto del agente se reporta pero
# no rompe el timer (systemd solo avisa), igual el script sale 0 para que
# systemd no accumulated fallos cuando el agente termine sin pushear.
exit 0
