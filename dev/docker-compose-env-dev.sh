#!/bin/bash
# This script passes all currently defined environment variables to docker compose up or restart

# Source .env file if present, then delete it
env_file=".env"
if [ -f "$env_file" ]; then
  echo "Sourcing environment variables from /.env"
  set -a
  if ! source "$env_file"; then
    echo "Failed to source /"$env_file" file. Exiting."
    exit 1
  fi
  set +a
else
  echo "WARNING: "$env_file" file not found. Proceeding with existing environment variables."
  exit 1
fi

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
