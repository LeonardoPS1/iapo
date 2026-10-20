#!/usr/bin/env bash
# iapo.cl — runner del agente semanal de rankings.
# Ejecutado por systemd timer en el VPS. Idempotente, con lock, logs y
# publicación del resultado en src/data/agent-status.json.
#
# Regla de oro: la corrida puede fallar, pero el estado tiene que llegar a
# GitHub igual. Un fallo que no deja rastro es indistinguible de "no corrió".
set -Eeuo pipefail

REPO_DIR="${IAPO_REPO_DIR:-/opt/iapo-agent/repo}"
LOG_DIR="${IAPO_LOG_DIR:-/var/log/iapo-agent}"
LOCK_FILE="${IAPO_LOCK_FILE:-/var/lock/iapo-ranking.lock}"
STATUS_REL="src/data/agent-status.json"
MODEL="${IAPO_MODEL:-alibaba/qwen3.8-max}"
TIMEOUT_MIN="${IAPO_TIMEOUT_MIN:-25}"
BRANCH="${IAPO_BRANCH:-main}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# El directorio de logs no puede ser un prerrequisito de la corrida. El
# 2026-09-27 el runner murió en el `mkdir` de /var/log con "Permission denied":
# sin log, sin estado, y por lo tanto indistinguible de "no corrió". Ahora se
# prueba la escritura y, si falla, se cae a un path del usuario de servicio.
LOG_FALLBACK_DIR="${IAPO_FALLBACK_LOG_DIR:-${HOME:-/tmp}/.local/state/iapo-agent}"
LOG_DEGRADED=0
if ! mkdir -p "$LOG_DIR" 2>/dev/null || ! touch "$LOG_DIR/.write-probe" 2>/dev/null; then
  printf '[%s] WARN: no se puede escribir en %s; los logs van a %s\n' \
    "$(date -u +%FT%TZ)" "$LOG_DIR" "$LOG_FALLBACK_DIR" >&2
  mkdir -p "$LOG_FALLBACK_DIR" 2>/dev/null || LOG_FALLBACK_DIR="$(mktemp -d)"
  LOG_DIR="$LOG_FALLBACK_DIR"
  LOG_DEGRADED=1
fi
rm -f "$LOG_DIR/.write-probe" 2>/dev/null || true
RUN_LOG="$LOG_DIR/$(date -u +%Y%m%dT%H%M%SZ)-run.log"
RUN_LOG_NAME="$(basename "$RUN_LOG")"
export XDG_DATA_HOME

START_EPOCH="$(date -u +%s)"
AGENT_RC=""
AGENT_ERROR=""
STATUS_STAGE="start"
STATUS_MESSAGE="corrida iniciada"
STATUS_PUBLISH=1

log() {
  local line="[$(date -u +%FT%TZ)] $*"
  # Si el archivo no se puede escribir, el mensaje igual sale por stdout y
  # queda en el journal: perder el log nunca debe tapar el motivo del fallo.
  printf '%s\n' "$line" | tee -a "$RUN_LOG" 2>/dev/null || printf '%s\n' "$line"
}
fail() { STATUS_STAGE="fatal"; STATUS_MESSAGE="$*"; log "ERROR: $*"; exit 1; }

# Escapa un string para incrustarlo en JSON sin depender de node.
# Ojo: `printf '%s'` (sin \n) + awk se traga las strings de una sola línea, así
# que se usa el idiom de sed para juntar las líneas y recién ahí escapar.
json_escape() {
  printf '%s\n' "${1:-}" \
    | sed -e 's/\\/\\\\/g' \
          -e 's/"/\\"/g' \
          -e 's/\t/\\t/g' \
          -e 's/\r//g' \
          -e ':a;N;$!ba;s/\n/\\n/g'
}

