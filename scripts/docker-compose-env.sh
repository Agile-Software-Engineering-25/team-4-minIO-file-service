#!/bin/bash
# This script passes all currently defined environment variables to docker compose up or restart

set -e

# Usage: ./scripts/docker-compose-env.sh [up|restart] [service]

ACTION="${1:-up}"
SERVICE="${2:-}"

# Export all current environment variables to a .env file for docker compose
printenv > .env

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
