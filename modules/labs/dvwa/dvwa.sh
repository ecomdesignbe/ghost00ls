#!/bin/bash
# modules/labs/dvwa/dvwa.sh - DVWA Manager

# ==========================
# Configuration
# ==========================

CONTAINER_WEB="dvwa-web"
CONTAINER_DB="dvwa-db"
DVWA_PORT=8081

MODULE_DIR="${HOME}/ghost00ls/modules/labs/dvwa"
COMPOSE_FILE="${MODULE_DIR}/compose.yml"
CONFIG_DIR="${MODULE_DIR}/config"
CONFIG_FILE="${CONFIG_DIR}/config.inc.php"
LOG_DIR="${HOME}/ghost00ls/logs/labs"
LOG_FILE="${LOG_DIR}/dvwa.log"

# ==========================
# Sources
# ==========================

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/lib/docker_utils.sh
source ~/ghost00ls/lib/exploits_common.sh

mkdir -p "$LOG_DIR" "$CONFIG_DIR"

# ==========================
# Fonctions DVWA
# ==========================

check_config() {
    echo -e "${CYAN}📋 Vérification configuration...${NC}"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}⚠️ config.inc.php manquant - création${NC}"
        
        cat > "$CONFIG_FILE" <<'EOCONFIG'
<?php
$_DVWA = array();
$_DVWA['db_server']   = 'dvwa-db';
$_DVWA['db_database'] = 'dvwa';
$_DVWA['db_user']     = 'dvwa';
$_DVWA['db_password'] = 'p@ssw0rd';
$_DVWA['db_port']     = '3306';

$_DVWA['recaptcha_public_key']  = '';
$_DVWA['recaptcha_private_key'] = '';

$_DVWA['default_security_level'] = 'low';
$_DVWA['default_locale'] = 'en';

$_DVWA['SQLI_DB'] = 'MySQL';

define('MYSQL', 'MySQL');
define('SQLITE', 'sqlite');
?>
EOCONFIG
    fi
    
    echo -e "${GREEN}✅ Configuration OK${NC}"
}

wait_dvwa_ready() {
    echo -e "${YELLOW}⏳ Attente démarrage DVWA (max 60s)...${NC}"
    
    local max_wait=12
    local count=0
    
    while [ $count -lt $max_wait ]; do
        local db_health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}unknown{{end}}' "$CONTAINER_DB" 2>/dev/null)
        local web_health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}unknown{{end}}' "$CONTAINER_WEB" 2>/dev/null)
        
        if [[ "$db_health" == "healthy" && "$web_health" == "healthy" ]]; then
            echo -e "${GREEN}✅ DVWA prêt !${NC}"
            return 0
        fi
        
        count=$((count + 1))
        echo -e "${CYAN}⏳ Tentative $count/$max_wait (DB: $db_health, Web: $web_health)${NC}"
        sleep 5
    done
    
    echo -e "${YELLOW}⚠️ DVWA pas encore healthy (peut fonctionner quand même)${NC}"
    return 1
}

# ==========================
# Actions
# ==========================

start_dvwa() {
    clear
    banner
    echo -e "${CYAN}=== 🚀 Démarrage DVWA ===${NC}\n"
    
    check_docker || { read -p "👉 Entrée..."; return 1; }
    check_config
    
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_WEB}$"; then
        echo -e "${YELLOW}⚠️ DVWA déjà actif${NC}"
        read -p "👉 Entrée..."
        return 0
    fi
    
    compose_up "$COMPOSE_FILE" | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        wait_dvwa_ready
        
        local ip=$(get_host_ip)
        echo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ DVWA lancé !${NC}"
        echo -e "${CYAN}🔗 URL      : http://${ip}:${DVWA_PORT}${NC}"
        echo -e "${CYAN}👤 Username : admin${NC}"
        echo -e "${CYAN}🔑 Password : password${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo -e "${RED}❌ Échec lancement DVWA${NC}"
        echo -e "${YELLOW}💡 Vérifier les logs avec option 5${NC}"
    fi
    
    read -p "👉 Entrée..."
}

stop_dvwa() {
    clear
    banner
    echo -e "${CYAN}=== 🛑 Arrêt DVWA ===${NC}\n"
    
    compose_down "$COMPOSE_FILE" | tee -a "$LOG_FILE"
    
    echo -e "${GREEN}✅ DVWA stoppé${NC}"
    sleep 1
}

clean_dvwa() {
    clear
    banner
    echo -e "${CYAN}=== 🧹 Nettoyage DVWA ===${NC}\n"
    
    echo -e "${YELLOW}⚠️ Ceci supprimera les containers ET volumes (données perdues)${NC}"
    read -p "Confirmer ? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        compose_down "$COMPOSE_FILE" true | tee -a "$LOG_FILE"
        echo -e "${GREEN}✅ DVWA nettoyé (containers + volumes)${NC}"
    else
        echo -e "${YELLOW}❌ Annulé${NC}"
    fi
    
    sleep 2
}

