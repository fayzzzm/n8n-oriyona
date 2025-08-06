#!/bin/bash

# Export workflows directly from Docker container
# This bypasses the API authentication issue

BACKUP_DIR="./workflow-backups"
TEMPLATE_DIR="./workflow-templates"
DATE=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🐳 Export Workflows from Docker Container${NC}"
echo "============================================="
echo ""

# Create directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMPLATE_DIR"

# Check if containers are running
if ! docker compose ps | grep -q "Up"; then
    echo -e "${RED}❌ n8n containers are not running${NC}"
    echo "Please start n8n first: docker compose up -d"
    exit 1
fi

echo -e "${YELLOW}📦 Exporting workflows from PostgreSQL database...${NC}"

# Method 1: Try to export from PostgreSQL directly
echo "Attempting to export from database..."

# Get the PostgreSQL container name
PG_CONTAINER=$(docker compose ps -q postgres)

if [ -n "$PG_CONTAINER" ]; then
    echo "Found PostgreSQL container: $PG_CONTAINER"
    
    # Export workflows table
    EXPORT_FILE="$BACKUP_DIR/workflows_db_export_$DATE.sql"
    
    if docker exec "$PG_CONTAINER" pg_dump -U n8n -d n8n -t workflows > "$EXPORT_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ Database export saved to: $EXPORT_FILE${NC}"
    else
        echo -e "${YELLOW}⚠️  Database export failed, trying alternative method...${NC}"
    fi
fi

# Method 2: Copy n8n data directory
echo -e "${YELLOW}📁 Copying n8n data directory...${NC}"

# Get the n8n container name
N8N_CONTAINER=$(docker compose ps -q n8n)

if [ -n "$N8N_CONTAINER" ]; then
    echo "Found n8n container: $N8N_CONTAINER"
    
    # Create backup directory
    BACKUP_DATA_DIR="$BACKUP_DIR/n8n_data_$DATE"
    mkdir -p "$BACKUP_DATA_DIR"
    
    # Copy the entire n8n data directory
    if docker cp "$N8N_CONTAINER:/home/node/.n8n" "$BACKUP_DATA_DIR"; then
        echo -e "${GREEN}✅ n8n data directory copied to: $BACKUP_DATA_DIR${NC}"
        
        # Look for workflow files
        if [ -d "$BACKUP_DATA_DIR/.n8n" ]; then
            echo -e "${BLUE}📋 Looking for workflow files...${NC}"
            
            # Find all JSON files that might be workflows
            find "$BACKUP_DATA_DIR/.n8n" -name "*.json" -type f | while read -r file; do
                filename=$(basename "$file")
                echo -e "${GREEN}📄 Found: $filename${NC}"
                
                # Copy to templates directory if it looks like a workflow
                if grep -q '"nodes"' "$file" 2>/dev/null; then
                    template_file="$TEMPLATE_DIR/${filename%.*}_$DATE.json"
                    cp "$file" "$template_file"
                    echo -e "${BLUE}   → Copied to: $template_file${NC}"
                fi
            done
        fi
    else
        echo -e "${RED}❌ Failed to copy n8n data directory${NC}"
    fi
fi

# Method 3: Try to access the API with basic auth
echo -e "${YELLOW}🔐 Trying API with basic authentication...${NC}"

# Try with basic auth (admin:password)
API_RESPONSE=$(curl -s -u "admin:password" "http://localhost:5678/rest/workflows" 2>/dev/null)

if echo "$API_RESPONSE" | grep -q "data"; then
    echo -e "${GREEN}✅ API access successful!${NC}"
    
    # Save the response
    API_FILE="$BACKUP_DIR/workflows_api_$DATE.json"
    echo "$API_RESPONSE" > "$API_FILE"
    echo -e "${BLUE}📄 API response saved to: $API_FILE${NC}"
    
    # Extract individual workflows
    WORKFLOW_COUNT=$(echo "$API_RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")
    echo -e "${BLUE}📊 Found $WORKFLOW_COUNT workflows via API${NC}"
    
    # Save each workflow as individual template
    if [ "$WORKFLOW_COUNT" -gt 0 ]; then
        echo "$API_RESPONSE" | jq -c '.data[]' | while read -r workflow; do
            workflow_name=$(echo "$workflow" | jq -r '.name // "unnamed"' 2>/dev/null || echo "unnamed")
            workflow_id=$(echo "$workflow" | jq -r '.id // "unknown"' 2>/dev/null || echo "unknown")
            
            # Clean filename
            clean_name=$(echo "$workflow_name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
            template_file="$TEMPLATE_DIR/${clean_name}_${workflow_id}_$DATE.json"
            
            echo "$workflow" | jq '.' > "$template_file"
            echo -e "${GREEN}📄 Saved workflow: $workflow_name → $template_file${NC}"
        done
    fi
else
    echo -e "${YELLOW}⚠️  API access failed, using data directory method${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Export completed!${NC}"
echo ""
echo -e "${BLUE}📁 Your templates are saved in:${NC}"
echo "   - Templates: $TEMPLATE_DIR/"
echo "   - Backups: $BACKUP_DIR/"
echo ""
echo -e "${YELLOW}📋 To use these templates:${NC}"
echo "1. Copy the JSON files from $TEMPLATE_DIR/"
echo "2. In n8n, go to Workflows → Import from JSON"
echo "3. Paste the content and import"
echo ""
echo -e "${YELLOW}📋 To restore from backup:${NC}"
echo "1. Stop n8n: docker compose down"
echo "2. Copy files from $BACKUP_DIR/n8n_data_$DATE/.n8n to your n8n data directory"
echo "3. Restart n8n: docker compose up -d" 