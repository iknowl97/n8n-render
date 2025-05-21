FROM n8nio/n8n:latest

# Set working directory
WORKDIR /home/node

# Expose the port n8n runs on
EXPOSE 5678

# Command to run n8n
CMD ["n8n", "start"]