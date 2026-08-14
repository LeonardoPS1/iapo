#!/usr/bin/env bash
# Deploy manual de iapo.cl directo por SSH, sin pasar por la UI de Dokploy.
# Úsalo solo como plan B si algo falla en Dokploy — el camino recomendado
# sigue siendo Dokploy (ver README.md), porque te da rollback, logs y
# redeploy automático por webhook sin esfuerzo extra.
#
# Uso: ejecutar DENTRO del VPS, parado en la carpeta del repo clonado.
#   git clone <tu-repo> iapo && cd iapo
#   chmod +x deploy.sh
#   ./deploy.sh

set -euo pipefail

IMAGE_NAME="iapo-site"
CONTAINER_NAME="iapo-site"
HOST_PORT="8091"   # puerto libre en el VPS; Traefik/Dokploy lo enruta desde afuera

echo "→ Actualizando código..."
git pull

echo "→ Construyendo imagen Docker..."
docker build -t "$IMAGE_NAME" .

echo "→ Deteniendo contenedor anterior (si existe)..."
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "→ Levantando contenedor nuevo..."
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "127.0.0.1:${HOST_PORT}:80" \
  "$IMAGE_NAME"

echo "→ Listo. Contenedor corriendo en 127.0.0.1:${HOST_PORT}"
echo "→ Falta: apuntar Traefik/Nginx externo a ese puerto para servir iapo.cl con SSL."
echo "  Si ya tienes un Nginx/Traefik reverse proxy corriendo fuera de Dokploy,"
echo "  agrega un server block o router apuntando a 127.0.0.1:${HOST_PORT}."
