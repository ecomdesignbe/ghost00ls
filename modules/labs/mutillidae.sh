#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

LOG_FILE=~/ghost00ls/logs/labs/mutillidae.log
mkdir -p ~/ghost00ls/logs/labs

while true; do
    clear
    banner
    echo -e "${CYAN}=== 🐛 Mutillidae (NOWASP) ===${NC}"
    echo
    echo -e "${GREEN}1) 🚀 Lancer Mutillidae${NC}"
    echo -e "${YELLOW}2) 📂 Logs Mutillidae${NC}"
    echo -e "${RED}3) 🛑 Stopper Mutillidae${NC}"
    echo -e "${RED}4) 🧹 Nettoyer Mutillidae${NC}"
    echo -e "${CYAN}5) 🧪 Exemples d’exploitation${NC}"
    echo -e "${RED}0) ❌ Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1)
            echo -e "${YELLOW}⏳ Démarrage Mutillidae...${NC}" | tee -a "$LOG_FILE"
            sudo docker run -d --name mutillidae -p 8083:80 citizenstig/nowasp >>"$LOG_FILE" 2>&1
            echo -e "${GREEN}✅ Mutillidae lancé : http://$(hostname -I | awk '{print $1}'):8083${NC}" | tee -a "$LOG_FILE"
            read -p "👉 [Entrée] Retour..."
            ;;
        2) less "$LOG_FILE" ;;
        3)
            sudo docker stop mutillidae >>"$LOG_FILE" 2>&1
            echo -e "${RED}🛑 Mutillidae stoppé.${NC}" | tee -a "$LOG_FILE"
            sleep 1
            ;;
        4)
            sudo docker rm -f mutillidae >>"$LOG_FILE" 2>&1
            echo -e "${RED}🧹 Mutillidae nettoyé.${NC}" | tee -a "$LOG_FILE"
            sleep 1
            ;;
        5)
            clear
            banner
            echo -e "${CYAN}=== 🧪 Exemples d’exploitation Mutillidae ===${NC}"
            echo
            echo -e "   1) LFI : http://<IP>:8083/mutillidae/index.php?page=../../../../etc/passwd"
            echo -e "   2) XSS : <script>alert('XSS')</script>"
            echo -e "   3) SQL Injection : ' OR '1'='1"
            echo
            read -p "👉 [Entrée] Retour..."
            ;;
        0) break ;;
        *) echo -e "${RED}❌ Option invalide${NC}"; sleep 1 ;;
    esac
done