status_dvwa() {
    clear
    banner
    echo -e "${CYAN}=== 📊 Statut DVWA ===${NC}\n"
    
    local web_running=0
    local db_running=0
    
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_WEB}$"; then
        web_running=1
        echo -e "${GREEN}🐳 Web : running${NC}"
    else
        echo -e "${YELLOW}🐳 Web : stopped${NC}"
    fi
    
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_DB}$"; then
        db_running=1
        echo -e "${GREEN}🐳 DB  : running${NC}"
    else
        echo -e "${YELLOW}🐳 DB  : stopped${NC}"
    fi
    
    if [ $web_running -eq 1 ]; then
        local ip=$(get_host_ip)
        echo
        echo -e "${CYAN}🔗 URL : http://${ip}:${DVWA_PORT}${NC}"
        echo -e "${CYAN}👤 Login : admin / password${NC}"
        
        local web_health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}N/A{{end}}' "$CONTAINER_WEB" 2>/dev/null)
        local db_health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}N/A{{end}}' "$CONTAINER_DB" 2>/dev/null)
        
        echo
        echo -e "${CYAN}Health: Web=${web_health}, DB=${db_health}${NC}"
    fi
    
    echo
    read -p "👉 Entrée..."
}

show_logs() {
    clear
    banner
    echo -e "${CYAN}=== 📜 Logs DVWA ===${NC}\n"
    
    compose_logs "$COMPOSE_FILE" 50
    
    echo
    read -p "👉 Entrée..."
}

show_info() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Informations DVWA ===${NC}\n"
    
    local ip=$(get_host_ip)
    
    echo -e "${GREEN}🔗 URL  : http://${ip}:${DVWA_PORT}${NC}"
    echo -e "${GREEN}👤 User : admin${NC}"
    echo -e "${GREEN}🔑 Pass : password${NC}"
    echo -e "${GREEN}📂 Path : $MODULE_DIR${NC}"
    
    echo
    echo -e "${CYAN}📚 Vulnérabilités disponibles :${NC}"
    echo "   • Brute Force"
    echo "   • Command Injection"
    echo "   • CSRF"
    echo "   • File Inclusion"
    echo "   • File Upload"
    echo "   • SQL Injection"
    echo "   • XSS (Reflected/Stored/DOM)"
    
    echo
    read -p "👉 Entrée..."
}

reset_db() {
    clear
    banner
    echo -e "${CYAN}=== 🔄 Reset DB DVWA ===${NC}\n"
    
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_DB}$"; then
        echo -e "${RED}❌ DB non active${NC}"
        read -p "👉 Entrée..."
        return 1
    fi
    
    local reset_sql="${MODULE_DIR}/reset.sql"
    
    if [ ! -f "$reset_sql" ]; then
        echo -e "${YELLOW}⚠️ reset.sql manquant - création${NC}"
        
        cat > "$reset_sql" <<'EOSQL'
CREATE DATABASE IF NOT EXISTS dvwa;
USE dvwa;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  user_id int(6) NOT NULL auto_increment,
  first_name varchar(15) NOT NULL,
  last_name varchar(15) NOT NULL,
  user varchar(15) NOT NULL,
  password varchar(32) NOT NULL,
  avatar varchar(70) NOT NULL,
  last_login TIMESTAMP,
  failed_login INT(3) DEFAULT '0',
  PRIMARY KEY (user_id)
);

INSERT INTO users VALUES (1, 'admin', 'admin', 'admin', MD5('password'), 'dvwa/hackable/users/admin.jpg', NOW(), 0);
EOSQL
    fi
    
    echo -e "${YELLOW}⏳ Exécution reset SQL...${NC}"
    docker exec -i "$CONTAINER_DB" mariadb -u dvwa -pp@ssw0rd dvwa < "$reset_sql" 2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ DB réinitialisée${NC}"
    else
        echo -e "${RED}❌ Échec reset DB${NC}"
    fi
    
    read -p "👉 Entrée..."
}

# ==========================
# Menu principal
# ==========================

menu_dvwa() {
    while true; do
        clear
        banner
        echo -e "${CYAN}=== 🎯 DVWA Manager ===${NC}"
        echo
        echo -e "${GREEN}1) 🚀 Lancer DVWA${NC}"
        echo -e "${GREEN}2) 📊 Statut${NC}"
        echo -e "${GREEN}3) 📋 Informations${NC}"
        echo -e "${GREEN}4) 🔄 Reset DB${NC}"
        echo -e "${YELLOW}5) 📜 Logs${NC}"
        echo -e "${RED}6) 🛑 Stopper${NC}"
        echo -e "${RED}7) 🧹 Nettoyer (+ volumes)${NC}"
        echo -e "${MAGENTA}8) 💣 Exploits${NC}"
        echo -e "${RED}0) ❌ Retour${NC}"
        echo
        read -p "👉 Choix : " choice

        case $choice in
            1) start_dvwa ;;
            2) status_dvwa ;;
            3) show_info ;;
            4) reset_db ;;
            5) show_logs ;;
            6) stop_dvwa ;;
            7) clean_dvwa ;;
            8)
                if [ -f "${MODULE_DIR}/exploits.sh" ]; then
                    bash "${MODULE_DIR}/exploits.sh"
                else
                    echo -e "${RED}❌ exploits.sh manquant${NC}"
                    read -p "👉 Entrée..."
                fi
                ;;
            0) return ;;
            *)
                echo -e "${RED}❌ Invalide${NC}"
                sleep 1
                ;;
        esac
    done
}

# ==========================
# Lancement
# ==========================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    menu_dvwa
fi
