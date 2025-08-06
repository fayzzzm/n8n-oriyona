#!/bin/bash

# n8n Template Saver
# This script helps you save workflow templates manually

TEMPLATE_DIR="./workflow-templates"
DATE=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}💾 n8n Template Saver${NC}"
echo "======================"
echo ""

# Create template directory if it doesn't exist
mkdir -p "$TEMPLATE_DIR"

echo -e "${YELLOW}📋 How to save your workflow template:${NC}"
echo ""
echo "1. ${GREEN}Export from n8n:${NC}"
echo "   - Open your workflow in n8n"
echo "   - Click the three dots menu (⋮)"
echo "   - Select 'Export Workflow'"
echo "   - Copy the JSON content"
echo ""
echo "2. ${GREEN}Save as template:${NC}"
echo "   - Paste the JSON below"
echo "   - Press Ctrl+D when done"
echo "   - Give it a descriptive name"
echo ""

# Get template name
read -p "Enter template name (e.g., telegram-bot, webhook-handler): " TEMPLATE_NAME

if [ -z "$TEMPLATE_NAME" ]; then
    echo -e "${RED}❌ Template name is required${NC}"
    exit 1
fi

# Create filename
TEMPLATE_FILE="$TEMPLATE_DIR/${TEMPLATE_NAME}_${DATE}.json"

echo ""
echo -e "${YELLOW}📝 Paste your workflow JSON below (press Ctrl+D when done):${NC}"
echo ""

# Read JSON from stdin
cat > "$TEMPLATE_FILE"

# Check if file was created and has content
if [ -s "$TEMPLATE_FILE" ]; then
    echo ""
    echo -e "${GREEN}✅ Template saved successfully!${NC}"
    echo -e "${BLUE}📄 File: $TEMPLATE_FILE${NC}"
    echo ""
    
    # Show file info
    FILE_SIZE=$(du -h "$TEMPLATE_FILE" | cut -f1)
    echo -e "${BLUE}📊 File size: $FILE_SIZE${NC}"
    
    # Validate JSON
    if jq empty "$TEMPLATE_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ Valid JSON format${NC}"
    else
        echo -e "${RED}⚠️  Warning: JSON format may be invalid${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}📋 To use this template:${NC}"
    echo "1. Copy the file content"
    echo "2. In n8n, go to Workflows → Import from JSON"
    echo "3. Paste the content and import"
    echo ""
    echo -e "${YELLOW}📋 To share this template:${NC}"
    echo "- The file is saved in: $TEMPLATE_FILE"
    echo "- You can copy it to other projects"
    echo "- Remember to remove sensitive data (API keys, tokens)"
    
else
    echo -e "${RED}❌ No content was saved${NC}"
    rm -f "$TEMPLATE_FILE"
    exit 1
fi 