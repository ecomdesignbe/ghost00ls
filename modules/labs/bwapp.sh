#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

LOG_FILE=~/ghost00ls/logs/labs/bwapp.log
mkdir -p ~/ghost00ls/logs/labs

while true; do
    clear
    banner
    echo -e "${CYAN}=== 🐝 bWAPP (Buggy Web App) ===${NC}"
    echo
    echo -e "${GREEN}1) 🚀 Lancer bWAPP${NC}"
    echo -e "${YELLOW}2) 📂 Logs bWAPP${NC}"
    echo -e "${RED}3) 🛑 Stopper bWAPP${NC}"
    echo -e "${RED}4) 🧹 Nettoyer bWAPP${NC}"
    echo -e "${CYAN}5) 🧪 Exemples d’exploitation${NC}"
    echo -e "${RED}0) ❌ Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1)
            echo -e "${YELLOW}⏳ Démarrage bWAPP...${NC}" | tee -a "$LOG_FILE"
            sudo docker run -d --name bwapp -p 8084:80 raesene/bwapp >>"$LOG_FILE" 2>&1
            echo -e "${GREEN}✅ bWAPP lancé : http://$(hostname -I | awk '{print $1}'):8084${NC}" | tee -a "$LOG_FILE"
            read -p "👉 [Entrée] Retour..."
            ;;
        2) less "$LOG_FILE" ;;
        3)
            sudo docker stop bwapp >>"$LOG_FILE" 2>&1
            echo -e "${RED}🛑 bWAPP stoppé.${NC}" | tee -a "$LOG_FILE"
            sleep 1
            ;;
        4)
            sudo docker rm -f bwapp >>"$LOG_FILE" 2>&1
            echo -e "${RED}🧹 bWAPP nettoyé.${NC}" | tee -a "$LOG_FILE"
            sleep 1
            ;;
        5)
            clear
            banner
            echo -e "${CYAN}=== 🧪 Exemples d’exploitation bWAPP ===${NC}"
            echo
            echo -e "   1) Command Injection : ping 127.0.0.1; id"
            echo -e "   2) SQL Injection : ' UNION SELECT null, user(), database() -- "
            echo -e "   3) CSRF exploitation avec Burp Suite"
            echo
            read -p "👉 [Entrée] Retour..."
            ;;
        0) break ;;
        *) echo -e "${RED}❌ Option invalide${NC}"; sleep 1 ;;
    esac
done
