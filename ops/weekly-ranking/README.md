# Agente semanal de rankings en el VPS

Ejecuta el agente `.opencode/agent/weekly-ranking.md` una vez por semana **dentro del VPS**,
sin depender de que tu laptop esté prendida ni de que haya una sesión de opencode abierta.

```
timer systemd (domingo 01:00 America/Santiago)
   └─ iapo-ranking.service  (Type=oneshot, usuario iapoagent)
        └─ /usr/local/bin/iapo-ranking-run
             ├─ git fetch + reset --hard origin/main
             ├─ npm ci (solo si cambió package-lock.json)
             ├─ opencode run --agent weekly-ranking
             └─ verifica dist/rankings/ y reporta commits sin pushear
                  └─ el agente commitea y pushea → dispara deploy.yml → VPS
```

## Componentes

| Archivo | Rol |
|---|---|
| `install.sh` | Bootstrap idempotente. Crea usuario de servicio, Node 22, opencode CLI, `auth.json`, deploy key SSH, clona el repo, instala el runner y activa el timer. |
| `run.sh` | Runner semanal. Se copia a `/usr/local/bin/iapo-ranking-run` desde el repo. |
| `iapo-ranking.service` | Unidad systemd `Type=oneshot` (el `.timer` se genera en `install.sh` porque la expresión de calendario es parametrizable). |
| `.github/workflows/bootstrap-vps-agent.yml` | `workflow_dispatch` que corre `install.sh` por SSH usando el secret `VPS_SSH_KEY`. |

## Bootstrap (una vez)

1. Crear el secret `MODEL_API_KEY` en el repo de GitHub (Settings → Secrets and variables → Actions).
2. Correr el workflow **Actions → bootstrap-vps-agent → Run workflow**.
3. El bootstrap imprime la deploy key pública. Copiarla en
   <https://github.com/LeonardoPS1/iapo/settings/keys> con **Allow write access** tildado.
4. Volver a correr el workflow: el `push test` debe dar `ok`.

Sin write access la key no puede pushear y el ranking no llega a producción — es el paso que
no se puede automatizar desde el lado del VPS.

## Operación

```bash
# estado del timer
systemctl list-timers iapo-ranking.timer

# última ejecución
journalctl -u iapo-ranking.service -n 100 --no-pager
tail -n 100 /var/log/iapo-agent/*-run.log

# forzar una ejecución ahora
systemctl start iapo-ranking.service

# cambiar la hora (ej: martes 12:00 hora Chile)
sudo sed -i 's/^OnCalendar=.*/OnCalendar=Tue *-*-* 12:00:00 America\/Santiago/' /etc/systemd/system/iapo-ranking.timer
sudo systemctl daemon-reload

# desactivar
sudo systemctl disable --now iapo-ranking.timer
```

## Parámetros

Se cambian en `/etc/iapo-agent/secrets.env` (root:iapoagent, 640) y se aplican con
`sudo systemctl daemon-reload` + reinicio del servicio.

| Variable | Default | Qué es |
|---|---|---|
| `MODEL_API_KEY` | — | API key del provider `opencode`. |
| `IAPO_MODEL` | `opencode/big-pickle` | `provider/model` que ejecuta el agente. |
| `IAPO_REPO_DIR` | `/opt/iapo-agent/repo` | Clone de trabajo. |
| `IAPO_TIMEOUT_MIN` | `25` | Tope de la corrida del agente. |
| `IAPO_CRON` | `Sun *-*-* 01:00:00 America/Santiago` | Calendario del timer (hora Chile, UTC-3), aplicado por `install.sh`. |

## Notas

- **No duplicar.** El job local de Windows `weekly-ranking` tiene que estar desactivado; si no,
  los dos corren el domingo a la misma hora y compiten por el push a `main`.
- **Veracidad.** El agente tiene reglas duras: si una fuente no entrega el dato, la lista se omite
  con nota. Un ranking incompleto es preferible a uno inventado.
- **Reintentos.** `Persistent=true` corre el job perdido al reiniciar el VPS, con un
  `RandomizedDelaySec=300` para no golpear GitHub siempre a la misma hora.
- **Logs.** Cada corrida deja un archivo fechado en `/var/log/iapo-agent/`; el servicio escribe
  además en el journal de systemd.
- **Rollback.** El repo del agente es un clon independiente del de Dokploy
  (`/etc/dokploy/applications/iapo-iapo-srsxbv/code`): si una edición sale mal, `git revert` en
  main y el deploy vuelve al estado anterior.
