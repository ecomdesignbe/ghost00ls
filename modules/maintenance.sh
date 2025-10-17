#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

LOG_DIR=~/ghost00ls/logs

menu_maintenance() {
    clear
    banner
    echo -e "${CYAN}=== 🧰 Maintenance Ghost-Framework ===${NC}"
    echo
    echo -e "${GREEN}1) 📂 Voir logs (tous modules)${NC}"
    echo -e "${GREEN}2) 🧹 Vider logs (sélectif ou global)${NC}"
    echo -e "${GREEN}3) 🔄 Mise à jour système (apt upgrade)${NC}"
    echo -e "${GREEN}4) 🔧 Vérifier dépendances${NC}"
    echo -e "${GREEN}5) 🚀 Mise à jour du framework (updater.sh)${NC}"
    echo -e "${GREEN}6) 🛡️ Vérification sécurité système (lynis, rkhunter, chkrootkit)${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1)
            echo -e "${YELLOW}=== Liste des logs ===${NC}"
            find $LOG_DIR -type f -name "*.log" | nl
            read -p "Appuie sur [Entrée] pour revenir..."
            ;;
        2)
            echo "1) Supprimer un log spécifique"
            echo "2) Supprimer tous les logs"
            read -p "👉 Choix : " opt
            case $opt in
                1)
                    find $LOG_DIR -type f -name "*.log" | nl
                    read -p "Numéro du log à supprimer : " num
                    FILE=$(find $LOG_DIR -type f -name "*.log" | sed -n "${num}p")
                    [ -n "$FILE" ] && rm -f "$FILE" && echo "✅ Supprimé : $FILE"
                    ;;
                2) rm -f $LOG_DIR/*/*.log && echo "✅ Tous les logs supprimés" ;;
                *) echo -e "${RED}Option invalide${NC}" ;;
            esac
            sleep 1
            ;;
        3)
            sudo apt update && sudo apt upgrade -y
            echo -e "${GREEN}✅ Système mis à jour${NC}"
            ;;
        4)
            echo -e "${YELLOW}=== Vérification dépendances ===${NC}"
            for dep in jq curl git tree nmap metasploit-framework sqlmap suricata zeek theharvester nikto zaproxy; do
                if ! command -v $dep &>/dev/null; then
                    echo -e "${RED}❌ $dep manquant${NC}"
                else
                    echo -e "${GREEN}✅ $dep installé${NC}"
                fi
            done
            read -p "Appuie sur [Entrée] pour revenir..."
            ;;
        5)
            bash ~/ghost00ls/modules/system/updater.sh
            read -p "Appuie sur [Entrée] pour revenir..."
            ;;
        6)
            echo -e "${YELLOW}=== Audit sécurité ===${NC}"
            sudo lynis audit system | tee ~/ghost00ls/logs/system/lynis_audit.log
            echo -e "${GREEN}✅ Audit terminé (voir ~/ghost00ls/logs/system/lynis_audit.log)${NC}"
            ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}" ;;
    esac

    menu_maintenance
}

menu_maintenance
