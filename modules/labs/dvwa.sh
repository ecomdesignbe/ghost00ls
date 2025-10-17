#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

COMPOSE=~/ghost00ls/modules/labs/dvwa/compose.yml
CONTAINER_WEB=dvwa-web
CONTAINER_DB=dvwa-db
CONFIG_DIR=~/ghost00ls/modules/labs/dvwa/config
CONFIG_FILE="$CONFIG_DIR/config.inc.php"
DIST_FILE="$CONFIG_DIR/config.inc.php.dist"

# ==========================
# Vérification et patch config
# ==========================
check_and_patch_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}⚠️ config.inc.php manquant → copie depuis .dist...${NC}"
        cp "$DIST_FILE" "$CONFIG_FILE"
    fi

    if ! grep -q "\$_DVWA\['SQLI_DB'\]" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Ajout variable SQLI_DB...${NC}"
        echo "\$_DVWA['SQLI_DB'] = 'MySQL';" >> "$CONFIG_FILE"
    fi

    if ! grep -q "define('MYSQL'" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Ajout define MYSQL...${NC}"
        echo "define('MYSQL', 'MySQL');" >> "$CONFIG_FILE"
    fi

    if ! grep -q "define('SQLITE'" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Ajout define SQLITE...${NC}"
        echo "define('SQLITE', 'sqlite');" >> "$CONFIG_FILE"
    fi

    echo -e "${GREEN}✅ config.inc.php vérifié et patché.${NC}"
}

# ==========================
# Menu principal DVWA
# ==========================
menu_dvwa() {
    clear
    banner
    echo -e "${CYAN}=== DVWA (Damn Vulnerable Web App) ===${NC}"
    echo -e "${GREEN}1) Lancer DVWA${NC}"
    echo -e "${GREEN}2) Réinitialiser la base de données${NC}"
    echo -e "${GREEN}3) Infos connexion (admin / password)${NC}"
    echo -e "${YELLOW}4) Logs DVWA${NC}"
    echo -e "${RED}5) Stopper DVWA${NC}"
    echo -e "${RED}6) Nettoyer DVWA (containers + volumes)${NC}"
    echo -e "${CYAN}7) 💣 Exemples d’exploitation${NC}"
    echo -e "${RED}0) Retour${NC}"
    read -p "👉 Choix : " choice

    case $choice in
        1) 
            echo -e "${YELLOW}⏳ Vérification Docker...${NC}"
            if ! command -v docker &>/dev/null; then
                echo -e "${RED}❌ Docker n’est pas installé.${NC}"
                read -p "👉 Entrée pour revenir..."
                return
            fi

            echo -e "${YELLOW}⏳ Vérification config.inc.php...${NC}"
            check_and_patch_config

            echo -e "${YELLOW}⏳ Lancement DVWA...${NC}"
            docker compose -f $COMPOSE up -d --build

            echo -e "${YELLOW}⏳ Vérification des healthchecks...${NC}"
            for i in {1..10}; do
                STATUS_DB=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_DB 2>/dev/null || echo "starting")
                STATUS_WEB=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_WEB 2>/dev/null || echo "starting")

                if [[ "$STATUS_DB" == "healthy" && "$STATUS_WEB" == "healthy" ]]; then
                    IP=$(hostname -I | awk '{print $1}')
                    echo -e "${GREEN}✅ DVWA est en ligne : http://$IP:8081${NC}"
                    break
                else
                    echo -e "${YELLOW}⚠️ DVWA pas encore prêt... (tentative $i/10)${NC}"
                    sleep 5
                fi
            done

            if [[ "$STATUS_WEB" != "healthy" ]]; then
                echo -e "${RED}❌ DVWA ne s’est pas lancé correctement.${NC}"
            fi
            read -p "👉 Entrée pour revenir..."
            ;;
        2) 
            echo -e "${YELLOW}⏳ Réinitialisation DB...${NC}"
            docker exec -i $CONTAINER_DB mariadb -u dvwa -pp@ssw0rd dvwa < ~/ghost00ls/modules/labs/dvwa/reset.sql
            echo -e "${GREEN}✅ Base DVWA importée automatiquement !${NC}"
            read -p "👉 Entrée pour revenir..."
            ;;
        3) 
            echo -e "${CYAN}📑 Identifiants par défaut :${NC}"
            IP=$(hostname -I | awk '{print $1}')
            echo -e "🔗 URL : http://$IP:8081"
            echo -e "👤 Login : admin"
            echo -e "🔑 Password : password"
            read -p "👉 Entrée pour revenir..."
            ;;
        4) 
            echo -e "${YELLOW}📜 Logs DVWA (50 dernières lignes)${NC}"
            docker compose -f $COMPOSE logs --tail=50
            read -p "👉 Entrée pour revenir..."
            ;;
        5) 
            echo -e "${RED}⏳ Arrêt DVWA...${NC}"
            docker compose -f $COMPOSE down
            echo -e "${GREEN}✅ DVWA stoppé.${NC}"
            read -p "👉 Entrée pour revenir..."
            ;;
        6) 
            echo -e "${RED}⏳ Nettoyage complet DVWA...${NC}"
            docker compose -f $COMPOSE down -v
            echo -e "${GREEN}✅ Containers + volumes supprimés.${NC}"
            read -p "👉 Entrée pour revenir..."
            ;;
        7) 
            source ~/ghost00ls/modules/labs/dvwa/exploits.sh
            exploits_menu
            ;;
        0) return ;;
        *) echo -e "${RED}❌ Option invalide${NC}" ; sleep 1 ;;
    esac
    menu_dvwa
}

menu_dvwa
