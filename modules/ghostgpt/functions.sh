#!/bin/bash
source ~/ghost00ls/lib/config.sh
source ~/ghost00ls/lib/colors.sh

# Fonction générique pour interroger Groq et logger
# $1 = rôle système (ex: "Tu es un assistant spécialisé en Pentest")
# $2 = prompt utilisateur
# $3 = nom du module (ex: "pentest", "redteam", etc.)
ask_groq() {
    local SYSTEM_PROMPT=$1
    local USER_PROMPT=$2
    local MODULE_NAME=$3

    RESPONSE=$(curl -s -X POST "$GROQ_URL" \
        -H "Authorization: Bearer $GROQ_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$GROQ_MODEL\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"$SYSTEM_PROMPT\"},
                {\"role\": \"user\", \"content\": \"$USER_PROMPT\"}
            ]
        }" | jq -r '.choices[0].message.content')

    echo -e "${GREEN}GhostGPT:${NC} $RESPONSE"

    # === Logging automatique ===
    LOG_DIR=~/ghost00ls/logs/ghostgpt
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/${MODULE_NAME}.log"
    {
        echo "[USER] $USER_PROMPT"
        echo "[AI] $RESPONSE"
        echo "---------------------------------"
    } >> "$LOG_FILE"
}
