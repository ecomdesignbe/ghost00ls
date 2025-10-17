#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/modules/ghostgpt/functions.sh

menu_redteam_ai() {
    clear
    banner
    echo -e "${CYAN}=== 🕵️ GhostGPT Red Team AI ===${NC}"
    echo "Tape ton prompt (ex: 'Montre-moi une attaque Kerberoasting sur Active Directory')"
    echo "Tape 'exit' pour quitter."
    echo

    while true; do
        read -p "👻 RedTeam > " USER_PROMPT
        [[ "$USER_PROMPT" == "exit" ]] && break
        ask_groq "Tu es un assistant spécialisé en Red Team (AD attacks, C2, evasion, lateral movement)." "$USER_PROMPT" "redteam"
    done
}

menu_redteam_ai
