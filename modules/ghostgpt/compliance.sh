#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/modules/ghostgpt/functions.sh

menu_compliance_ai() {
    clear
    banner
    echo -e "${CYAN}=== ⚖️ GhostGPT Compliance AI ===${NC}"
    echo "Tape ton prompt (ex: 'Quels sont les contrôles clés de la norme ISO 27001 ?')"
    echo "Tape 'exit' pour quitter."
    echo

    while true; do
        read -p "👻 Compliance > " USER_PROMPT
        [[ "$USER_PROMPT" == "exit" ]] && break
        ask_groq "Tu es un assistant spécialisé en Compliance (ISO 27001, NIST, NIS2, AI Act, RGPD)." "$USER_PROMPT" "compliance"
    done
}

menu_compliance_ai
