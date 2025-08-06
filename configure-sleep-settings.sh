#!/bin/bash

# Configure Mac sleep settings for n8n reliability

echo "⚙️  Configure Sleep Settings for n8n"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}📋 This script will help you configure sleep settings for n8n reliability${NC}"
echo ""
echo "Options:"
echo "1. Prevent sleep completely (best for n8n)"
echo "2. Increase sleep delay (sleep after 1 hour)"
echo "3. Keep current settings"
echo "4. Show current sleep settings"
echo ""

read -p "Choose an option (1-4): " choice

case $choice in
    1)
        echo -e "${YELLOW}🛡️  Preventing sleep completely...${NC}"
        sudo pmset -c sleep 0
        sudo pmset -b sleep 0
        echo -e "${GREEN}✅ Sleep disabled${NC}"
        echo "Your Mac will not sleep while plugged in or on battery"
        ;;
    2)
        echo -e "${YELLOW}⏰ Setting sleep delay to 1 hour...${NC}"
        sudo pmset -c sleep 60
        sudo pmset -b sleep 60
        echo -e "${GREEN}✅ Sleep delay set to 1 hour${NC}"
        echo "Your Mac will sleep after 1 hour of inactivity"
        ;;
    3)
        echo -e "${YELLOW}⏭️  Keeping current settings${NC}"
        ;;
    4)
        echo -e "${BLUE}📊 Current sleep settings:${NC}"
        pmset -g
        ;;
    *)
        echo -e "${RED}❌ Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}💡 Additional recommendations:${NC}"
echo ""
echo "1. ${GREEN}Set up auto-restart after sleep:${NC}"
echo "   ./auto-restart-after-sleep.sh setup"
echo ""
echo "2. ${GREEN}Use reliable tunnel monitoring:${NC}"
echo "   ./start-reliable-tunnel.sh"
echo ""
echo "3. ${GREEN}For production use, deploy to DigitalOcean:${NC}"
echo "   ./deploy-to-digitalocean.sh"
echo ""
echo -e "${YELLOW}📋 Manual sleep prevention commands:${NC}"
echo "   caffeinate -i          # Prevent sleep until Ctrl+C"
echo "   caffeinate -d          # Prevent display sleep"
echo "   caffeinate -s 3600     # Prevent sleep for 1 hour"
echo ""
echo -e "${BLUE}🔧 To restore default sleep settings:${NC}"
echo "   sudo pmset -c sleep 10  # Sleep after 10 minutes (plugged in)"
echo "   sudo pmset -b sleep 5   # Sleep after 5 minutes (battery)" 