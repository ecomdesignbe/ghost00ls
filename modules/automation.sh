#!/bin/bash
# automation.sh - Automatisation de tâches récurrentes
# Place in: ~/ghost00ls/modules/automation.sh

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

CRON_DIR=~/ghost00ls/cron
AUTOMATION_LOG=~/ghost00ls/logs/automation.log
mkdir -p "$CRON_DIR"

# === Scan quotidien automatique ===
setup_daily_scan() {
    clear
    banner
    echo -e "${CYAN}=== 🕐 Configuration Scan Quotidien ===${NC}"
    echo
    read -p "🎯 IP/Domaine à scanner : " TARGET
    read -p "⏰ Heure (format 24h, ex: 02:00) : " SCAN_TIME
    
    HOUR=$(echo "$SCAN_TIME" | cut -d: -f1)
    MINUTE=$(echo "$SCAN_TIME" | cut -d: -f2)
    
    # Créer script de scan
    SCAN_SCRIPT="$CRON_DIR/daily_scan_${TARGET//[^a-zA-Z0-9]/_}.sh"
    
    cat > "$SCAN_SCRIPT" <<EOF
#!/bin/bash
# Scan quotidien automatique - $TARGET
DATE=\$(date +%F_%H-%M-%S)
LOG_DIR=~/ghost00ls/logs/automated_scans
mkdir -p "\$LOG_DIR"

echo "[\$DATE] Début scan de $TARGET" >> $AUTOMATION_LOG

# Nmap full scan
nmap -sS -sV -O -A -T4 -oN "\$LOG_DIR/nmap_${TARGET}_\${DATE}.txt" \\
     -oX "\$LOG_DIR/nmap_${TARGET}_\${DATE}.xml" $TARGET >> $AUTOMATION_LOG 2>&1

# Nikto web scan (si port 80/443 ouvert)
if nmap -p 80,443 --open $TARGET | grep -q open; then
    nikto -h $TARGET -o "\$LOG_DIR/nikto_${TARGET}_\${DATE}.txt" >> $AUTOMATION_LOG 2>&1
fi

echo "[\$DATE] Scan terminé - Logs dans \$LOG_DIR" >> $AUTOMATION_LOG

# Notification optionnelle (si webhook configuré)
if [[ -n "\$SLACK_WEBHOOK_URL" ]]; then
    curl -X POST "\$SLACK_WEBHOOK_URL" \\
         -H 'Content-Type: application/json' \\
         -d "{\"text\":\"✅ Scan quotidien de $TARGET terminé\"}" >> $AUTOMATION_LOG 2>&1
fi
EOF

    chmod +x "$SCAN_SCRIPT"
    
    # Ajouter à crontab
    (crontab -l 2>/dev/null; echo "$MINUTE $HOUR * * * $SCAN_SCRIPT") | crontab -
    
    echo -e "${GREEN}✅ Scan quotidien configuré :${NC}"
    echo -e "   Cible : $TARGET"
    echo -e "   Heure : $SCAN_TIME"
    echo -e "   Script : $SCAN_SCRIPT"
    read -p "👉 Entrée pour revenir..."
}

