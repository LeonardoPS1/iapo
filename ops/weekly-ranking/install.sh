#!/usr/bin/env bash
# iapo.cl — bootstrap del agente semanal de rankings en el VPS.
# Idempotente: se puede volver a correr en cualquier momento sin romper nada.
#
# Uso (por SSH como ubuntu, con sudo):
#   sudo env MODEL_API_KEY=... bash /tmp/iapo-agent-bootstrap/install.sh
#
# Variables por entorno:
#   MODEL_API_KEY   secret de OpenCode (obligatorio la primera vez)
#   IAPO_REPO_DIR   default /opt/iapo-agent/repo
#   IAPO_MODEL      default opencode/big-pickle
#   IAPO_CRON       default "Sun *-*-* 01:00:00 America/Santiago"  (domingo 01:00 hora Chile)
#   AGENT_USER      default iapoagent
set -Eeuo pipefail

REPO_DIR="${IAPO_REPO_DIR:-/opt/iapo-agent/repo}"
AGENT_USER="${AGENT_USER:-iapoagent}"
MODEL="${IAPO_MODEL:-opencode/big-pickle}"
CRON="${IAPO_CRON:-Sun *-*-* 01:00:00 America/Santiago}"
SECRETS_DIR="/etc/iapo-agent"
SECRETS_FILE="$SECRETS_DIR/secrets.env"
AGENT_HOME="/home/$AGENT_USER"
AGENT_PATH="$AGENT_HOME/.opencode/bin:$AGENT_HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Corre un comando como el usuario de servicio, con HOME y PATH correctos
# (runuser funciona aunque el shell del usuario sea nologin; sudo -H no siempre).
as_agent() { runuser -u "$AGENT_USER" -- env HOME="$AGENT_HOME" PATH="$AGENT_PATH" "$@"; }

log() { printf '[%s] %s\n' "$(date -u +%FT%TZ)" "$*"; }
fail() { log "ERROR: $*"; exit 1; }

[ "$(id -u)" -eq 0 ] || fail "correr con sudo"
log "=== bootstrap iapo-agent (root) ==="
log "repo=$REPO_DIR model=$MODEL cron=$CRON"

# ---------------------------------------------------------- 1. usuario
if id "$AGENT_USER" >/dev/null 2>&1; then
  log "usuario $AGENT_USER ya existe"
else
  log "creando usuario de servicio $AGENT_USER (nologin, home $AGENT_HOME)"
  useradd --system --create-home --home-dir "$AGENT_HOME" --shell /usr/sbin/nologin "$AGENT_USER"
fi

# --------------------------------------------- 2. node >= 22 + opencode
install_node() {
  log "instalando Node 22 LTS vía NodeSource"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq curl ca-certificates gnupg >/dev/null
  install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list
  apt-get update -qq
  apt-get install -y -qq nodejs >/dev/null
  rm -f /etc/apt/sources.list.d/nodesource.list
}

if command -v node >/dev/null 2>&1 && [ "$(node -p 'process.versions.node.split(".")[0]')" -ge 22 ]; then
  log "node ya está: $(node -v)"
else
  install_node
  log "node instalado: $(node -v)"
fi

if as_agent opencode --version >/dev/null 2>&1; then
  log "opencode ya instalado: $(as_agent opencode --version)"
else
  log "instalando opencode CLI para $AGENT_USER"
  curl -fsSL https://opencode.ai/install | as_agent bash
  log "opencode instalado: $(as_agent opencode --version)"
fi

# ---------------------------------------------------------- 3. secrets
install -d -m 0750 -o root -g "$AGENT_USER" "$SECRETS_DIR"
if [ -f "$SECRETS_FILE" ]; then
  log "$SECRETS_FILE ya existe — se conserva la API key previa"
else
  [ -n "${MODEL_API_KEY:-}" ] || fail "falta MODEL_API_KEY y no existe $SECRETS_FILE"
  umask 077
  cat >"$SECRETS_FILE" <<EOF
# Generado por ops/weekly-ranking/install.sh. No commitear.
MODEL_API_KEY=$MODEL_API_KEY
IAPO_MODEL=$MODEL
IAPO_REPO_DIR=$REPO_DIR
EOF
  log "escrito $SECRETS_FILE"
fi
chown root:"$AGENT_USER" "$SECRETS_FILE"
chmod 640 "$SECRETS_FILE"

# ------------------------------------------------ 4. auth.json de opencode
AUTH_DIR="$AGENT_HOME/.local/share/opencode"
install -d -m 0700 -o "$AGENT_USER" -g "$AGENT_USER" "$AUTH_DIR"
if [ -f "$AUTH_DIR/auth.json" ]; then
  log "auth.json ya existe — se conserva"
else
  KEY="$(sed -n 's/^MODEL_API_KEY=//p' "$SECRETS_FILE" | head -1)"
  [ -n "$KEY" ] || fail "no se pudo leer MODEL_API_KEY de $SECRETS_FILE"
  log "generando auth.json (provider opencode) en $AUTH_DIR"
  as_agent env KEY="$KEY" bash -c '
    umask 077
    mkdir -p "$HOME/.local/share/opencode"
    printf "{\"opencode\":{\"type\":\"api\",\"key\":\"%s\"}}\n" "$KEY" \
      > "$HOME/.local/share/opencode/auth.json"
    chmod 600 "$HOME/.local/share/opencode/auth.json"'
  log "auth.json creado"
