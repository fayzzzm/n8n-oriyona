#!/bin/bash

# n8n Workflow Backup and Restore Script
# This script helps you backup and restore your n8n workflows

BACKUP_DIR="./workflow-backups"
DATE=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 n8n Workflow Backup & Restore Tool${NC}"
echo "=========================================="

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to check if n8n is running
check_n8n() {
    if ! curl -s http://localhost:5678 > /dev/null; then
        echo -e "${RED}❌ n8n is not running on localhost:5678${NC}"
        echo "Please start n8n first: docker compose up -d"
        exit 1
    fi
}

# Function to backup workflows
backup_workflows() {
    echo -e "${YELLOW}📦 Creating workflow backup...${NC}"
    
    # Create backup filename
    BACKUP_FILE="$BACKUP_DIR/workflows_backup_$DATE.json"
    
    # Export workflows from n8n
    if curl -s -X GET "http://localhost:5678/rest/workflows" \
        -H "Content-Type: application/json" \
        -o "$BACKUP_FILE"; then
        
        echo -e "${GREEN}✅ Workflows backed up to: $BACKUP_FILE${NC}"
        
        # Count workflows
        WORKFLOW_COUNT=$(jq '.data | length' "$BACKUP_FILE" 2>/dev/null || echo "0")
        echo -e "${BLUE}📊 Found $WORKFLOW_COUNT workflows${NC}"
        
        # Create a symlink to latest backup
        ln -sf "$BACKUP_FILE" "$BACKUP_DIR/latest_backup.json"
        echo -e "${GREEN}🔗 Latest backup symlink created${NC}"
        
    else
        echo -e "${RED}❌ Failed to backup workflows${NC}"
        echo "Make sure n8n is running and accessible"
        exit 1
    fi
}

# Function to list available backups
list_backups() {
    echo -e "${YELLOW}📋 Available backups:${NC}"
    echo "========================"
    
    if [ -z "$(ls -A $BACKUP_DIR/*.json 2>/dev/null)" ]; then
        echo -e "${RED}No backups found${NC}"
        return
    fi
    
    for backup in "$BACKUP_DIR"/*.json; do
        if [ -f "$backup" ]; then
            filename=$(basename "$backup")
            size=$(du -h "$backup" | cut -f1)
            date=$(stat -f "%Sm" "$backup" 2>/dev/null || stat -c "%y" "$backup" 2>/dev/null)
            echo -e "${GREEN}📄 $filename${NC} ($size) - $date"
        fi
    done
}

# Function to restore workflows
restore_workflows() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please specify a backup file to restore${NC}"
        echo "Usage: $0 restore <backup-file>"
        echo "Example: $0 restore $BACKUP_DIR/latest_backup.json"
        exit 1
    fi
    
    BACKUP_FILE="$1"
    
    if [ ! -f "$BACKUP_FILE" ]; then
        echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}🔄 Restoring workflows from: $BACKUP_FILE${NC}"
    echo -e "${RED}⚠️  This will overwrite existing workflows!${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Import workflows to n8n
        if curl -s -X POST "http://localhost:5678/rest/workflows" \
            -H "Content-Type: application/json" \
            -d @"$BACKUP_FILE"; then
            
            echo -e "${GREEN}✅ Workflows restored successfully!${NC}"
        else
            echo -e "${RED}❌ Failed to restore workflows${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}❌ Restore cancelled${NC}"
    fi
}

# Function to export individual workflow
export_workflow() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please specify a workflow ID${NC}"
        echo "Usage: $0 export <workflow-id>"
        exit 1
    fi
    
    WORKFLOW_ID="$1"
    EXPORT_FILE="$BACKUP_DIR/workflow_${WORKFLOW_ID}_$DATE.json"
    
    echo -e "${YELLOW}📤 Exporting workflow $WORKFLOW_ID...${NC}"
    
    if curl -s -X GET "http://localhost:5678/rest/workflows/$WORKFLOW_ID" \
        -H "Content-Type: application/json" \
        -o "$EXPORT_FILE"; then
        
        echo -e "${GREEN}✅ Workflow exported to: $EXPORT_FILE${NC}"
    else
        echo -e "${RED}❌ Failed to export workflow${NC}"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  backup              - Create a backup of all workflows"
    echo "  list                - List available backups"
    echo "  restore <file>      - Restore workflows from backup file"
    echo "  export <id>         - Export a single workflow by ID"
    echo "  help                - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 backup"
    echo "  $0 list"
    echo "  $0 restore $BACKUP_DIR/latest_backup.json"
    echo "  $0 export 123"
}

# Main script logic
case "$1" in
    "backup")
        check_n8n
        backup_workflows
        ;;
    "list")
        list_backups
        ;;
    "restore")
        check_n8n
        restore_workflows "$2"
        ;;
    "export")
        check_n8n
        export_workflow "$2"
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac 