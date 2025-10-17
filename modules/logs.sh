#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

LOG_DIR=~/ghost00ls/logs

menu_logs() {
    clear
    banner
    echo -e "${CYAN}=== 📂 Gestion des logs ===${NC}"
    echo
    echo -e "${GREEN}1) Voir logs (par module)${NC}"
    echo -e "${GREEN}2) Vider logs (sélectif ou global)${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1)
            clear
            banner
            echo -e "${YELLOW}=== Liste des logs disponibles ===${NC}"
            find $LOG_DIR -type f -name "*.log" | nl
            echo
            read -p "👉 Numéro du log à afficher (0 = retour) : " num
            if [[ "$num" != "0" ]]; then
                FILE=$(find $LOG_DIR -type f -name "*.log" | sed -n "${num}p")
                [[ -n "$FILE" ]] && clear && banner && echo -e "${CYAN}=== Affichage : $FILE ===${NC}" && cat "$FILE"
                read -p "Appuie sur [Entrée] pour revenir..."
            fi
            ;;
        2)
            clear
            banner
            echo -e "${YELLOW}=== Suppression des logs ===${NC}"
            echo "1) Supprimer un log spécifique"
            echo "2) Supprimer tous les logs"
            echo "0) Retour"
            read -p "👉 Choix : " opt
            case $opt in
                1)
                    find $LOG_DIR -type f -name "*.log" | nl
                    read -p "👉 Numéro du log à supprimer : " num
                    FILE=$(find $LOG_DIR -type f -name "*.log" | sed -n "${num}p")
                    if [[ -n "$FILE" ]]; then
                        rm -f "$FILE"
                        echo -e "${GREEN}✅ Log supprimé : $FILE${NC}"
                    else
                        echo -e "${RED}Numéro invalide${NC}"
                    fi
                    ;;
                2)
                    rm -f $LOG_DIR/*/*.log 2>/dev/null
                    echo -e "${GREEN}✅ Tous les logs supprimés${NC}"
                    ;;
                0) ;;
                *) echo -e "${RED}Option invalide${NC}" ;;
            esac
            read -p "Appuie sur [Entrée] pour revenir..."
            ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}"; sleep 1 ;;
    esac
    menu_logs
}

menu_logs
