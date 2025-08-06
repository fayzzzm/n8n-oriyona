#!/bin/bash

# Auto-update Webhook URL Script
# This script automatically updates n8n configuration when tunnel URL changes

echo "🔄 Auto-update Webhook URL for n8n"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to get current tunnel URL
get_tunnel_url() {
    if [ -f "./tunnel.log" ]; then
        TUNNEL_URL=$(grep "trycloudflare.com" ./tunnel.log | tail -1 | grep -o 'https://[^[:space:]]*' | head -1)
        echo "$TUNNEL_URL"
    else
        echo ""
    fi
}

# Function to update docker-compose.yml
update_docker_compose() {
    local new_url="$1"
    
    if [ -z "$new_url" ]; then
        echo -e "${RED}❌ No tunnel URL provided${NC}"
        return 1
    fi
    
    # Extract hostname from URL
    HOSTNAME=$(echo "$new_url" | sed 's|https://||' | sed 's|/.*||')
    
    echo -e "${YELLOW}🔄 Updating docker-compose.yml with new tunnel URL...${NC}"
    echo "New URL: $new_url"
    echo "Hostname: $HOSTNAME"
    
    # Create backup of current docker-compose.yml
    cp docker-compose.yml docker-compose.yml.backup
    
    # Update the WEBHOOK_URL in docker-compose.yml
    sed -i.bak "s|WEBHOOK_URL=https://[^/]*/|WEBHOOK_URL=$new_url/|g" docker-compose.yml
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ docker-compose.yml updated successfully${NC}"
        
        # Restart n8n to apply new configuration
        echo -e "${YELLOW}🔄 Restarting n8n to apply new webhook URL...${NC}"
        docker compose down && docker compose up -d
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ n8n restarted successfully${NC}"
            echo ""
            echo -e "${BLUE}📋 Your webhook URL is now:${NC}"
            echo "   $new_url/webhook/[your-webhook-id]"
            echo ""
            echo -e "${GREEN}✅ Telegram webhook should now work!${NC}"
            return 0
        else
            echo -e "${RED}❌ Failed to restart n8n${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Failed to update docker-compose.yml${NC}"
        return 1
    fi
}

# Function to monitor tunnel and auto-update
monitor_and_update() {
    echo -e "${BLUE}🔍 Monitoring tunnel for URL changes...${NC}"
    echo "Press Ctrl+C to stop"
    echo ""
    
    LAST_URL=""
    
    while true; do
        CURRENT_URL=$(get_tunnel_url)
        
        if [ -n "$CURRENT_URL" ] && [ "$CURRENT_URL" != "$LAST_URL" ]; then
            echo -e "${YELLOW}🔄 Tunnel URL changed: $CURRENT_URL${NC}"
            update_docker_compose "$CURRENT_URL"
            LAST_URL="$CURRENT_URL"
        fi
        
        # Check every 10 seconds
        sleep 10
    done
}

# Main execution
echo -e "${YELLOW}📋 This script will:${NC}"
echo "1. Monitor the tunnel for URL changes"
echo "2. Automatically update n8n configuration"
echo "3. Restart n8n with the new webhook URL"
echo "4. Keep your Telegram webhook working"
echo ""

# Check if tunnel is running
if ! ps aux | grep -q "cloudflared tunnel"; then
    echo -e "${RED}❌ No cloudflared tunnel is running${NC}"
    echo "Please start the tunnel first:"
    echo "  ./start-reliable-tunnel.sh"
    exit 1
fi

echo -e "${GREEN}✅ Tunnel is running${NC}"

# Get current URL and update if needed
CURRENT_URL=$(get_tunnel_url)
if [ -n "$CURRENT_URL" ]; then
    echo -e "${GREEN}🌐 Current tunnel URL: $CURRENT_URL${NC}"
    
    # Ask if user wants to update now
    read -p "Update n8n configuration with this URL? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        update_docker_compose "$CURRENT_URL"
    else
        echo -e "${YELLOW}⏭️  Skipping update${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No tunnel URL found yet${NC}"
    echo "Waiting for tunnel to establish..."
fi

# Start monitoring
monitor_and_update 