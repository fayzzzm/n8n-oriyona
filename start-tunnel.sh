#!/bin/bash

echo "Starting cloudflared tunnel for n8n..."
echo "This will create an HTTPS URL that Telegram can use for webhooks."
echo ""

# Kill any existing cloudflared processes
pkill -f cloudflared 2>/dev/null

# Start cloudflared tunnel
echo "Starting tunnel..."
cloudflared tunnel --url http://localhost:5678

echo ""
echo "Tunnel started! Your n8n instance is now available at the URL shown above."
echo "You can now use this URL for Telegram webhooks."
echo "Press Ctrl+C to stop the tunnel." 