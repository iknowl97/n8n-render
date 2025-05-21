#!/usr/bin/env bash

# Script to export n8n workflows and credentials to a backup directory
# Usage: ./export_workflows.sh [backup_directory]

# Default export directory name with date
EXPORT_DIR=${1:-"n8n-backup-$(date +%Y%m%d-%H%M%S)"}

# Default data folder location
DATA_FOLDER=${DATA_FOLDER:-"/home/node/.n8n"}

# Default backup root directory
EXPORT_ROOT=${EXPORT_ROOT:-"./backups"}

# Create backup directory if it doesn't exist
mkdir -p "$EXPORT_ROOT/$EXPORT_DIR"

set -euo pipefail

echo "Exporting n8n workflows to $EXPORT_ROOT/$EXPORT_DIR"

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  echo "Loading environment variables from .env file"
  export $(grep -v '^#' .env | xargs)
fi

# Backup the encryption key
if [ -n "${N8N_ENCRYPTION_KEY:-}" ]; then
  echo "Backing up encryption key..."
  echo "N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}" > "$EXPORT_ROOT/$EXPORT_DIR/encryption_key.env"
  echo "IMPORTANT: Keep this file secure as it contains your encryption key!" >> "$EXPORT_ROOT/$EXPORT_DIR/encryption_key.env"
  echo "Encryption key backed up to $EXPORT_ROOT/$EXPORT_DIR/encryption_key.env"
else
  echo "WARNING: N8N_ENCRYPTION_KEY not found in environment. Credentials may not be recoverable without it!"
fi

# Run the export command for workflows
echo "Exporting workflows..."
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
    n8nio/n8n:1.93.0 \
    n8n export:workflow --backup --output=/backup/$EXPORT_DIR/ --data=/home/node/.n8n

# Run the export command for credentials (decrypted for better recovery options)
echo "Exporting credentials..."
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
    n8nio/n8n:1.93.0 \
    n8n export:credentials --output=/backup/$EXPORT_DIR/credentials.json --decrypted --data=/home/node/.n8n

echo "Export completed successfully to $EXPORT_ROOT/$EXPORT_DIR"
echo "IMPORTANT: The backup includes your encryption key and decrypted credentials. Keep this directory secure!"
