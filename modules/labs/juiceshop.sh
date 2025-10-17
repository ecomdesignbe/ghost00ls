#!/bin/bash
# juice_shop.sh - Ghostools module (format DVWA-style)
# Emplacement suggéré : ~/ghost00ls/modules/labs/juice_shop/juice_shop.sh
# Objectif : gérer l'installation, le lancement, l'arrêt, les logs et les exploits
# Style et flux volontairement calqués sur dvwa.sh pour homogénéité dans Ghostools.

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

MODULE_DIR=~/ghost00ls/modules/labs/juice_shop
EXPLOITS_DIR="$MODULE_DIR/exploits"
LOG_DIR=~/ghost00ls/logs/juice_shop
DOCKER_IMAGE=bkimminich/juice-shop:latest
CONTAINER_NAME=ghost-juice
JUICE_PORT=3000

# ==========================
# Vérifications préalables
# ==========================
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${YELLOW}⚠️ Docker n’est pas installé. Certaines fonctionnalités ne seront pas disponibles.${NC}"
        return 1
    fi
    return 0
}

# ==========================
# Installation / Pull image
# ==========================
install_juice() {
    echo -e "${YELLOW}⏳ Vérification Docker...${NC}"
    if ! check_docker; then
        echo -e "${RED}❌ Docker requis pour l'installation via image. Installe Docker ou utilise npm (juice-shop CLI).${NC}"
        read -p "👉 Entrée pour revenir..."
        return
    fi

    echo -e "${YELLOW}⏳ Pull de l'image $DOCKER_IMAGE...${NC}"
    docker pull $DOCKER_IMAGE && echo -e "${GREEN}✅ Image Docker prête.${NC}"
    read -p "👉 Entrée pour revenir..."
}

# ==========================
# Lancement / Arrêt / Status
# ==========================
start_juice() {
    echo -e "${YELLOW}⏳ Démarrage Juice Shop...${NC}"
    if ! check_docker; then
        # tenter juice-shop CLI
        if command -v juice-shop &>/dev/null; then
            mkdir -p "$LOG_DIR"
            nohup juice-shop --port $JUICE_PORT --hostname 0.0.0.0 >"$LOG_DIR/juice_shop.out" 2>&1 &
            echo -e "${GREEN}✅ Juice Shop lancé via juice-shop CLI (port $JUICE_PORT)${NC}"
        else
            echo -e "${RED}❌ Ni Docker ni juice-shop CLI trouvés. Impossible de lancer Juice Shop.${NC}"
        fi
        read -p "👉 Entrée pour revenir..."
        return
    fi

    # Si container déjà présent, avertir
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${YELLOW}⚠️ Juice Shop est déjà en cours d'exécution (container: $CONTAINER_NAME).${NC}"
        read -p "👉 Entrée pour revenir..."
        return
    fi

    docker run -d --rm --name $CONTAINER_NAME -p ${JUICE_PORT}:3000 $DOCKER_IMAGE
    echo -e "${GREEN}✅ Juice Shop démarré : http://$(hostname -I | awk '{print $1}'):${JUICE_PORT}${NC}"
    read -p "👉 Entrée pour revenir..."
}

stop_juice() {
    echo -e "${YELLOW}⏳ Arrêt Juice Shop...${NC}"
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        docker stop $CONTAINER_NAME || true
        echo -e "${GREEN}✅ Container $CONTAINER_NAME stoppé.${NC}"
    else
        # tenter process juice-shop
        if [ -f "$LOG_DIR/juice_shop.pid" ]; then
            pid=$(cat "$LOG_DIR/juice_shop.pid")
            kill "$pid" || true
            rm -f "$LOG_DIR/juice_shop.pid"
            echo -e "${GREEN}✅ Process juice-shop arrêté (PID $pid).${NC}"
        else
            echo -e "${YELLOW}⚠️ Aucun container ni processus Juice Shop trouvé.${NC}"
        fi
    fi
    read -p "👉 Entrée pour revenir..."
}

status_juice() {
    echo -e "${CYAN}📊 Statut Juice Shop :${NC}"
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${GREEN}running (docker: $CONTAINER_NAME)${NC}"
    elif [ -f "$LOG_DIR/juice_shop.pid" ]; then
        pid=$(cat "$LOG_DIR/juice_shop.pid")
        if ps -p $pid &>/dev/null; then
            echo -e "${GREEN}running (pid $pid)${NC}"
        else
            echo -e "${YELLOW}stopped (pid file présent mais processus absent)${NC}"
        fi
    else
        echo -e "${YELLOW}stopped${NC}"
    fi
    read -p "👉 Entrée pour revenir..."
}

# ==========================
# Logs
# ==========================
show_logs() {
    echo -e "${YELLOW}📜 Logs Juice Shop (50 dernières lignes)${NC}"
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        docker logs --tail 50 $CONTAINER_NAME
    else
        tail -n 50 "$LOG_DIR/juice_shop.out" 2>/dev/null || echo -e "${YELLOW}(Pas de logs disponibles)${NC}"
    fi
    read -p "👉 Entrée pour revenir..."
}

# ==========================
# Menu principal (calqué sur dvwa.sh)
# ==========================
menu_juice() {
    clear
    banner
    echo -e "${CYAN}=== OWASP Juice Shop ===${NC}"
    echo -e "${GREEN}1) Lancer Juice Shop${NC}"
    echo -e "${GREEN}2) Installer / Pull image${NC}"
    echo -e "${GREEN}3) Infos connexion (URL / port)${NC}"
    echo -e "${YELLOW}4) Logs Juice Shop${NC}"
    echo -e "${RED}5) Stopper Juice Shop${NC}"
    echo -e "${RED}6) Nettoyer (supprimer container si présent)${NC}"
    echo -e "${CYAN}7) 💣 Exemples d’exploitation${NC}"
    echo -e "${RED}0) Retour${NC}"
    read -p "👉 Choix : " choice

    case $choice in
        1) start_juice ;; 
        2) install_juice ;; 
        3)
            IP=$(hostname -I | awk '{print $1}')
            echo -e "${CYAN}🔗 URL : http://$IP:$JUICE_PORT${NC}"
            read -p "👉 Entrée pour revenir..." ;;
        4) show_logs ;; 
        5) stop_juice ;; 
        6)
            echo -e "${RED}⏳ Nettoyage container...${NC}"
            docker rm -f $CONTAINER_NAME 2>/dev/null || echo -e "${YELLOW}⚠️ Aucun container à supprimer${NC}"
            echo -e "${GREEN}✅ Nettoyage terminé.${NC}"
            read -p "👉 Entrée pour revenir..." ;;
        7) 
            source ~/ghost00ls/modules/labs/juiceshop/exploits.sh
            exploits_menu
            ;;        
        0) return ;; 
        *) echo -e "${RED}❌ Option invalide${NC}" ; sleep 1 ;;
    esac

    menu_juice
}

# Lancer le menu si exécuté directement
menu_juice
