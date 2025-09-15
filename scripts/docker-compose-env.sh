#!/bin/bash
# This script passes all currently defined environment variables to docker compose up or restart

# Usage: ./scripts/docker-compose-env.sh [up|restart] [service]

set -e

ACTION="${1:-up}"
SERVICE="${2:-}"

# Export all environment variables for MINIO to a .env file for docker-compose
printenv | grep "MINIO_"> scripts/.env

if [ "$ACTION" = "up" ]; then
  if [ -n "$SERVICE" ]; then
    docker compose up -d "$SERVICE"
  else
    docker compose up -d
  fi
elif [ "$ACTION" = "restart" ]; then
  if [ -n "$SERVICE" ]; then
    docker compose restart "$SERVICE"
  else
    docker compose restart
  fi
else
  echo "Usage: $0 [up|restart] [service]"
  exit 1
fi
