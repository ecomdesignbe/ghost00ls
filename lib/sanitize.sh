#!/bin/bash
# Fonctions de sanitization des inputs utilisateur

sanitize_ip() {
    local ip="$1"
    if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo ""
        return 1
    fi
    echo "$ip"
}

sanitize_domain() {
    local domain="$1"
    # Supprimer caractères dangereux
    echo "$domain" | sed 's/[^a-zA-Z0-9.-]//g'
}

sanitize_filename() {
    local filename="$1"
    echo "$filename" | sed 's/[^a-zA-Z0-9._-]//g'
}

sanitize_port() {
    local port="$1"
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo ""
        return 1
    fi
    echo "$port"
}

sanitize_url() {
    local url="$1"
    # Supprimer caractères potentiellement dangereux
    echo "$url" | sed 's/[;&|`$()]//g'
}
