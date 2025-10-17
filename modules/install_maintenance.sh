#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

menu_install_maintenance() {
    clear
    banner
    echo -e "${CYAN}=== 🛠️ Installation & Maintenance ===${NC}"
    echo
    echo -e "${GREEN}1) 📦 Installation des outils${NC}"
    echo -e "${GREEN}2) 🧰 Maintenance du framework${NC}"
    echo -e "${GREEN}3) ⚙️ Config & Settings${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) bash ~/ghost00ls/modules/install.sh ;;
        2) bash ~/ghost00ls/modules/maintenance.sh ;;
        3) bash ~/ghost00ls/modules/system/config.sh ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}"; sleep 1 ;;
    esac
    menu_install_maintenance
}

menu_install_maintenance