# Escribe el estado y lo pushea a main. Best effort: si el reporter falla, la
# corrida real no debe quedar marcada como fallida por culpa del reporter.
publish_status() {
  local rc="$1" ok="false" now dur head tmp
  [ "$rc" -eq 0 ] && ok="true"
  now="$(date -u +%s)"
  dur=$(( now - START_EPOCH ))

  head="null"
  if [ -d "$REPO_DIR/.git" ]; then
    head="\"$(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo null)\""
  fi

  tmp="$(mktemp)"
  cat >"$tmp" <<JSON
{
  "updatedAt": "$(date -u +%FT%TZ)",
  "ok": $ok,
  "stage": "$(json_escape "$STATUS_STAGE")",
  "message": "$(json_escape "$STATUS_MESSAGE")",
  "model": "$(json_escape "$MODEL")",
  "agentRc": ${AGENT_RC:-null},
  "exitCode": $rc,
  "durationSec": $dur,
  "logFile": "$(json_escape "$RUN_LOG_NAME")",
  "head": $head
}
JSON

  if cmp -s "$tmp" "$REPO_DIR/$STATUS_REL" 2>/dev/null; then
    log "status sin cambios, no hace falta commit"
  else
    mkdir -p "$REPO_DIR/src/data"
    cp "$tmp" "$REPO_DIR/$STATUS_REL"
    if git -C "$REPO_DIR" add "$STATUS_REL" 2>>"$RUN_LOG" \
      && git -C "$REPO_DIR" diff --cached --quiet 2>>"$RUN_LOG"; then
      log "status sin cambios, no hace falta commit"
    else
      git -C "$REPO_DIR" commit -q \
        -m "chore(agente): estado de la corrida semanal $(date -u +%F)" \
        >>"$RUN_LOG" 2>&1 || { log "WARN: no se pudo commitear el estado"; return 0; }
      if git -C "$REPO_DIR" push origin "$BRANCH" >>"$RUN_LOG" 2>&1; then
        log "estado publicado en $STATUS_REL"
      else
        log "WARN: no se pudo pushear el estado (ver $RUN_LOG)"
      fi
    fi
  fi
  rm -f "$tmp"
}

on_exit() {
  local rc=$?
  set +e
  log "exit=$rc"
  [ "$STATUS_PUBLISH" -eq 1 ] && publish_status "$rc"
  exit "$rc"
}
# Un comando que muere por `set -e` sin pasar por fail() igual tiene que dejar
# un estado legible, no un "corrida iniciada" colgado para siempre.
on_err() {
  STATUS_STAGE="inesperado"
  STATUS_MESSAGE="fallo no controlado en la línea ${1:-?} del runner (revisar el log $RUN_LOG_NAME)"
  log "ERROR: $STATUS_MESSAGE"
}
trap 'on_err $LINENO' ERR
trap on_exit EXIT

# ---------------------------------------------------------------- lock
# Sin flock el `exec 9>` + `flock -n` falla y el script se saltearía toda la
# corrida en silencio (parecería un lock ocupado). Tiene que ser fatal.
command -v flock >/dev/null 2>&1 || { STATUS_STAGE="fatal"; STATUS_MESSAGE="flock no encontrado (paquete util-linux)"; log "ERROR: $STATUS_MESSAGE"; exit 1; }
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  # Hay otra corrida en curso: NO tocar el estado, corresponde a esa corrida.
  STATUS_PUBLISH=0
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
cd "$REPO_DIR" || fail "no se puede entrar al repo ($REPO_DIR)"
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

# El dist no puede venir de una corrida anterior: `dist/` está fuera de git y
# `git reset --hard` no lo toca. Si un build viejo dejó dist/rankings/index.html,
# la verificación de abajo pasaría siempre y el estado mentiría. Borrarlo es la
# única forma de que "existe dist/rankings/index.html" signifique "el build de
# ESTA corrida lo generó".
if [ -d dist ]; then
  rm -rf dist
  log "dist/ borrado (el build del agente tiene que regenerarlo)"
fi

# --------------------------------------------------- ejecución del agente
PROMPT='Ejecutá el procedimiento completo de ranking semanal de iapo.cl.
Esta es una ejecución AUTOMÁTICA PROGRAMADA: el push a origin/main está autorizado.
Snapshot: usá la fecha actual en runtime. Escribí src/content/rankings/ranking-YYYY-MM-DD.md,
validá con npm run build (exit 0), y hacé commit + push a main.
Al terminar respondé con el formato de salida obligatorio del procedimiento.'

