#!/bin/bash

# Auto-restart n8n after sleep mode
# This script monitors for sleep/wake events and restarts services

echo "🔄 Auto-restart n8n after sleep mode"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to restart services
restart_services() {
    echo -e "${YELLOW}🔄 Restarting services after sleep...${NC}"
    
    # Kill any existing cloudflared processes
    pkill -f cloudflared 2>/dev/null
    sleep 2
    
    # Restart n8n containers
    echo -e "${BLUE}📦 Restarting n8n containers...${NC}"
    docker compose down
    docker compose up -d
    
    # Wait for n8n to start
    echo -e "${BLUE}⏳ Waiting for n8n to start...${NC}"
    sleep 10
    
    # Check if n8n is running
    if curl -s http://localhost:5678 > /dev/null; then
        echo -e "${GREEN}✅ n8n is running${NC}"
    else
        echo -e "${RED}❌ n8n failed to start${NC}"
        return 1
    fi
    
    # Start new tunnel
    echo -e "${BLUE}🌐 Starting new tunnel...${NC}"
    ./start-reliable-tunnel.sh &
    TUNNEL_PID=$!
    
    # Wait for tunnel to start
    sleep 15
    
    # Get new tunnel URL
    if [ -f "./tunnel.log" ]; then
        NEW_URL=$(grep "trycloudflare.com" ./tunnel.log | tail -1 | grep -o 'https://[^[:space:]]*' | head -1)
        if [ -n "$NEW_URL" ]; then
            echo -e "${GREEN}🌐 New tunnel URL: $NEW_URL${NC}"
            
            # Update docker-compose.yml with new URL
            sed -i.bak "s|WEBHOOK_URL=https://[^/]*/|WEBHOOK_URL=$NEW_URL/|g" docker-compose.yml
            
            # Restart n8n with new URL
            docker compose down && docker compose up -d
            
            echo -e "${GREEN}✅ Services restarted successfully!${NC}"
            echo -e "${BLUE}📋 New webhook URL: $NEW_URL/webhook/[your-webhook-id]${NC}"
        else
            echo -e "${RED}❌ Failed to get new tunnel URL${NC}"
        fi
    fi
}

# Function to monitor sleep events
monitor_sleep() {
    echo -e "${BLUE}🔍 Monitoring for sleep/wake events...${NC}"
    echo "This script will automatically restart services when you wake up"
    echo "Press Ctrl+C to stop monitoring"
    echo ""
    
    # Get initial timestamp
    LAST_CHECK=$(date +%s)
    
    while true; do
        # Check if n8n is running
        if ! curl -s http://localhost:5678 > /dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  n8n is not responding, restarting...${NC}"
            restart_services
        fi
        
        # Check if tunnel is running
        if ! ps aux | grep -q "cloudflared tunnel"; then
            echo -e "${YELLOW}⚠️  Tunnel is not running, restarting...${NC}"
            restart_services
        fi
        
        # Check for long gaps (sleep mode)
        CURRENT_TIME=$(date +%s)
        TIME_DIFF=$((CURRENT_TIME - LAST_CHECK))
        
        if [ $TIME_DIFF -gt 300 ]; then  # 5 minutes
            echo -e "${YELLOW}⚠️  Detected potential sleep mode, checking services...${NC}"
            restart_services
        fi
        
        LAST_CHECK=$CURRENT_TIME
        
        # Check every 30 seconds
        sleep 30
    done
}

# Function to set up sleep monitoring
setup_sleep_monitoring() {
    echo -e "${YELLOW}📋 Setting up sleep monitoring...${NC}"
    
    # Create launch agent to run on wake
    LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
    mkdir -p "$LAUNCH_AGENT_DIR"
    
    LAUNCH_AGENT_FILE="$LAUNCH_AGENT_DIR/com.n8n.restart.plist"
    
    cat > "$LAUNCH_AGENT_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.n8n.restart</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$(pwd)/restart-after-wake.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
    
    # Create the restart script
    cat > "restart-after-wake.sh" << EOF
#!/bin/bash
cd "$(pwd)"
sleep 30  # Wait for network to be ready
./auto-restart-after-sleep.sh restart
EOF
    
    chmod +x "restart-after-wake.sh"
    
    # Load the launch agent
    launchctl load "$LAUNCH_AGENT_FILE" 2>/dev/null
    
    echo -e "${GREEN}✅ Sleep monitoring set up${NC}"
    echo "The script will automatically restart services when you wake up"
}

# Main execution
case "$1" in
    "setup")
        setup_sleep_monitoring
        ;;
    "restart")
        restart_services
        ;;
    "monitor")
        monitor_sleep
        ;;
    *)
        echo "Usage: $0 [setup|restart|monitor]"
        echo ""
        echo "Commands:"
        echo "  setup   - Set up automatic restart after sleep"
        echo "  restart - Restart services now"
        echo "  monitor - Monitor and auto-restart when needed"
        echo ""
        echo "Examples:"
        echo "  $0 setup    # Set up automatic restart"
        echo "  $0 restart  # Restart services now"
        echo "  $0 monitor  # Start monitoring"
        ;;
esac 