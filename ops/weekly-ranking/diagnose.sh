#!/usr/bin/env bash
# iapo.cl — diagnóstico del agente semanal de rankings.
# Corre en el VPS e imprime un reporte en markdown para pegar en un issue.
#
# Regla dura: NUNCA imprime el contenido de secrets.env ni de auth.json.
# Solo existencia, permisos y las variables que no son secretas.
set -uo pipefail

LOG_DIR="${IAPO_LOG_DIR:-/var/log/iapo-agent}"
REPO_DIR="${IAPO_REPO_DIR:-/opt/iapo-agent/repo}"
SECRETS_FILE="/etc/iapo-agent/secrets.env"
TIMER="iapo-ranking.timer"
SERVICE="iapo-ranking.service"
MAX_LINES="${DIAG_MAX_LINES:-150}"
AGENT_USER="${AGENT_USER:-iapoagent}"
AGENT_HOME="/home/$AGENT_USER"
AGENT_PATH="$AGENT_HOME/.opencode/bin:$AGENT_HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

# Los chequeos de toolchain y de git se hacen COMO el usuario de servicio, no
# como root. La primera versión de este script corría todo como root y mentir:
# reportaba "opencode: AUSENTE" (vive en ~/.opencode/bin, fuera del PATH de
# root) y cuatro "dubious ownership" de git (el repo es de iapoagent). Dos
# alarmas falsas tapando la causa real. Verificar en el mismo contexto en el
# que corre el runner es la única forma de que el reporte diga la verdad.
as_agent() { runuser -u "$AGENT_USER" -- env HOME="$AGENT_HOME" PATH="$AGENT_PATH" "$@" 2>&1; }

h() { printf '\n## %s\n\n```\n' "$*"; }
end() { printf '```\n'; }
run() { "$@" 2>&1 | head -n "$MAX_LINES" || true; }
exists() { [ -e "$1" ] && echo "presente" || echo "AUSENTE"; }

printf '# Diagnóstico del agente semanal\n'

# ------------------------------------------------------------- 1. timer
h "Timer ($TIMER)"
echo "is-enabled: $(systemctl is-enabled "$TIMER" 2>&1)"
echo "is-active:  $(systemctl is-active "$TIMER" 2>&1)"
echo "calendario: $(systemctl show "$TIMER" -p TimersCalendar --value 2>/dev/null)"
echo "unit file:  $(systemctl show "$TIMER" -p FragmentPath --value 2>/dev/null)"
echo
systemctl list-timers "$TIMER" --no-pager 2>&1 | head -n 5

# ------------------------------------------------- 2. último servicio
h "Última ejecución del servicio"
for p in Result ExecMainStatus ExecMainCode ExecMainStartTimestamp ExecMainExitTimestamp InactiveEnterTimestamp; do
  printf '%s: %s\n' "$p" "$(systemctl show "$SERVICE" -p "$p" --value 2>/dev/null)"
done

# -------------------------------------------------------- 3. journal
h "journalctl del servicio (últimas $MAX_LINES líneas)"
journalctl -u "$SERVICE" -n "$MAX_LINES" --no-pager -o short-iso 2>&1

# ------------------------------------------------- 4. logs en disco
h "Logs en $LOG_DIR"
# El 2026-09-27 el runner murió en `mkdir -p $LOG_DIR` con "Permission denied"
# (su padre /var/log es de root) y no dejó ni log ni estado. Por eso se prueba
# la escritura real como el usuario de servicio y no solo la existencia.
if [ -d "$LOG_DIR" ]; then
  echo "directorio: $(stat -c '%a %U:%G' "$LOG_DIR")"
  if as_agent test -w "$LOG_DIR"; then
    echo "escritura por $AGENT_USER: OK"
  else
    echo "escritura por $AGENT_USER: FALLOSA (causa raíz del fallo del 2026-09-27)"
    echo "  fix: install -d -m 0750 -o $AGENT_USER -g $AGENT_USER $LOG_DIR"
  fi
else
  echo "directorio: NO EXISTE (el runner no puede crear logs; en /var/log no puede)"
fi
echo
ls -l "$LOG_DIR" 2>&1 | tail -n 15
LATEST="$(ls -1t "$LOG_DIR"/*-run.log 2>/dev/null | head -n 1 || true)"
if [ -n "$LATEST" ]; then
  printf '\n### Contenido de %s (últimas %s líneas)\n\n```\n' "$(basename "$LATEST")" "$MAX_LINES"
  tail -n "$MAX_LINES" "$LATEST" 2>&1
  printf '```\n'
else
  printf '\n_Sin logs de corrida: el runner nunca llegó a ejecutarse._\n'
fi

# ------------------------------------------------------- 5. toolchain
h "Toolchain (en el contexto del usuario de servicio $AGENT_USER)"
echo "node:    $(as_agent node -v || echo AUSENTE)"
echo "opencode:$(as_agent opencode --version 2>&1 | head -n1 || true)"
[ -x "$AGENT_HOME/.opencode/bin/opencode" ] || echo "opencode: binario no encontrado en $AGENT_HOME/.opencode/bin"
echo "git:     $(as_agent git --version || echo AUSENTE)"

# --------------------------------------------------------- 6. config
h "Configuración (solo variables no secretas)"
if [ -f "$SECRETS_FILE" ]; then
  grep -E '^(IAPO_MODEL|IAPO_CRON|IAPO_REPO_DIR|IAPO_TIMEOUT_MIN|IAPO_BRANCH)=' "$SECRETS_FILE" 2>&1 || echo "(sin variables IAPO_*)"
else
  echo "$SECRETS_FILE AUSENTE"
fi
echo
echo "secretos: $SECRETS_FILE -> $(exists "$SECRETS_FILE") ($(stat -c '%a %U:%G' "$SECRETS_FILE" 2>/dev/null || echo '?'))"
AUTH="$(ls -1 /home/iapoagent/.local/share/opencode/auth.json 2>/dev/null | head -n1)"
echo "auth.json: ${AUTH:-AUSENTE} -> $(exists "${AUTH:-/nonexistent}") ($(stat -c '%a %U:%G' "$AUTH" 2>/dev/null || echo '-'))"
echo "(contenido omitido a propósito)"

# --------------------------------------------------------- 7. repo
h "Repo del agente"
if [ -d "$REPO_DIR/.git" ]; then
  echo "HEAD: $(as_agent git -C "$REPO_DIR" rev-parse --short HEAD)"
  echo "último commit: $(as_agent git -C "$REPO_DIR" log -1 --pretty='%s (%cr)')"
  echo "commits sin pushear: $(as_agent git -C "$REPO_DIR" rev-list --count origin/main..HEAD)"
  echo "últimos 5 commits:"
  as_agent git -C "$REPO_DIR" log -5 --pretty='  %h %cr %s'
  echo
  echo "cambios sin commitear:"
  as_agent git -C "$REPO_DIR" status --porcelain | head -n 20
  echo
  echo "contenido de src/content/rankings:"
  ls -1 "$REPO_DIR/src/content/rankings" 2>&1 | head -n 20
  echo
  echo "dist construido: $([ -f "$REPO_DIR/dist/rankings/index.html" ] && echo sí || echo NO)"
else
  echo "$REPO_DIR AUSENTE (el bootstrap no terminó)"
fi

# --------------------------------------------- 8. estado publicado
h "Estado publicado en el repo"
if [ -f "$REPO_DIR/src/data/agent-status.json" ]; then
  cat "$REPO_DIR/src/data/agent-status.json" 2>&1
else
  echo "(el runner todavía no publicó estado: es la versión anterior al cambio)"
fi
