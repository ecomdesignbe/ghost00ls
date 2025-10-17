#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/modules/ghostgpt/functions.sh

menu_osint_ai() {
    clear
    banner
    echo -e "${CYAN}=== 🛰️ GhostGPT OSINT AI ===${NC}"
    echo "Tape ton prompt (ex: 'Donne-moi une commande theHarvester pour collecter des emails sur un domaine')"
    echo "Tape 'exit' pour quitter."
    echo

    while true; do
        read -p "👻 OSINT > " USER_PROMPT
        [[ "$USER_PROMPT" == "exit" ]] && break
        ask_groq "Tu es un assistant spécialisé en OSINT (theHarvester, Maltego, Spiderfoot, analyse sources publiques)." "$USER_PROMPT" "osint"
    done
}

menu_osint_ai
