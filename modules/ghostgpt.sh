#!/bin/bash
# GhostGPT LIVE - Menu principal
# Author: Steve Vandenbossche (ecomdesign.be)

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/config.sh
source ~/ghost00ls/modules/ghostgpt/functions.sh
source ~/ghost00ls/lib/banner.sh

LOG_DIR=~/ghost00ls/logs/ghostgpt

view_logs() {
    clear
    banner
    echo -e "${CYAN}=== 📂 Logs GhostGPT ===${NC}"
    echo "Fichiers disponibles :"
    echo

    ls -1 $LOG_DIR/*.log 2>/dev/null | nl

    echo
    read -p "👉 Choisis le numéro du log à afficher (0 = retour) : " choice

    if [[ "$choice" == "0" ]]; then
        return
    fi

    FILE=$(ls -1 $LOG_DIR/*.log 2>/dev/null | sed -n "${choice}p")

    if [[ -z "$FILE" ]]; then
        echo -e "${RED}Numéro invalide !${NC}"
        sleep 1
        return
    fi

    clear
    banner
    echo -e "${YELLOW}Affichage de : $FILE${NC}"
    echo "---------------------------------"
    cat "$FILE"
    echo "---------------------------------"
    read -p "Appuie sur [Entrée] pour revenir..."
}

clear_logs() {
    clear
    banner
    echo -e "${CYAN}=== 🧹 Vider logs GhostGPT ===${NC}"
    echo "1) Supprimer un log spécifique"
    echo "2) Supprimer tous les logs"
    echo "0) Retour"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1)
            echo
            ls -1 $LOG_DIR/*.log 2>/dev/null | nl
            echo
            read -p "👉 Choisis le numéro du log à supprimer : " lognum
            FILE=$(ls -1 $LOG_DIR/*.log 2>/dev/null | sed -n "${lognum}p")
            if [[ -n "$FILE" ]]; then
                rm -f "$FILE"
                echo -e "${GREEN}✅ Log supprimé : $FILE${NC}"
            else
                echo -e "${RED}Numéro invalide !${NC}"
            fi
            sleep 1
            ;;
        2)
            rm -f $LOG_DIR/*.log 2>/dev/null
            echo -e "${GREEN}✅ Tous les logs GhostGPT ont été supprimés.${NC}"
            sleep 1
            ;;
        0) return ;;
        *) echo -e "${RED}Option invalide !${NC}"; sleep 1 ;;
    esac
}

menu_ghostgpt() {
    clear
    banner
    echo -e "${CYAN}================= 🤖 GhostGPT LIVE =================${NC}"
    echo
    echo -e "${GREEN}1) 💣 Pentest AI${NC}"
    echo -e "${GREEN}2) 🕵️ Red Team AI${NC}"
    echo -e "${GREEN}3) 🔐 Blue Team AI${NC}"
    echo -e "${GREEN}4) ☁️ Cloud AI${NC}"
    echo -e "${GREEN}5) 🛰️ OSINT AI${NC}"
    echo -e "${GREEN}6) ⚖️ Compliance AI${NC}"
    echo -e "${GREEN}7) 🤖 General Assistant${NC}"
    echo -e "${YELLOW}8) 📂 Voir logs GhostGPT${NC}"
    echo -e "${YELLOW}9) 🧹 Vider logs GhostGPT${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) bash ~/ghost00ls/modules/ghostgpt/pentest.sh ;;
        2) bash ~/ghost00ls/modules/ghostgpt/redteam.sh ;;
        3) bash ~/ghost00ls/modules/ghostgpt/blueteam.sh ;;
        4) bash ~/ghost00ls/modules/ghostgpt/cloud.sh ;;
        5) bash ~/ghost00ls/modules/ghostgpt/osint.sh ;;
        6) bash ~/ghost00ls/modules/ghostgpt/compliance.sh ;;
        7) bash ~/ghost00ls/modules/ghostgpt/general.sh ;;
        8) view_logs ;;
        9) clear_logs ;;
        0) return ;;
        *) echo -e "${RED}Option invalide !${NC}"; sleep 1 ;;
    esac
    menu_ghostgpt
}

menu_ghostgpt
