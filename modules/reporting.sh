#!/bin/bash
# reporting.sh - Génération automatique de rapports
# Place in: ~/ghost00ls/modules/reporting.sh
source ~/ghost00ls/lib/sanitize.sh

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

REPORT_DIR=~/ghost00ls/reports
LOG_DIR=~/ghost00ls/logs
mkdir -p "$REPORT_DIR"

# === Génération rapport Markdown ===
generate_markdown_report() {
    clear
    banner
    echo -e "${CYAN}=== 📄 Génération Rapport Markdown ===${NC}"
    echo
    read -p "🏷️ Nom du projet/client : " PROJECT_NAME
    read -p "📅 Date du pentest (YYYY-MM-DD) : " PENTEST_DATE
    
    REPORT_FILE="$REPORT_DIR/${PROJECT_NAME}_${PENTEST_DATE}_report.md"
    
    cat > "$REPORT_FILE" <<EOF
# 🔒 Rapport de Pentest - $PROJECT_NAME
**Date** : $PENTEST_DATE  
**Testeur** : $(whoami)  
**Framework** : Ghost00ls v1.0  

---

## 📊 Résumé Exécutif

**Vulnérabilités Critiques** : [À compléter]  
**Vulnérabilités Élevées** : [À compléter]  
**Vulnérabilités Moyennes** : [À compléter]  
**Vulnérabilités Faibles** : [À compléter]  

**Score de Risque Global** : [À calculer]

---

## 🎯 Périmètre du Test

**Cibles** :
- [IP/Hostname 1]
- [IP/Hostname 2]

**Outils utilisés** :
- Nmap
- Nikto
- SQLmap
- Metasploit

---

## 🔍 Découvertes

### 1. [Vulnérabilité 1 - Titre]
**Sévérité** : 🔴 Critique  
**CVSS Score** : 9.8  
**Description** : [Description détaillée]  
**Preuve de Concept** :
\`\`\`bash
# Commande utilisée
curl -X POST http://target/vulnerable -d 'payload'
\`\`\`
**Impact** : [Décrire l'impact]  
**Recommandations** :
- Corriger X
- Implémenter Y

---

### 2. [Vulnérabilité 2 - Titre]
[Répéter le format]

---

## 📂 Annexes

**Logs disponibles** :
EOF

    # Ajouter liste des logs disponibles
    find "$LOG_DIR" -type f -name "*.log" | while read -r logfile; do
        echo "- \`$(basename "$logfile")\`" >> "$REPORT_FILE"
    done

    cat >> "$REPORT_FILE" <<EOF

---

## ✅ Checklist de Sécurité

- [ ] Toutes les vulnérabilités critiques corrigées
- [ ] Re-test effectué après corrections
- [ ] Documentation mise à jour
- [ ] Équipe informée

---

**Généré par Ghost00ls Framework**  
**Contact** : ecomdesign.be
EOF

    echo -e "${GREEN}✅ Rapport généré : $REPORT_FILE${NC}"
    read -p "👉 Ouvrir avec nano ? [y/N] : " OPEN
    [[ "$OPEN" =~ ^[yY]$ ]] && nano "$REPORT_FILE"
}

# === Génération rapport HTML ===
generate_html_report() {
    clear
    banner
    echo -e "${CYAN}=== 🌐 Génération Rapport HTML ===${NC}"
    echo
    read -p "🏷️ Nom du projet : " PROJECT_NAME
    read -p "📅 Date : " DATE
    
    HTML_FILE="$REPORT_DIR/${PROJECT_NAME}_${DATE}_report.html"
    
    cat > "$HTML_FILE" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Pentest - PROJECT_NAME</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e0e0e0;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255,255,255,0.05);
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }
        h1 {
            color: #00ff88;
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
            text-shadow: 0 0 20px rgba(0,255,136,0.5);
        }
        .severity-critical { background: #ff4444; color: white; }
        .severity-high { background: #ff8800; }
        .severity-medium { background: #ffcc00; color: #333; }
        .severity-low { background: #88ff00; color: #333; }
        .vuln-card {
            background: rgba(255,255,255,0.08);
            border-left: 5px solid #00ff88;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }
        .badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: bold;
            margin: 5px;
        }
        code {
            background: #000;
            padding: 10px;
            display: block;
            border-radius: 5px;
            overflow-x: auto;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 Rapport de Pentest</h1>
        <h2>PROJECT_NAME</h2>
        <p><strong>Date :</strong> DATE</p>
        <p><strong>Testeur :</strong> Ghost00ls Team</p>
        
        <hr style="margin: 30px 0; border-color: #00ff88;">
        
        <h2>📊 Résumé</h2>
        <div>
            <span class="badge severity-critical">🔴 Critiques: 0</span>
            <span class="badge severity-high">🟠 Élevées: 0</span>
            <span class="badge severity-medium">🟡 Moyennes: 0</span>
            <span class="badge severity-low">🟢 Faibles: 0</span>
        </div>
        
        <h2 style="margin-top: 40px;">🔍 Vulnérabilités Détectées</h2>
        
        <div class="vuln-card">
            <h3>1. [Titre de la vulnérabilité]</h3>
            <span class="badge severity-critical">🔴 CRITIQUE</span>
            <p><strong>Description :</strong> [À compléter]</p>
            <p><strong>Impact :</strong> [À compléter]</p>
            <code>
# Preuve de Concept
curl -X POST http://target/vuln -d 'exploit'
            </code>
            <p><strong>Recommandation :</strong> [À compléter]</p>
        </div>
        
        <hr style="margin: 30px 0; border-color: #00ff88;">
        
        <p style="text-align: center; color: #00ff88;">
            <strong>Généré par Ghost00ls Framework</strong><br>
            ecomdesign.be
        </p>
    </div>
</body>
</html>
EOF

    # Remplacer les placeholders
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$HTML_FILE"
    sed -i "s/DATE/$DATE/g" "$HTML_FILE"
    
    echo -e "${GREEN}✅ Rapport HTML généré : $HTML_FILE${NC}"
    echo -e "${CYAN}Ouvre-le avec : firefox $HTML_FILE${NC}"
}

# === Export CSV des scans ===
export_csv_logs() {
    clear
    banner
    echo -e "${CYAN}=== 📊 Export CSV Global ===${NC}"
    echo
    
    CSV_FILE="$REPORT_DIR/ghost00ls_export_$(date +%F_%H-%M-%S).csv"
    
    echo "Module,Date,Fichier,Taille" > "$CSV_FILE"
    
    find "$LOG_DIR" -type f | while read -r logfile; do
        MODULE=$(dirname "$logfile" | xargs basename)
        DATE=$(stat -c %y "$logfile" | cut -d' ' -f1)
        FILENAME=$(basename "$logfile")
        SIZE=$(du -h "$logfile" | cut -f1)
        echo "$MODULE,$DATE,$FILENAME,$SIZE" >> "$CSV_FILE"
    done
    
    echo -e "${GREEN}✅ Export CSV : $CSV_FILE${NC}"
    echo -e "${CYAN}Lignes : $(wc -l < "$CSV_FILE")${NC}"
}

# === Menu principal ===
menu_reporting() {
    clear
    banner
    echo -e "${CYAN}=== 📝 Reporting & Export ===${NC}"
    echo
    echo -e "${GREEN}1) 📄 Générer rapport Markdown${NC}"
    echo -e "${GREEN}2) 🌐 Générer rapport HTML${NC}"
    echo -e "${GREEN}3) 📊 Export CSV des logs${NC}"
    echo -e "${GREEN}4) 📂 Voir rapports existants${NC}"
    echo -e "${GREEN}5) 🗑️ Supprimer ancien rapport${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) generate_markdown_report ;;
        2) generate_html_report ;;
        3) export_csv_logs ;;
        4)
            clear
            banner
            echo -e "${CYAN}=== 📂 Rapports disponibles ===${NC}"
            ls -lh "$REPORT_DIR"
            read -p "👉 Entrée pour revenir..."
            ;;
        5)
            ls -1 "$REPORT_DIR" | nl
            read -p "👉 Numéro du rapport à supprimer : " NUM
            FILE=$(ls -1 "$REPORT_DIR" | sed -n "${NUM}p")
            [[ -n "$FILE" ]] && rm "$REPORT_DIR/$FILE" && echo -e "${GREEN}✅ Supprimé${NC}"
            sleep 1
            ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}"; sleep 1 ;;
    esac
    menu_reporting
}

menu_reporting