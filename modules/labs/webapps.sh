#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

while true; do
    clear
    banner
    echo -e "${CYAN}=== 🌐 Web Vuln Apps ===${NC}"
    echo
    echo -e "${GREEN}1) 🚀 DVWA (Damn Vulnerable Web App)${NC}"
    echo -e "${GREEN}2) 🚀 Juice Shop${NC}"
    echo -e "${GREEN}3) 🚀 Mutillidae${NC}"
    echo -e "${GREEN}4) 🚀 bWAPP${NC}"
    echo -e "${RED}0) ❌ Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) ~/ghost00ls/modules/labs/dvwa.sh ;;
        2) ~/ghost00ls/modules/labs/juiceshop.sh ;;
        3) ~/ghost00ls/modules/labs/mutillidae.sh ;;
        4) ~/ghost00ls/modules/labs/bwapp.sh ;;
        0) break ;;
        *) echo -e "${RED}❌ Option invalide${NC}"; sleep 1 ;;
    esac
done
