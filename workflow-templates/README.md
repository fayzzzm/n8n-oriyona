# n8n Workflow Templates

This directory contains reusable workflow templates that you can import into n8n.

## How to Use Templates

1. **Import a template:**
   ```bash
   # Copy the template to your n8n instance
   curl -X POST "http://localhost:5678/rest/workflows" \
     -H "Content-Type: application/json" \
     -d @workflow-templates/telegram-echo.json
   ```

2. **Backup your current workflows first:**
   ```bash
   ./backup-workflows.sh backup
   ```

3. **Restore from backup if needed:**
   ```bash
   ./backup-workflows.sh restore ./workflow-backups/latest_backup.json
   ```

## Available Templates

### 1. Telegram Echo Bot (`telegram-echo.json`)
- **Description**: Simple Telegram bot that echoes back messages
- **Use Case**: Testing Telegram integration
- **Features**: 
  - Receives messages from Telegram
  - Echoes them back to the sender
  - Includes message metadata

### 2. Telegram Notification Bot (`telegram-notification.json`)
- **Description**: Sends notifications to a specific chat
- **Use Case**: Alert system, status updates
- **Features**:
  - Sends formatted messages
  - Supports markdown formatting
  - Configurable chat ID

### 3. Webhook to Telegram (`webhook-to-telegram.json`)
- **Description**: Receives webhooks and forwards to Telegram
- **Use Case**: Monitoring systems, alerts
- **Features**:
  - Webhook trigger
  - Data transformation
  - Telegram message formatting

## Creating Your Own Templates

1. **Export a workflow from n8n:**
   ```bash
   ./backup-workflows.sh export <workflow-id>
   ```

2. **Copy to templates directory:**
   ```bash
   cp ./workflow-backups/workflow_<id>_*.json ./workflow-templates/my-template.json
   ```

3. **Update the template:**
   - Remove sensitive data (API keys, tokens)
   - Add comments in the description
   - Test the template

## Template Structure

Each template should include:
- **Name**: Descriptive workflow name
- **Description**: What the workflow does
- **Tags**: For categorization
- **Nodes**: Properly configured nodes
- **Connections**: Node connections
- **Settings**: Workflow settings

## Best Practices

1. **Remove sensitive data** before sharing templates
2. **Use environment variables** for API keys
3. **Add clear descriptions** to help others understand
4. **Test templates** before sharing
5. **Version your templates** with dates or version numbers

## Environment Variables

For production use, replace hardcoded values with environment variables:

```json
{
  "parameters": {
    "telegramBotToken": "{{ $env.TELEGRAM_BOT_TOKEN }}",
    "chatId": "{{ $env.TELEGRAM_CHAT_ID }}"
  }
}
```

## Security Notes

- Never commit API keys or tokens to version control
- Use environment variables for sensitive data
- Regularly rotate your API keys
- Monitor webhook usage and logs 