#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/modules/ghostgpt/functions.sh

menu_general_ai() {
    clear
    banner
    echo -e "${CYAN}=== 🤖 GhostGPT General Assistant ===${NC}"
    echo "Tape ton prompt (ex: 'Explique-moi la différence entre un WAF et un firewall réseau')"
    echo "Tape 'exit' pour quitter."
    echo

    while true; do
        read -p "👻 General > " USER_PROMPT
        [[ "$USER_PROMPT" == "exit" ]] && break
        ask_groq "Tu es un assistant généraliste en cybersécurité et développement." "$USER_PROMPT" "general"
    done
}

menu_general_ai
