#!/bin/bash
# encrypt_reports.sh - Chiffrement automatique rapports sensibles
# Cron: 0 2 * * * bash ~/ghost00ls/cron/encrypt_reports.sh

REPORT_DIR=~/ghost00ls/reports
LOG_FILE=~/ghost00ls/logs/system/encryption.log
TIMESTAMP=$(date +"%F %T")

# Vérifier GPG disponible
if ! command -v gpg &>/dev/null; then
    echo "[$TIMESTAMP] ❌ GPG non installé" >> "$LOG_FILE"
    exit 1
fi

# Chiffrer rapports récents (< 24h)
find "$REPORT_DIR" -name "*.md" -o -name "*.html" -mtime -1 2>/dev/null | while read -r file; do
    # Skip si déjà chiffré
    [[ -f "${file}.gpg" ]] && continue
    
    # Chiffrer
    if gpg --batch --yes --encrypt --recipient ghost00ls@local "$file" 2>/dev/null; then
        echo "[$TIMESTAMP] ✅ Chiffré : $(basename $file)" >> "$LOG_FILE"
        
        # Suppression sécurisée original
        shred -u "$file" 2>/dev/null || rm -f "$file"
    else
        echo "[$TIMESTAMP] ❌ Échec chiffrement : $(basename $file)" >> "$LOG_FILE"
    fi
done

echo "[$TIMESTAMP] Encryption job terminé" >> "$LOG_FILE"
