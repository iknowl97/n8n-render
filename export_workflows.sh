#!/usr/bin/env bash

# Script to export n8n workflows to a backup directory
# Usage: ./export_workflows.sh [backup_directory]

# Default export directory name with date
EXPORT_DIR=${1:-"n8n-backup-$(date +%Y%m%d-%H%M%S)"}

# Default data folder location
DATA_FOLDER=${DATA_FOLDER:-"/home/node/.n8n"}

# Default backup root directory
EXPORT_ROOT=${EXPORT_ROOT:-"./backups"}

# Create backup directory if it doesn't exist
mkdir -p "$EXPORT_ROOT"

set -euo pipefail

echo "Exporting n8n workflows to $EXPORT_ROOT/$EXPORT_DIR"

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  echo "Loading environment variables from .env file"
  export $(grep -v '^#' .env | xargs)
fi

# Run the export command
docker run \
    --rm \
    -v "$(pwd)/.env:/home/node/.env" \
    -v "${DATA_FOLDER}:/home/node/.n8n" \
    -v "$(pwd)/${EXPORT_ROOT}:/backup" \
    -e N8N_ENCRYPTION_KEY \
    -e GENERIC_TIMEZONE \
    -e TZ \
    -e DB_TYPE \
    -e DB_POSTGRESDB_DATABASE \
    -e DB_POSTGRESDB_HOST \
    -e DB_POSTGRESDB_PORT \
    -e DB_POSTGRESDB_USER \
    -e DB_POSTGRESDB_SCHEMA \
    -e DB_POSTGRESDB_PASSWORD \
    -u node \
    n8nio/n8n:latest \
    n8n export:workflow --backup --output=/backup/$EXPORT_DIR/ --data=/home/node/.n8n

echo "Export completed successfully to $EXPORT_ROOT/$EXPORT_DIR"
