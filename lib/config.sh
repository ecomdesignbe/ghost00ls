#!/bin/bash
# === Ghost00ls Global Configuration ===
# Author: Steve Vandenbossche
# Platform: Raspberry Pi 5 - ParrotOS ARM64

# === API Keys (CRITICAL: Keep this file secure - chmod 600 recommended) ===

# Groq AI (for GhostGPT)
export GROQ_API_KEY="YourAPIkeys"
export GROQ_URL="https://api.groq.com/openai/v1/chat/completions"
export GROQ_MODEL="llama-3.1-8b-instant"  # Options: llama-3.1-8b-instant, mixtral-8x7b-32768, llama-3.1-70b-versatile

# Shodan (for OSINT/Recon)
export SHODAN_API_KEY="${SHODAN_API_KEY:-}"

# VirusTotal (for malware analysis)
export VIRUSTOTAL_API_KEY="${VIRUSTOTAL_API_KEY:-}"

# Have I Been Pwned (for breach checks)
export HIBP_API_KEY="${HIBP_API_KEY:-}"

# Censys (for internet-wide scanning)
export CENSYS_API_ID="${CENSYS_API_ID:-}"
export CENSYS_API_SECRET="${CENSYS_API_SECRET:-}"

# === Framework Paths ===
export GHOST_ROOT="${HOME}/ghost00ls"
export GHOST_LOGS="${GHOST_ROOT}/logs"
export GHOST_MODULES="${GHOST_ROOT}/modules"
export GHOST_WORDLISTS="${GHOST_ROOT}/wordlists"
export GHOST_TMP="${GHOST_ROOT}/tmp"

# === Default Target Settings ===
export DEFAULT_TARGET_IP="127.0.0.1"
export DEFAULT_TIMEOUT=30
export DEFAULT_THREADS=10

# === Tool Preferences ===
export PREFERRED_SCANNER="nmap"     # or masscan
export PREFERRED_BRUTEFORCER="hydra"  # or medusa
export PREFERRED_FUZZER="ffuf"       # or wfuzz

# === Security & Logging ===
export LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR
export AUTO_CLEANUP_LOGS=false  # Set to true to auto-delete logs > 30 days
export ENCRYPT_SENSITIVE_LOGS=false  # Set to true to GPG-encrypt reports

# === Compliance Mode (GDPR/SOC2) ===
export COMPLIANCE_MODE=false  # Anonymizes IPs in logs if true

# === Docker Settings (for labs) ===
export DOCKER_NETWORK="ghost_net"
export DVWA_PORT=4280
export JUICE_PORT=3000

# === Notification Settings (future feature) ===
export SLACK_WEBHOOK_URL=""
export DISCORD_WEBHOOK_URL=""
export TELEGRAM_BOT_TOKEN=""
export TELEGRAM_CHAT_ID=""

# === Warning Check ===
if [[ -z "$GROQ_API_KEY" ]]; then
    echo -e "\033[33m⚠️ GROQ_API_KEY not set. GhostGPT will be unavailable.\033[0m"
    echo -e "\033[36mSet it via: export GROQ_API_KEY=\"gsk_xxxxx\" or edit lib/config.sh\033[0m"
fi

# === Security Recommendation ===
CONFIG_PERMS=$(stat -c %a "$GHOST_ROOT/lib/config.sh" 2>/dev/null)
if [[ "$CONFIG_PERMS" != "600" && "$CONFIG_PERMS" != "400" ]]; then
    echo -e "\033[31m⚠️ SECURITY RISK: config.sh permissions are $CONFIG_PERMS (should be 600)\033[0m"
    echo -e "\033[32mFix with: chmod 600 ~/ghost00ls/lib/config.sh\033[0m"
fi
