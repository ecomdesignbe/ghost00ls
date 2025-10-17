#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

LOG_DIR=~/ghost00ls/logs/labs
mkdir -p "$LOG_DIR"

while true; do
    clear
    banner
    echo -e "${CYAN}=== 🧪 Labs / CTF / Vuln Labs (Ghost00ls Framework) ===${NC}"
    echo
    echo -e "${GREEN}1) 🌐 Web Vuln Apps${NC}"
    echo -e "${GREEN}2) 💣 Exploitable VMs${NC}"
    echo -e "${GREEN}3) ☁️ Cloud Vuln Labs${NC}"
    echo -e "${GREEN}4) 🧩 Capture The Flag (CTF)${NC}"
    echo -e "${YELLOW}5) 📂 Conteneurs & Réseau${NC}"
    echo -e "${YELLOW}6) 📊 Logs & Monitoring${NC}"
    echo -e "${RED}0) ❌ Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) ~/ghost00ls/modules/labs/webapps.sh ;;
        2) ~/ghost00ls/modules/labs/exploitable_vms.sh ;;
        3) ~/ghost00ls/modules/labs/cloud_labs.sh ;;
        4) ~/ghost00ls/modules/labs/ctf.sh ;;
        5) ~/ghost00ls/modules/labs/containers.sh ;;
        6) ~/ghost00ls/modules/labs/logs.sh ;;
        0) break ;;
        *) echo -e "${RED}❌ Option invalide${NC}"; sleep 1 ;;
    esac
done
