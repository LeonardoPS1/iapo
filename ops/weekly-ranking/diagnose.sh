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
h "Toolchain"
echo "node:    $(command -v node >/dev/null && node -v || echo AUSENTE)"
echo "opencode:$(command -v opencode >/dev/null && echo " $(opencode --version 2>&1 | head -n1)" || echo ' AUSENTE')"
echo "git:     $(git --version 2>&1)"

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
  echo "HEAD: $(git -C "$REPO_DIR" rev-parse --short HEAD 2>&1)"
  echo "último commit: $(git -C "$REPO_DIR" log -1 --pretty='%s (%cr)' 2>&1)"
  echo "commits sin pushear: $(git -C "$REPO_DIR" rev-list --count origin/main..HEAD 2>&1)"
  echo "últimos 5 commits:"
  git -C "$REPO_DIR" log -5 --pretty='  %h %cr %s' 2>&1
  echo
  echo "cambios sin commitear:"
  git -C "$REPO_DIR" status --porcelain 2>&1 | head -n 20
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
