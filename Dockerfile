FROM n8nio/n8n:1.93.0

# Set working directory
WORKDIR /home/node

# Expose the port n8n runs on
EXPOSE 5678

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:5678/healthz || exit 1

# Command to run n8n
CMD ["n8n", "start"]