# La salida de opencode va a su propio archivo para poder citar el motivo real
# del fallo en el estado. Hasta el 2026-10-18 el estado decía "el build no generó
# dist/rankings/index.html" mientras la causa era que opencode moría en 5
# segundos porque el modelo no tenía acceso: el mensaje culpaba al build y
# escondió la causa real durante cinco semanas.
AGENT_OUT="${RUN_LOG%.log}-agent.log"
log "corriendo opencode run (máx ${TIMEOUT_MIN} min)…"
set +e
timeout --signal=SIGINT --kill-after=5m "${TIMEOUT_MIN}m" \
  opencode run --agent weekly-ranking --model "$MODEL" --auto --title "Ranking semanal automático" "$PROMPT" \
  >"$AGENT_OUT" 2>&1
AGENT_RC=$?
set -e
cat "$AGENT_OUT" >>"$RUN_LOG" 2>/dev/null || true
log "opencode terminó con rc=$AGENT_RC"

# La causa real del fallo del agente, tal cual la reportó opencode. Sin esto el
# estado solo puede decir "algo falló", que es lo que hacía inútil el reporte.
#
# opencode colorea su salida, así que el texto extraído viene con secuencias ANSI
# (ESC [ 91 m, etc.). Eso NO puede terminar dentro del JSON del estado: los bytes
# de control rompen el parseo del archivo y con él el build del sitio entero (pasó
# el 2026-10-19 y el deploy quedó rojo). Se limpian acá, antes de publicar.
strip_ansi() {
  tr -d '\r' | sed -E 's/\x1b\[[0-9;]*[A-Za-z]//g; s/\x1b\][^\x07]*\x07//g; s/\x1b[()][0-9A-Za-z]//g' | tr -d '\000-\010\013\014\016-\037'
}

if [ "$AGENT_RC" -ne 0 ]; then
  if [ "$AGENT_RC" -eq 124 ]; then
    AGENT_ERROR="timeout: no terminó en ${TIMEOUT_MIN} min"
  else
    AGENT_ERROR="$(grep -a -m1 -E 'Error|error:|denied|Insufficient|unauthorized|forbidden|not found' "$AGENT_OUT" 2>/dev/null | strip_ansi | cut -c1-180 || true)"
    [ -n "$AGENT_ERROR" ] || AGENT_ERROR="$(grep -a -v '^[[:space:]]*$' "$AGENT_OUT" 2>/dev/null | tail -n1 | strip_ansi | cut -c1-180 || true)"
  fi
  log "causa reportada por opencode: ${AGENT_ERROR:-desconocida}"
fi

# --------------------------------------------------- verificación post
log "verificando dist…"
DIST_INDEX="dist/rankings/index.html"
TODAY="$(date -u +%F)"

if [ "$AGENT_RC" -ne 0 ]; then
  # El agente murió: mirar dist no aporta nada y el mensaje anterior ("no hay
  # dist, culpa del build") era directamente falso.
  STATUS_STAGE="agente"
  STATUS_MESSAGE="opencode run falló (rc=$AGENT_RC): ${AGENT_ERROR:-ver $RUN_LOG_NAME}"
  exit 1
fi

if [ ! -f "$DIST_INDEX" ]; then
  # Llegó acá con rc=0 pero sin build: o no commiteó, o el build falló.
  STATUS_STAGE="verificacion"
  STATUS_MESSAGE="el agente terminó bien (rc=0) pero no generó $DIST_INDEX (no commiteó o el build falló)"
  exit 1
fi

if [ ! -f "dist/rankings/ranking-$TODAY/index.html" ]; then
  STATUS_STAGE="aviso"
  STATUS_MESSAGE="el build salió bien pero la edición del día quedó en otra fecha (esperaba ranking-$TODAY)"
  log "WARN: $STATUS_MESSAGE"
else
  STATUS_STAGE="ok"
  STATUS_MESSAGE="la edición del día se generó y quedó publicada"
fi

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

# El build verificado es lo que importa. Un rc distinto del agente se publica
# en el estado pero no rompe el timer, así systemd no acumula fallos cuando
# el agente terminó sin commits nuevos.
exit 0
