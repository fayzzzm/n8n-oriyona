# n8n Workflow Automation Platform

This is a Docker-based deployment of n8n with PostgreSQL for DigitalOcean App Platform.

## Quick Start

1. The app will automatically deploy using Docker Compose
2. n8n will be available at the root URL
3. PostgreSQL database is included in the container

## Configuration

Environment variables are set in the DigitalOcean App Platform:
- `N8N_PASSWORD`: Admin password
- `N8N_HOST`: App hostname
- `WEBHOOK_URL`: HTTPS webhook URL

## Services

- **n8n**: Main workflow automation platform
- **postgres**: PostgreSQL database for n8n data

## Access

- **n8n Dashboard**: Root URL of the app
- **Admin Login**: admin / [N8N_PASSWORD] 