# === Backup automatique des logs ===
setup_auto_backup() {
    clear
    banner
    echo -e "${CYAN}=== 💾 Configuration Backup Automatique ===${NC}"
    echo
    read -p "📂 Destination backup (ex: /mnt/usb/backups) : " BACKUP_DIR
    read -p "🔢 Fréquence (1=quotidien, 7=hebdo) : " FREQ
    
    mkdir -p "$BACKUP_DIR"
    
    BACKUP_SCRIPT="$CRON_DIR/auto_backup.sh"
    
    cat > "$BACKUP_SCRIPT" <<EOF
#!/bin/bash
# Backup automatique Ghost00ls
DATE=\$(date +%F_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/ghost00ls_backup_\${DATE}.tar.gz"

echo "[\$DATE] Début backup" >> $AUTOMATION_LOG

tar -czf "\$BACKUP_FILE" \\
    ~/ghost00ls/logs \\
    ~/ghost00ls/reports \\
    ~/ghost00ls/lib/config.sh \\
    >> $AUTOMATION_LOG 2>&1

# Supprimer backups > 30 jours
find "$BACKUP_DIR" -name "ghost00ls_backup_*.tar.gz" -mtime +30 -delete

echo "[\$DATE] Backup terminé : \$BACKUP_FILE" >> $AUTOMATION_LOG

# Chiffrer si GPG disponible
if command -v gpg &>/dev/null; then
    gpg --symmetric --cipher-algo AES256 "\$BACKUP_FILE" 2>> $AUTOMATION_LOG
    rm "\$BACKUP_FILE"
    echo "[\$DATE] Backup chiffré : \${BACKUP_FILE}.gpg" >> $AUTOMATION_LOG
fi
EOF

    chmod +x "$BACKUP_SCRIPT"
    
    # Crontab : chaque X jours à 03:00
    (crontab -l 2>/dev/null; echo "0 3 */$FREQ * * $BACKUP_SCRIPT") | crontab -
    
    echo -e "${GREEN}✅ Backup automatique configuré :${NC}"
    echo -e "   Destination : $BACKUP_DIR"
    echo -e "   Fréquence : Tous les $FREQ jour(s) à 03:00"
    read -p "👉 Entrée pour revenir..."
}

# === Monitoring continu (mode SOC) ===
setup_continuous_monitoring() {
    clear
    banner
    echo -e "${CYAN}=== 👁️ Mode Monitoring Continu ===${NC}"
    echo
    echo -e "${YELLOW}Ce mode lance des checks toutes les 5 minutes :${NC}"
    echo "  - Ports ouverts (netstat)"
    echo "  - Connexions suspectes"
    echo "  - Processus anormaux"
    echo "  - Modification de fichiers critiques"
    echo
    read -p "🚀 Activer ? [y/N] : " CONFIRM
    [[ ! "$CONFIRM" =~ ^[yY]$ ]] && return
    
    MONITOR_SCRIPT="$CRON_DIR/continuous_monitor.sh"
    
    cat > "$MONITOR_SCRIPT" <<'EOF'
#!/bin/bash
# Monitoring continu Ghost00ls
DATE=$(date +%F_%H-%M-%S)
LOG=~/ghost00ls/logs/monitoring/continuous_${DATE}.log
mkdir -p ~/ghost00ls/logs/monitoring

echo "=== Monitoring $DATE ===" >> "$LOG"

# 1. Ports ouverts
echo "[PORTS]" >> "$LOG"
ss -tulpn | grep LISTEN >> "$LOG" 2>&1

# 2. Connexions actives
echo "[CONNECTIONS]" >> "$LOG"
netstat -antup 2>/dev/null >> "$LOG"

# 3. Top 10 processus CPU
echo "[PROCESSES]" >> "$LOG"
ps aux --sort=-%cpu | head -11 >> "$LOG"

# 4. Détection connexions suspectes (exemple : IPs étrangères)
SUSPICIOUS=$(netstat -antup 2>/dev/null | grep ESTABLISHED | grep -vE '127\.0\.0\.1|192\.168\.|10\.')
if [[ -n "$SUSPICIOUS" ]]; then
    echo "[ALERT] Connexions externes détectées :" >> "$LOG"
    echo "$SUSPICIOUS" >> "$LOG"
    # Notification (optionnel)
    logger -t GHOST00LS "⚠️ Connexions suspectes détectées"
fi

# 5. Fichiers critiques modifiés (dans /etc)
echo "[FILE_INTEGRITY]" >> "$LOG"
find /etc -type f -mmin -5 2>/dev/null >> "$LOG"

# Compression quotidienne des logs
if [[ $(date +%H:%M) == "23:59" ]]; then
    tar -czf ~/ghost00ls/logs/monitoring/archive_$(date +%F).tar.gz \\
        ~/ghost00ls/logs/monitoring/*.log 2>/dev/null
    rm ~/ghost00ls/logs/monitoring/*.log 2>/dev/null
fi
EOF

    chmod +x "$MONITOR_SCRIPT"
    
    # Exécution toutes les 5 minutes
    (crontab -l 2>/dev/null; echo "*/5 * * * * $MONITOR_SCRIPT") | crontab -
    
    echo -e "${GREEN}✅ Monitoring continu activé (check toutes les 5min)${NC}"
    read -p "👉 Entrée pour revenir..."
}

# === Auto-update du framework ===
setup_auto_update() {
    clear
    banner
    echo -e "${CYAN}=== 🔄 Auto-Update Framework ===${NC}"
    echo
    read -p "⏰ Heure de mise à jour (ex: 04:00) : " UPDATE_TIME
    
    HOUR=$(echo "$UPDATE_TIME" | cut -d: -f1)
    MINUTE=$(echo "$UPDATE_TIME" | cut -d: -f2)
    
    UPDATE_SCRIPT="$CRON_DIR/auto_update.sh"
    
    cat > "$UPDATE_SCRIPT" <<'EOF'
#!/bin/bash
# Auto-update Ghost00ls
DATE=$(date +%F_%H-%M-%S)
echo "[$DATE] Début mise à jour" >> ~/ghost00ls/logs/automation.log

cd ~/ghost00ls || exit 1

# Sauvegarder config.sh
cp lib/config.sh lib/config.sh.bak

# Pull dernières modifications
git pull origin main >> ~/ghost00ls/logs/automation.log 2>&1

# Restaurer config.sh si écrasé
if [[ -f lib/config.sh.bak ]]; then
    mv lib/config.sh.bak lib/config.sh
fi

# Rendre exécutables
chmod +x ghost-menu.sh modules/*.sh modules/*/*.sh

echo "[$DATE] Mise à jour terminée" >> ~/ghost00ls/logs/automation.log
EOF

    chmod +x "$UPDATE_SCRIPT"
    
    (crontab -l 2>/dev/null; echo "$MINUTE $HOUR * * * $UPDATE_SCRIPT") | crontab -
    
    echo -e "${GREEN}✅ Auto-update configuré à $UPDATE_TIME${NC}"
    read -p "👉 Entrée pour revenir..."
}

# === Gestion tâches planifiées ===
list_scheduled_tasks() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Tâches Planifiées ===${NC}"
    echo
    echo -e "${YELLOW}=== Crontab actuel ===${NC}"
    crontab -l 2>/dev/null | grep ghost00ls || echo "Aucune tâche Ghost00ls"
    echo
    echo -e "${YELLOW}=== Scripts disponibles ===${NC}"
    ls -lh "$CRON_DIR" 2>/dev/null || echo "Aucun script"
    echo
    read -p "👉 Entrée pour revenir..."
}

