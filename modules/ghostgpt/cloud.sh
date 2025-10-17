#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/modules/ghostgpt/functions.sh

menu_cloud_ai() {
    clear
    banner
    echo -e "${CYAN}=== ☁️ GhostGPT Cloud AI ===${NC}"
    echo "Tape ton prompt (ex: 'Comment sécuriser un bucket S3 public en AWS ?')"
    echo "Tape 'exit' pour quitter."
    echo

    while true; do
        read -p "👻 Cloud > " USER_PROMPT
        [[ "$USER_PROMPT" == "exit" ]] && break
        ask_groq "Tu es un assistant spécialisé en Cloud Security (AWS, Azure, GCP, Kubernetes, IaC, DevSecOps)." "$USER_PROMPT" "cloud"
    done
}

menu_cloud_ai
