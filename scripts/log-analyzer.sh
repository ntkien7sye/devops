#!/bin/bash
# Log analyzer - runs daily at midnight, sends errors to Slack

LOG_DIR="${LOG_DIR:-/app/logs}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
APP_NAME="${APP_NAME:-nestjs-backend}"
DATE=$(date -d "yesterday" +%Y-%m-%d)
LOG_FILE="${LOG_DIR}/app-${DATE}.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 0
fi

ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo 0)
WARN_COUNT=$(grep -c "WARN" "$LOG_FILE" 2>/dev/null || echo 0)

if [ "$ERROR_COUNT" -gt 0 ] && [ -n "$SLACK_WEBHOOK_URL" ]; then
    ERRORS=$(grep "ERROR" "$LOG_FILE" | tail -10)
    
    PAYLOAD=$(cat <<EOF
{
    "blocks": [
        {
            "type": "header",
            "text": {"type": "plain_text", "text": "🚨 Log Analysis Report - ${APP_NAME}"}
        },
        {
            "type": "section",
            "fields": [
                {"type": "mrkdwn", "text": "*Date:* ${DATE}"},
                {"type": "mrkdwn", "text": "*Errors:* ${ERROR_COUNT}"},
                {"type": "mrkdwn", "text": "*Warnings:* ${WARN_COUNT}"}
            ]
        },
        {
            "type": "section",
            "text": {"type": "mrkdwn", "text": "*Recent Errors:*\n\`\`\`${ERRORS}\`\`\`"}
        }
    ]
}
EOF
)
    curl -X POST -H 'Content-type: application/json' --data "$PAYLOAD" "$SLACK_WEBHOOK_URL"
fi

echo "Log analysis complete: $ERROR_COUNT errors, $WARN_COUNT warnings"
