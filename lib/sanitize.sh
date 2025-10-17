#!/bin/bash
# sanitize.sh - Fonctions de validation et nettoyage inputs
# Usage: source ~/ghost00ls/lib/sanitize.sh

# Nettoyer input alphanumérique
sanitize_alnum() {
    echo "$1" | sed 's/[^a-zA-Z0-9._-]//g'
}

# Valider IP
validate_ip() {
    local ip=$1
    if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi
    
    # Vérifier chaque octet <= 255
    IFS='.' read -ra OCTETS <<< "$ip"
    for octet in "${OCTETS[@]}"; do
        if (( octet > 255 )); then
            return 1
        fi
    done
    return 0
}

# Valider domaine
validate_domain() {
    local domain=$1
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 1
    fi
    return 0
}

# Échapper HTML
html_escape() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

# Échapper SQL (basique)
sql_escape() {
    echo "$1" | sed "s/'/''/g"
}

# Limiter longueur
truncate_string() {
    local str=$1
    local max=${2:-256}
    echo "${str:0:$max}"
}

EOFLIB

chmod 644 "$SANITIZE_LIB"
echo -e "${GREEN}✅ Bibliothèque sanitize.sh créée${NC}"
echo -e "${CYAN}   Path : $SANITIZE_LIB${NC}"

# Ajouter source dans modules critiques
for module in "$GHOST_ROOT/modules/reporting.sh" \
              "$GHOST_ROOT/modules/labs/dvwa/exploits.sh"; do
    if [[ -f "$module" ]] && ! grep -q "source.*sanitize.sh" "$module"; then
        sed -i '3a source ~/ghost00ls/lib/sanitize.sh' "$module"
        echo -e "${GREEN}✅ sanitize.sh ajouté à $(basename $module)${NC}"
    fi
done

# === FIX 6 : Chiffrement auto rapports sensibles ===
echo
echo -e "${YELLOW}[8/8] FIX #6 - Script chiffrement auto rapports...${NC}"

ENCRYPT_SCRIPT="$GHOST_ROOT/cron/encrypt_reports.sh"
