#!/bin/bash

echo "🔧 n8n Webhook URL Fix Tool"
echo "==========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Restarting HTTPS tunnel to get a fresh URL...${NC}"

# Kill existing tunnel
echo "Stopping existing tunnel..."
pkill -f cloudflared 2>/dev/null
sleep 2

# Start new tunnel
echo "Starting new tunnel..."
./start-tunnel.sh &
TUNNEL_PID=$!

# Wait for tunnel to start
echo "Waiting for tunnel to start..."
sleep 8

# Check if tunnel is running
if ps -p $TUNNEL_PID > /dev/null; then
    echo -e "${GREEN}✅ Tunnel restarted successfully${NC}"
    echo ""
    echo -e "${BLUE}📋 Look for the new URL in the cloudflared output above${NC}"
    echo -e "${BLUE}💡 Use that URL for your Telegram webhook${NC}"
    echo ""
    echo -e "${YELLOW}🔧 To fix the webhook in n8n:${NC}"
    echo "1. Go to your Telegram Trigger node in n8n"
    echo "2. Click 'Set Webhook'"
    echo "3. Use the new HTTPS URL from above"
    echo "4. Test the webhook"
    echo ""
    echo -e "${GREEN}✅ Your webhook should now work!${NC}"
else
    echo -e "${RED}❌ Failed to restart tunnel${NC}"
    echo "Please run: ./start-tunnel.sh manually"
fi 