# n8n on Render

This repository contains configuration files for deploying [n8n](https://n8n.io/) (a workflow automation tool) to [Render.io](https://render.com/) using Docker. It's designed to provide a seamless deployment experience with persistent storage and custom domain support.

## Features

- Ready-to-deploy configuration for Render.io
- Persistent data storage using Render Disks
- PostgreSQL database integration
- Custom domain support
- Automatic SSL/TLS certificate management
- Environment variable management
- Local development environment with Docker Compose
- Enhanced encryption key management
- Comprehensive backup solution

## Deployment Instructions

### Deploy to Render

1. Fork or clone this repository to your GitHub account
2. Log in to your Render dashboard
3. Click on "New" and select "Blueprint"
4. Connect your GitHub account and select this repository
5. Follow the prompts to deploy the application
6. **CRITICAL**: When prompted for `N8N_ENCRYPTION_KEY`, generate a secure value with `openssl rand -hex 24`
   - **SAVE THIS KEY SECURELY** - you will need it for future deployments
   - If redeploying an existing instance, you MUST use the same key as before

### Configure Custom Domain

1. After deployment, go to your service dashboard in Render
2. Navigate to the "Settings" tab
3. Scroll down to the "Custom Domains" section
4. Add your domain
5. Follow Render's instructions to configure DNS settings for your domain

## Encryption Key Management

### Why This Is Critical

The `N8N_ENCRYPTION_KEY` is used to encrypt all credentials stored in n8n. If this key changes between deployments:

- All stored credentials will become unusable
- You'll see errors like "Credentials could not be decrypted"
- Workflows using those credentials will fail

### Best Practices

1. **Generate a Strong Key**: Use `openssl rand -hex 24` to create a secure key
2. **Store Securely**: Save this key in a password manager or secure vault
3. **Consistent Usage**: Always use the same key for the same n8n instance
4. **Backup Your Key**: Include it in your backup strategy (the updated `export_workflows.sh` does this)
5. **Document Your Key**: Keep a secure record of which key is used for which deployment

### Recovering From Key Issues

If you've lost access to credentials due to a key change:

1. If you have the old key, set it back in the environment variables
2. If you have a backup with decrypted credentials, restore from that backup
3. If neither is possible, you'll need to recreate all credentials

## Environment Variables

Most environment variables are pre-configured in the `render.yaml` file. However, you may want to customize some values:

- `N8N_ENCRYPTION_KEY`: **CRITICAL** - Set during deployment (keep this secure and consistent)
- `GENERIC_TIMEZONE` and `TZ`: Set to your preferred timezone
- `N8N_LOG_LEVEL`: Set to desired logging level (info, verbose, debug)

## Local Development

To test the application locally before deploying to Render:

1. Clone this repository
2. Copy `.env.example` to `.env` and update the values as needed
3. Run `docker-compose up -d`
4. Access n8n at http://localhost:5678

## Data Persistence

This configuration uses Render Disks for persistent storage. The n8n data is stored at `/home/node/.n8n` in the container, which is mounted to a persistent disk. The PostgreSQL database also uses persistent storage.

### Critical Files to Persist

- `/home/node/.n8n/config`: Contains the encryption key if not set via environment variable
- `/home/node/.n8n/database.sqlite`: Default database if not using PostgreSQL
- PostgreSQL data directory for workflow and credential storage

## Maintenance

### Updating n8n

To update n8n to a new version:

1. Update the Dockerfile to specify the desired version (e.g., `FROM n8nio/n8n:1.93.0`)
2. Commit and push your changes
3. Render will automatically rebuild and deploy the updated version
4. **IMPORTANT**: Ensure the `N8N_ENCRYPTION_KEY` remains the same during updates

### Backing Up Data

You can use the enhanced `export_workflows.sh` script to export your workflows and credentials:

1. Run the script to export workflows, credentials, and encryption key to a backup directory
2. The script now includes:
   - Workflow export
   - Credentials export (decrypted for recovery)
   - Encryption key backup
   - Consistent versioning with the Docker image

## Troubleshooting

### Common Issues

#### Credentials Could Not Be Decrypted

This error occurs when the encryption key has changed between deployments.

**Solution**:

1. Check if you have the original encryption key
2. Update the `N8N_ENCRYPTION_KEY` environment variable with the original key
3. Restart the n8n service
4. If the original key is lost, you'll need to recreate all credentials

#### Database Connection Issues

**Solution**:

1. Verify database environment variables in `render.yaml` or `.env`
2. Check that the PostgreSQL service is running and healthy
3. Ensure the database user has proper permissions

#### Webhook URL Problems

**Solution**:

1. Ensure that `WEBHOOK_URL` is set to your domain with https protocol
2. Verify your custom domain is properly configured in Render
3. Check that your DNS settings are correct

#### Persistent Storage Issues

**Solution**:

1. Verify that the disk is mounted at `/home/node/.n8n`
2. Check Render logs for any disk mounting errors
3. Ensure the disk has sufficient space

## Security Considerations

- **Encryption Key**: Always use a strong, unique `N8N_ENCRYPTION_KEY` and keep it secure
- **Database Credentials**: Keep your database credentials secure
- **Regular Updates**: Update n8n regularly to get security patches
- **Backup Security**: Secure your backups as they contain sensitive information
- **Access Control**: Consider implementing IP restrictions for your database if needed

## Version Information

This configuration uses n8n version 1.93.0. For the latest version information, check the [n8n Docker Hub page](https://hub.docker.com/r/n8nio/n8n).
