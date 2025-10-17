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
EOFCRON

chmod +x "$ENCRYPT_SCRIPT"
echo -e "${GREEN}✅ Script encrypt_reports.sh créé${NC}"
echo -e "${CYAN}   Path : $ENCRYPT_SCRIPT${NC}"

# Proposer ajout au cron
echo
read -p "📅 Ajouter au cron (chaque nuit 2h) ? [y/N] : " ADD_CRON
if [[ "$ADD_CRON" =~ ^[yY]$ ]]; then
    (crontab -l 2>/dev/null; echo "0 2 * * * bash $ENCRYPT_SCRIPT") | crontab -
    echo -e "${GREEN}✅ Tâche cron ajoutée${NC}"
fi

# === Résumé final ===
echo
echo -e "${CYAN}=================================================${NC}"
echo -e "${GREEN}✅ Correctifs appliqués avec succès !${NC}"
echo -e "${CYAN}=================================================${NC}"
echo
echo -e "${YELLOW}📋 Résumé des actions :${NC}"
echo -e "   1. ✅ config.sh permissions → 600"
echo -e "   2. ✅ automation.sh typo corrigé"
echo -e "   3. ✅ DVWA HTML tronqué réparé"
echo -e "   4. ✅ install.sh division/0 protégée"
echo -e "   5. ✅ sanitize.sh créé"
echo -e "   6. ✅ encrypt_reports.sh créé"
echo
echo -e "${YELLOW}🔐 Sécurité :${NC}"
echo -e "   • API keys protégées (chmod 600)"
echo -e "   • Validation inputs disponible"
echo -e "   • Chiffrement rapports configuré"
echo
echo -e "${YELLOW}💾 Backups :${NC}"
echo -e "   • Backup complet : $BACKUP_DIR/ghost00ls_${TIMESTAMP}.tar.gz"
echo -e "   • Backups fichiers : *.bak"
echo
echo -e "${CYAN}📚 Prochaines étapes recommandées :${NC}"
echo -e "   1. Tester les modules critiques :"
echo -e "      ${GREEN}bash ~/ghost00ls/ghost-menu.sh${NC}"
echo -e "   2. Vérifier logs système :"
echo -e "      ${GREEN}tail -f ~/ghost00ls/logs/system/*.log${NC}"
echo -e "   3. Lancer audit shellcheck :"
echo -e "      ${GREEN}shellcheck ~/ghost00ls/modules/**/*.sh${NC}"
echo
echo -e "${GREEN}🎉 Ghost00ls est maintenant plus sécurisé !${NC}"
echo