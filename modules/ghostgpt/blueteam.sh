#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/modules/ghostgpt/functions.sh

menu_blueteam_ai() {
    clear
    banner
    echo -e "${CYAN}=== 🔐 GhostGPT Blue Team AI ===${NC}"
    echo "Tape ton prompt (ex: 'Donne une règle Suricata pour détecter un scan Nmap')"
    echo "Tape 'exit' pour quitter."
    echo

    while true; do
        read -p "👻 BlueTeam > " USER_PROMPT
        [[ "$USER_PROMPT" == "exit" ]] && break
        ask_groq "Tu es un assistant spécialisé en Blue Team (SOC, SIEM, IDS/IPS, Threat Hunting, Incident Response)." "$USER_PROMPT" "blueteam"
    done
}

menu_blueteam_ai
