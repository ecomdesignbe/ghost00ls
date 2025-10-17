#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

CONFIG_FILE=~/ghost00ls/lib/config.sh

menu_system() {
    clear
    banner
    echo -e "${CYAN}=== 🧱 System & Hardening ===${NC}"
    echo
    echo -e "${GREEN}1) 🔒 Hardening système (ufw, fail2ban, services)${NC}"
    echo -e "${GREEN}2) ⚙️ Config & Settings (API keys, variables)${NC}"
    echo -e "${GREEN}3) 🔄 Mise à jour système (apt upgrade)${NC}"
    echo -e "${GREEN}4) 🔧 Vérifier dépendances${NC}"
    echo -e "${GREEN}5) 🚀 Mise à jour du framework (updater.sh)${NC}"
    echo -e "${GREEN}6) 🛡️ Vérification sécurité (lynis, rkhunter, chkrootkit)${NC}"
    echo -e "${GREEN}7) 📝 Vérifier intégrité des scripts (ghost-menu.sh, modules)${NC}"
    echo -e "${GREEN}8) 🧹 Nettoyer caches temporaires / fichiers orphelins${NC}"
    echo -e "${GREEN}9) ♻️ Recharger config.sh (si corrompu)${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) bash ~/ghost00ls/modules/system/hardening.sh ;;
        2) bash ~/ghost00ls/modules/system/config.sh ;;
        3) sudo apt update && sudo apt upgrade -y ;;
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
        5) bash ~/ghost00ls/modules/system/updater.sh ;;
        6)
            echo -e "${YELLOW}=== Audit sécurité ===${NC}"
            sudo lynis audit system | tee ~/ghost00ls/logs/system/lynis_audit.log
            sudo rkhunter --check | tee ~/ghost00ls/logs/system/rkhunter.log
            sudo chkrootkit | tee ~/ghost00ls/logs/system/chkrootkit.log
            echo -e "${GREEN}✅ Audits terminés (logs dans ~/ghost00ls/logs/system/)${NC}"
            read -p "Appuie sur [Entrée] pour revenir..."
            ;;
        7)
            echo -e "${YELLOW}=== Vérification intégrité des scripts ===${NC}"
            md5sum ~/ghost00ls/ghost-menu.sh ~/ghost00ls/modules/*.sh ~/ghost00ls/modules/*/*.sh > ~/ghost00ls/logs/system/md5sum_current.log
            echo -e "${GREEN}✅ Hashes générés dans logs/system/md5sum_current.log${NC}"
            ;;
        8)
            echo -e "${YELLOW}=== Nettoyage caches ===${NC}"
            rm -rf ~/ghost00ls/tmp/* 2>/dev/null
            echo -e "${GREEN}✅ Caches nettoyés${NC}"
            ;;
        9)
            echo -e "${YELLOW}=== Rechargement config.sh ===${NC}"
            if [ -f "$CONFIG_FILE" ]; then
                source "$CONFIG_FILE"
                echo -e "${GREEN}✅ Config.sh rechargé${NC}"
            else
                echo "export GROQ_API_KEY=\"\"" > "$CONFIG_FILE"
                echo -e "${RED}❌ config.sh était absent - recréé par défaut${NC}"
            fi
            ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}"; sleep 1 ;;
    esac
    menu_system
}

menu_system