remove_scheduled_task() {
    clear
    banner
    echo -e "${CYAN}=== 🗑️ Supprimer Tâche ===${NC}"
    echo
    crontab -l 2>/dev/null | grep ghost00ls | nl
    echo
    read -p "👉 Numéro de la ligne à supprimer (0=annuler) : " LINE_NUM
    
    if [[ "$LINE_NUM" -gt 0 ]]; then
        crontab -l 2>/dev/null | grep -v "$(crontab -l 2>/dev/null | grep ghost00ls | sed -n "${LINE_NUM}p")" | crontab -
        echo -e "${GREEN}✅ Tâche supprimée${NC}"
    fi
    
    sleep 1
}

# === Menu principal ===
menu_automation() {
    clear
    banner
    echo -e "${CYAN}=== 🤖 Automation & Scheduling ===${NC}"
    echo
    echo -e "${GREEN}1) 🕐 Configurer scan quotidien${NC}"
    echo -e "${GREEN}2) 💾 Configurer backup automatique${NC}"
    echo -e "${GREEN}3) 👁️ Activer monitoring continu (SOC mode)${NC}"
    echo -e "${GREEN}4) 🔄 Configurer auto-update framework${NC}"
    echo -e "${GREEN}5) 📋 Voir tâches planifiées${NC}"
    echo -e "${GREEN}6) 🗑️ Supprimer tâche planifiée${NC}"
    echo -e "${GREEN}7) 📊 Voir log automation${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) setup_daily_scan ;;
        2) setup_auto_backup ;;
        3) setup_continuous_monitoring ;;
        4) setup_auto_update ;;
        5) list_scheduled_tasks ;;
        6) remove_scheduled_task ;;
        7)
            clear
            banner
            echo -e "${CYAN}=== 📊 Log Automation ===${NC}"
            tail -50 "$AUTOMATION_LOG" 2>/dev/null || echo "Aucun log"
            read -p "👉 Entrée pour revenir..."
            ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}"; sleep 1 ;;
    esac
    menu_automation
}

menu_automation