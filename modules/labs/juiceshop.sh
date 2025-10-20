#!/bin/bash
# juiceshop.sh - Unified module (DVWA-style)
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

MODULE_DIR=~/ghost00ls/modules/labs/juiceshop
LOG_DIR=~/ghost00ls/logs/labs
LOG_FILE="$LOG_DIR/juiceshop.log"
DOCKER_IMAGE=bkimminich/juice-shop:latest
CONTAINER_NAME=ghost-juice
JUICE_PORT=3000

mkdir -p "$LOG_DIR"

# ==========================
# Vérifications
# ==========================
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${YELLOW}⚠️ Docker n'est pas installé${NC}"
        return 1
    fi
    return 0
}

# ==========================
# Fonctions de gestion
# ==========================

install_juice() {
    echo -e "${YELLOW}⏳ Vérification Docker...${NC}"
    
    if ! check_docker; then
        echo -e "${RED}❌ Docker requis. Installe Docker ou utilise npm (juice-shop)${NC}"
        read -p "👉 Entrée pour revenir..."
        return
    fi

    echo -e "${YELLOW}⏳ Pull de l'image $DOCKER_IMAGE...${NC}"
    docker pull $DOCKER_IMAGE && echo -e "${GREEN}✅ Image prête${NC}"
    read -p "👉 Entrée pour revenir..."
}

start_juice() {
    echo -e "${YELLOW}⏳ Démarrage Juice Shop...${NC}" | tee -a "$LOG_FILE"
    
    if ! check_docker; then
        # Fallback : juice-shop CLI
        if command -v juice-shop &>/dev/null; then
            nohup juice-shop --port $JUICE_PORT --hostname 0.0.0.0 >"$LOG_FILE" 2>&1 &
            echo $! > "$LOG_DIR/juice.pid"
            echo -e "${GREEN}✅ Juice Shop lancé via CLI (port $JUICE_PORT)${NC}"
        else
            echo -e "${RED}❌ Ni Docker ni juice-shop CLI trouvés${NC}"
        fi
        read -p "👉 Entrée pour revenir..."
        return
    fi

    # Vérifier si déjà lancé
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${YELLOW}⚠️ Juice Shop déjà en cours${NC}"
        read -p "👉 Entrée pour revenir..."
        return
    fi

    docker run -d --rm --name $CONTAINER_NAME -p ${JUICE_PORT}:3000 $DOCKER_IMAGE >>"$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        local IP=$(hostname -I | awk '{print $1}')
        echo -e "${GREEN}✅ Juice Shop lancé : http://$IP:${JUICE_PORT}${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}❌ Échec du démarrage${NC}" | tee -a "$LOG_FILE"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

stop_juice() {
    echo -e "${YELLOW}⏳ Arrêt Juice Shop...${NC}" | tee -a "$LOG_FILE"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        docker stop $CONTAINER_NAME || true
        echo -e "${GREEN}✅ Container stoppé${NC}" | tee -a "$LOG_FILE"
    elif [ -f "$LOG_DIR/juice.pid" ]; then
        local pid=$(cat "$LOG_DIR/juice.pid")
        kill "$pid" 2>/dev/null || true
        rm -f "$LOG_DIR/juice.pid"
        echo -e "${GREEN}✅ Process arrêté (PID $pid)${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${YELLOW}⚠️ Aucune instance trouvée${NC}"
    fi
    
    sleep 1
}

clean_juice() {
    echo -e "${YELLOW}⏳ Nettoyage Juice Shop...${NC}" | tee -a "$LOG_FILE"
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    rm -f "$LOG_DIR/juice.pid"
    echo -e "${GREEN}✅ Nettoyage terminé${NC}" | tee -a "$LOG_FILE"
    sleep 1
}

status_juice() {
    echo -e "${CYAN}📊 Statut Juice Shop :${NC}"
    
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${GREEN}running (container: $CONTAINER_NAME)${NC}"
        local IP=$(hostname -I | awk '{print $1}')
        echo -e "URL : http://$IP:${JUICE_PORT}"
    elif [ -f "$LOG_DIR/juice.pid" ]; then
        local pid=$(cat "$LOG_DIR/juice.pid")
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

show_logs() {
    echo -e "${YELLOW}📜 Logs Juice Shop (50 dernières lignes)${NC}"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        docker logs --tail 50 $CONTAINER_NAME
    else
        tail -n 50 "$LOG_FILE" 2>/dev/null || echo -e "${YELLOW}(Pas de logs disponibles)${NC}"
    fi
    
    read -p "👉 Entrée pour revenir..."
}

show_info() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Informations Juice Shop ===${NC}"
    echo
    local IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}🔗 URL : http://$IP:${JUICE_PORT}${NC}"
    echo -e "${GREEN}🔌 Port : ${JUICE_PORT}${NC}"
    echo -e "${GREEN}🐳 Container : ${CONTAINER_NAME}${NC}"
    echo
    echo -e "${CYAN}📚 Challenges OWASP Top 10 disponibles${NC}"
    echo "   • Broken Access Control"
    echo "   • Cryptographic Failures"
    echo "   • Injection (SQL, XSS, etc.)"
    echo "   • Insecure Design"
    echo "   • Security Misconfiguration"
    echo "   • Vulnerable Components"
    echo "   • Authentication Failures"
    echo "   • Data Integrity Failures"
    echo "   • Logging Failures"
    echo "   • SSRF"
    echo
    read -p "👉 Entrée pour revenir..."
}

# ==========================
# Menu principal
# ==========================

menu_juice() {
    while true; do
        clear
        banner
        echo -e "${CYAN}=== 🥤 OWASP Juice Shop ===${NC}"
        echo
        echo -e "${GREEN}1) 🚀 Lancer Juice Shop${NC}"
        echo -e "${GREEN}2) 📥 Installer / Pull image${NC}"
        echo -e "${GREEN}3) 📊 Statut${NC}"
        echo -e "${GREEN}4) 📋 Infos connexion${NC}"
        echo -e "${YELLOW}5) 📂 Logs Juice Shop${NC}"
        echo -e "${RED}6) 🛑 Stopper Juice Shop${NC}"
        echo -e "${RED}7) 🧹 Nettoyer${NC}"
        echo -e "${CYAN}8) 💣 Exemples d'exploitation${NC}"
        echo -e "${RED}0) ❌ Retour${NC}"
        echo
        read -p "👉 Choix : " choice

        case $choice in
            1) start_juice ;; 
            2) install_juice ;; 
            3) status_juice ;;
            4) show_info ;; 
            5) show_logs ;; 
            6) stop_juice ;; 
            7) clean_juice ;;
            8) 
                if [ -f "$MODULE_DIR/exploits.sh" ]; then
                    source "$MODULE_DIR/exploits.sh"
                    menu_exploits
                else
                    echo -e "${RED}❌ Fichier exploits.sh introuvable${NC}"
                    read -p "👉 Entrée pour revenir..."
                fi
                ;;
            0) break ;; 
            *) echo -e "${RED}❌ Option invalide${NC}" ; sleep 1 ;;
        esac
    done
}

# Lancement si exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    menu_juice
fi
