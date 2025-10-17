#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

CONFIG_FILE=~/ghost00ls/lib/config.sh

menu_config() {
    clear
    banner
    echo -e "${CYAN}=== ⚙️ Config & Settings ===${NC}"
    echo
    echo -e "${GREEN}1) Voir configuration actuelle${NC}"
    echo -e "${GREEN}2) Modifier clé API Groq${NC}"
    echo -e "${GREEN}3) Ajouter une autre clé API (Shodan, VirusTotal, etc.)${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1)
            clear
            banner
            echo -e "${YELLOW}=== Contenu actuel de $CONFIG_FILE ===${NC}"
            cat $CONFIG_FILE
            read -p "Appuie sur [Entrée] pour revenir..."
            ;;
        2)
            read -p "👉 Nouvelle clé Groq : " newkey
            sed -i "s|^export GROQ_API_KEY=.*|export GROQ_API_KEY=\"$newkey\"|" $CONFIG_FILE
            echo -e "${GREEN}✅ Clé Groq mise à jour${NC}"
            ;;
        3)
            read -p "👉 Nom de la variable (ex: SHODAN_API_KEY) : " varname
            read -p "👉 Valeur de la clé : " apikey
            echo "export $varname=\"$apikey\"" >> $CONFIG_FILE
            echo -e "${GREEN}✅ $varname ajouté à $CONFIG_FILE${NC}"
            ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}" ;;
    esac
    menu_config
}

menu_config
