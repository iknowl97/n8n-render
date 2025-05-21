# n8n on Render

This repository contains configuration files for deploying [n8n](https://n8n.io/) (a workflow automation tool) to [Render.io](https://render.com/) using Docker. It's designed to provide a seamless deployment experience with persistent storage and custom domain support.

## Features

- Ready-to-deploy configuration for Render.io
- Persistent data storage using Render Disks
- PostgreSQL database integration
- Custom domain support (configured for n8nalter.ddns.net)
- Automatic SSL/TLS certificate management
- Environment variable management
- Local development environment with Docker Compose

## Deployment Instructions

### Deploy to Render

1. Fork or clone this repository to your GitHub account
2. Log in to your Render dashboard
3. Click on "New" and select "Blueprint"
4. Connect your GitHub account and select this repository
5. Follow the prompts to deploy the application
6. When prompted, enter a secure value for `N8N_ENCRYPTION_KEY` (you can generate one with `openssl rand -hex 24`)

### Configure Custom Domain

1. After deployment, go to your service dashboard in Render
2. Navigate to the "Settings" tab
3. Scroll down to the "Custom Domains" section
4. Add your domain (n8nalter.ddns.net)
5. Follow Render's instructions to configure DNS settings for your domain

### Environment Variables

Most environment variables are pre-configured in the `render.yaml` file. However, you may want to customize some values:

- `N8N_ENCRYPTION_KEY`: Set during deployment (keep this secure and consistent)
- `GENERIC_TIMEZONE` and `TZ`: Set to your preferred timezone
- `N8N_LOG_LEVEL`: Set to desired logging level (info, verbose, debug)

## Local Development

To test the application locally before deploying to Render:

1. Clone this repository
2. Copy `.env.example` to `.env` and update the values as needed
3. Run `docker-compose up -d`
4. Access n8n at https://iknowl-n8n.onrender.com

## Data Persistence

This configuration uses Render Disks for persistent storage. The n8n data is stored at `/home/node/.n8n` in the container, which is mounted to a persistent disk. The PostgreSQL database also uses persistent storage.

## Maintenance

### Updating n8n

To update n8n to the latest version:

1. Update the Dockerfile if needed (the current configuration uses the latest tag)
2. Commit and push your changes
3. Render will automatically rebuild and deploy the updated version

### Backing Up Data

You can use the included `export_workflows.sh` script to export your workflows:

1. Modify the script with your environment details
2. Run the script to export workflows to a backup directory

## Troubleshooting

### Common Issues

- **Database Connection Issues**: Check that the database environment variables are correctly set
- **Webhook URL Problems**: Ensure that `WEBHOOK_URL` is set to your domain with https protocol
- **Persistent Storage Issues**: Verify that the disk is mounted at `/home/node/.n8n`

## Security Considerations

- Always use a strong, unique `N8N_ENCRYPTION_KEY`
- Keep your database credentials secure
- Regularly update n8n to the latest version
- Consider implementing IP restrictions for your database if needed

## Version Information

This configuration uses n8n's latest Docker image. Check the [n8n Docker Hub page](https://hub.docker.com/r/n8nio/n8n) for version details.