fi

# ------------------------------------ 5. deploy key SSH para push a GitHub
install -d -m 0700 -o "$AGENT_USER" -g "$AGENT_USER" "$AGENT_HOME/.ssh"
KEY_PATH="$AGENT_HOME/.ssh/id_ed25519"
NEW_KEY=0
if [ -f "$KEY_PATH" ]; then
  log "deploy key ya existe en $KEY_PATH"
else
  log "generando deploy key SSH para push a GitHub"
  as_agent ssh-keygen -t ed25519 -N "" -C "iapo-agent@vps" -f "$KEY_PATH"
  NEW_KEY=1
fi
chown "$AGENT_USER:$AGENT_USER" "$KEY_PATH" "$KEY_PATH.pub"
chmod 600 "$KEY_PATH"
chmod 644 "$KEY_PATH.pub"

# ---------------------------------------------------------- 6. repo
install -d -m 0755 -o "$AGENT_USER" -g "$AGENT_USER" "$(dirname "$REPO_DIR")"
if [ -d "$REPO_DIR/.git" ]; then
  log "repo existente — fetch + reset a origin/main"
  as_agent git -C "$REPO_DIR" fetch --prune origin main
  as_agent git -C "$REPO_DIR" reset --hard origin/main
else
  log "clonando repo en $REPO_DIR"
  as_agent git clone --branch main https://github.com/LeonardoPS1/iapo.git "$REPO_DIR"
fi
as_agent git -C "$REPO_DIR" config user.name  "iapo-agent"
as_agent git -C "$REPO_DIR" config user.email "agent@iapo.cl"
as_agent git -C "$REPO_DIR" config core.sshCommand "ssh -i $KEY_PATH -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
as_agent git -C "$REPO_DIR" remote set-url origin git@github.com:LeonardoPS1/iapo.git
chown -R "$AGENT_USER:$AGENT_USER" "$REPO_DIR"
log "repo listo en $REPO_DIR @ $(as_agent git -C "$REPO_DIR" rev-parse --short HEAD)"

# ---------------------------------------------------------- 7. runner
install -m 0755 -o root -g root "$REPO_DIR/ops/weekly-ranking/run.sh" /usr/local/bin/iapo-ranking-run
log "runner instalado en /usr/local/bin/iapo-ranking-run"

# ---------------------------------------------------------- 8. systemd
install -m 0644 -o root -g root "$SRC_DIR/iapo-ranking.service" /etc/systemd/system/iapo-ranking.service
cat >/etc/systemd/system/iapo-ranking.timer <<EOF
[Unit]
Description=Ranking semanal de iapo.cl (agente opencode)

[Timer]
OnCalendar=$CRON
Persistent=true
RandomizedDelaySec=300
Unit=iapo-ranking.service

[Install]
WantedBy=timers.target
EOF
chmod 0644 /etc/systemd/system/iapo-ranking.timer
log "timer generado con OnCalendar='$CRON'"

systemctl daemon-reload
systemctl enable --now iapo-ranking.timer

# ---------------------------------------------------------- 9. verificación
log "--- verificación ---"
systemctl list-timers iapo-ranking.timer --no-pager || true
echo
# Un OnCalendar inválido deja el timer sin cargar y el bootstrap "pasa" en verde
# sin que el agente corra nunca. Esto es fatal a propósito.
CAL="$(systemctl show iapo-ranking.timer -p TimersCalendar --value 2>/dev/null | head -1)"
[ -n "$CAL" ] || fail "el timer no cargó: OnCalendar='$CRON' es inválido (revisá el formato y la zona horaria)"
[ "$(systemctl is-active iapo-ranking.timer)" = "active" ] \
  || fail "el timer quedó $(systemctl is-active iapo-ranking.timer), se esperaba active"
as_agent node -v || fail "el usuario de servicio no puede ejecutar node"
as_agent opencode --version || fail "el usuario de servicio no puede ejecutar opencode"
[ -f "$REPO_DIR/.opencode/agent/weekly-ranking.md" ] \
  || fail "falta .opencode/agent/weekly-ranking.md en el clon"
[ -x /usr/local/bin/iapo-ranking-run ] || fail "el runner no quedó ejecutable"
echo

PUSH_TEST=ok
as_agent git -C "$REPO_DIR" push --dry-run origin HEAD:main >/dev/null 2>&1 || PUSH_TEST=fallo

log "--- resultado ---"
log "modelo:      $MODEL"
log "timer:       $(systemctl show iapo-ranking.timer -p TimersCalendar --value 2>/dev/null | head -1)"
log "push test:   $PUSH_TEST"
if [ "$PUSH_TEST" != ok ]; then
  log ""
  log "ACCIÓN PENDIENTE — registrar esta deploy key en GitHub:"
  log "  url:   https://github.com/LeonardoPS1/iapo/settings/keys/new"
  log "  title: iapo-agent@vps"
  log "  key:   $(cat "$KEY_PATH.pub")"
  log "  ☑ Allow write access  ← obligatorio, sin esto no puede pushear el ranking"
  log "Después volvé a correr este workflow: el push test debe dar 'ok'."
  exit 2
fi
log "=== bootstrap terminado - el agente corre automaticamente los $CRON ==="
