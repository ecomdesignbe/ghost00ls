#!/bin/bash
# lib/docker_utils.sh - Gestion Docker centralisée
# Version: 2.0 - Ghost00ls Labs

# Charger colors si pas déjà fait
if [ -z "$GREEN" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m'
fi

# ==========================
# Vérifications
# ==========================

check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}❌ Docker n'est pas installé${NC}"
        echo -e "${YELLOW}💡 sudo apt install docker.io${NC}"
        return 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker daemon non démarré ou permissions insuffisantes${NC}"
        echo -e "${YELLOW}💡 sudo systemctl start docker${NC}"
        echo -e "${YELLOW}💡 sudo usermod -aG docker $USER${NC}"
        return 1
    fi
    
    return 0
}

# ==========================
# Containers simples
# ==========================

start_container() {
    local name="$1"
    local image="$2"
    local port="$3"
    local internal_port="${4:-80}"
    
    if docker ps --format '{{.Names}}' | grep -q "^${name}$"; then
        echo -e "${YELLOW}⚠️ Container $name déjà actif${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⏳ Démarrage de $name...${NC}"
    
    docker run -d --rm --name "$name" -p "${port}:${internal_port}" "$image" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        local ip=$(hostname -I | awk '{print $1}')
        echo -e "${GREEN}✅ $name lancé${NC}"
        echo -e "${CYAN}🔗 http://${ip}:${port}${NC}"
        return 0
    else
        echo -e "${RED}❌ Échec lancement de $name${NC}"
        return 1
    fi
}

stop_container() {
    local name="$1"
    
    if ! docker ps --format '{{.Names}}' | grep -q "^${name}$"; then
        echo -e "${YELLOW}⚠️ Container $name non actif${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⏳ Arrêt de $name...${NC}"
    docker stop "$name" >/dev/null 2>&1
    echo -e "${GREEN}✅ $name stoppé${NC}"
    return 0
}

clean_container() {
    local name="$1"
    echo -e "${YELLOW}⏳ Nettoyage de $name...${NC}"
    docker rm -f "$name" >/dev/null 2>&1
    echo -e "${GREEN}✅ $name nettoyé${NC}"
}

status_container() {
    local name="$1"
    local port="$2"
    
    if docker ps --format '{{.Names}}' | grep -q "^${name}$"; then
        echo -e "${GREEN}▶ Status: running${NC}"
        
        local ip=$(hostname -I | awk '{print $1}')
        echo -e "${CYAN}🔗 URL: http://${ip}:${port}${NC}"
        
        # Health check
        local health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}N/A{{end}}' "$name" 2>/dev/null)
        
        if [ "$health" != "N/A" ]; then
            if [ "$health" = "healthy" ]; then
                echo -e "${GREEN}💚 Health: healthy${NC}"
            else
                echo -e "${YELLOW}⚠️ Health: $health${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⏸ Status: stopped${NC}"
    fi
}

show_container_logs() {
    local name="$1"
    local lines="${2:-50}"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
        docker logs --tail "$lines" "$name"
    else
        echo -e "${YELLOW}⚠️ Container $name introuvable${NC}"
    fi
}

pull_image() {
    local image="$1"
    echo -e "${YELLOW}⏳ Téléchargement de $image...${NC}"
    docker pull "$image" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Image prête${NC}"
        return 0
    else
        echo -e "${RED}❌ Échec téléchargement${NC}"
        return 1
    fi
}

# ==========================
# Docker Compose
# ==========================

compose_up() {
    local compose_file="$1"
    
    if [ ! -f "$compose_file" ]; then
        echo -e "${RED}❌ Fichier compose introuvable: $compose_file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⏳ Lancement via Docker Compose...${NC}"
    docker compose -f "$compose_file" up -d
    return $?
}

compose_down() {
    local compose_file="$1"
    local remove_volumes="${2:-false}"
    
    if [ ! -f "$compose_file" ]; then
        echo -e "${RED}❌ Fichier compose introuvable: $compose_file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⏳ Arrêt via Docker Compose...${NC}"
    
    if [ "$remove_volumes" = "true" ]; then
        docker compose -f "$compose_file" down -v
    else
        docker compose -f "$compose_file" down
    fi
    
    return $?
}

compose_logs() {
    local compose_file="$1"
    local lines="${2:-50}"
    
    if [ ! -f "$compose_file" ]; then
        echo -e "${RED}❌ Fichier compose introuvable: $compose_file${NC}"
        return 1
    fi
    
    docker compose -f "$compose_file" logs --tail="$lines"
}

# ==========================
# Healthcheck
# ==========================

wait_for_healthy() {
    local name="$1"
    local timeout="${2:-60}"
    local elapsed=0
    
    echo -e "${YELLOW}⏳ Attente healthcheck ($timeout s max)...${NC}"
    
    while [ $elapsed -lt $timeout ]; do
        local health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}N/A{{end}}' "$name" 2>/dev/null)
        
        if [ "$health" = "healthy" ]; then
            echo -e "${GREEN}✅ $name est healthy${NC}"
            return 0
        fi
        
        if [ "$health" = "N/A" ]; then
            echo -e "${CYAN}ℹ️ Pas de healthcheck défini pour $name${NC}"
            return 0
        fi
        
        sleep 5
        elapsed=$((elapsed + 5))
        echo -e "${CYAN}⏳ $elapsed / $timeout s...${NC}"
    done
    
    echo -e "${RED}❌ Timeout: healthcheck échoué${NC}"
    return 1
}
