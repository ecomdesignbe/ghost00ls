#!/bin/bash
# modules/labs/webapps.sh - Menu Web Vuln Apps

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

while true; do
    clear
    banner
    echo -e "${CYAN}=== 🌐 Web Vuln Apps (Ghost00ls Labs) ===${NC}"
    echo
    echo -e "${GREEN}1) 🎯 DVWA${NC}           ${YELLOW}(Damn Vulnerable Web App)${NC}"
    echo -e "${GREEN}2) 🥤 Juice Shop${NC}     ${YELLOW}(OWASP Top 10 moderne)${NC}"
    echo -e "${GREEN}3) 🐝 bWAPP${NC}          ${YELLOW}(Buggy Web Application)${NC}"
    echo -e "${GREEN}4) 🐛 Mutillidae${NC}     ${YELLOW}(NOWASP)${NC}"
    echo
    echo -e "${RED}0) ❌ Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) bash ~/ghost00ls/modules/labs/dvwa/dvwa.sh ;;
        2) bash ~/ghost00ls/modules/labs/juiceshop/juiceshop.sh ;;
        3) bash ~/ghost00ls/modules/labs/bwapp/bwapp.sh ;;
        4) bash ~/ghost00ls/modules/labs/mutillidae/mutillidae.sh ;;
        0) break ;;
        *) 
            echo -e "${RED}❌ Option invalide${NC}"
            sleep 1
            ;;
    esac
done
