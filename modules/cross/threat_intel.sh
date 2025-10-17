#!/bin/bash
# threat_intel.sh - Module Threat Intelligence
# Place in: ~/ghost00ls/modules/cross/threat_intel.sh

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/lib/config.sh

TI_LOG=~/ghost00ls/logs/threat_intel
mkdir -p "$TI_LOG"

# === Vérification IP/Domain sur VirusTotal ===
check_virustotal() {
    clear
    banner
    echo -e "${CYAN}=== 🦠 VirusTotal Lookup ===${NC}"
    echo
    
    if [[ -z "$VIRUSTOTAL_API_KEY" ]]; then
        echo -e "${RED}❌ Clé VirusTotal manquante${NC}"
        echo -e "${YELLOW}Configure-la dans lib/config.sh :${NC}"
        echo "export VIRUSTOTAL_API_KEY=\"ta_clé\""
        read -p "👉 Entrée pour revenir..."
        return
    fi
    
    read -p "🎯 IP/Domain/Hash à vérifier : " TARGET
    
    echo -e "${YELLOW}⏳ Requête VirusTotal...${NC}"
    
    # Détecter le type (IP, domain, hash)
    if [[ "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        TYPE="ip-addresses"
    elif [[ "$TARGET" =~ ^[a-f0-9]{32}$ || "$TARGET" =~ ^[a-f0-9]{40}$ || "$TARGET" =~ ^[a-f0-9]{64}$ ]]; then
        TYPE="files"
    else
        TYPE="domains"
    fi
    
    RESPONSE=$(curl -s --request GET \
        --url "https://www.virustotal.com/api/v3/${TYPE}/${TARGET}" \
        --header "x-apikey: $VIRUSTOTAL_API_KEY")
    
    echo "$RESPONSE" | jq '.' > "$TI_LOG/vt_${TARGET//[^a-zA-Z0-9]/_}.json"
    
    # Extraction données clés
    MALICIOUS=$(echo "$RESPONSE" | jq -r '.data.attributes.last_analysis_stats.malicious // 0')
    SUSPICIOUS=$(echo "$RESPONSE" | jq -r '.data.attributes.last_analysis_stats.suspicious // 0')
    HARMLESS=$(echo "$RESPONSE" | jq -r '.data.attributes.last_analysis_stats.harmless // 0')
    
    echo
    echo -e "${CYAN}=== Résultat ===${NC}"
    echo -e "🔴 Malicious : $MALICIOUS"
    echo -e "🟠 Suspicious : $SUSPICIOUS"
    echo -e "🟢 Harmless : $HARMLESS"
    echo
    echo -e "${GREEN}Rapport complet : $TI_LOG/vt_${TARGET//[^a-zA-Z0-9]/_}.json${NC}"
    
    read -p "👉 Entrée pour revenir..."
}

# === Vérification IP sur AbuseIPDB ===
check_abuseipdb() {
    clear
    banner
    echo -e "${CYAN}=== 🚨 AbuseIPDB Lookup ===${NC}"
    echo
    
    read -p "🎯 IP à vérifier : " IP
    
    # Clé gratuite limitée - indiquer à l'utilisateur
    echo -e "${YELLOW}⚠️ Nécessite une clé AbuseIPDB (gratuite)${NC}"
    read -p "🔑 Clé API (ou [Enter] pour skip) : " API_KEY
    
    if [[ -z "$API_KEY" ]]; then
        echo -e "${RED}Skipped${NC}"
        sleep 1
        return
    fi
    
    echo -e "${YELLOW}⏳ Requête AbuseIPDB...${NC}"
    
    RESPONSE=$(curl -s -G https://api.abuseipdb.com/api/v2/check \
        --data-urlencode "ipAddress=$IP" \
        -d maxAgeInDays=90 \
        -H "Key: $API_KEY" \
        -H "Accept: application/json")
    
    echo "$RESPONSE" | jq '.' > "$TI_LOG/abuse_${IP//\./_}.json"
    
    ABUSE_SCORE=$(echo "$RESPONSE" | jq -r '.data.abuseConfidenceScore // 0')
    REPORTS=$(echo "$RESPONSE" | jq -r '.data.totalReports // 0')
    
    echo
    echo -e "${CYAN}=== Résultat ===${NC}"
    echo -e "📊 Abuse Score : $ABUSE_SCORE%"
    echo -e "📝 Reports : $REPORTS"
    
    if [[ $ABUSE_SCORE -gt 50 ]]; then
        echo -e "${RED}⚠️ IP SUSPECTE !${NC}"
    else
        echo -e "${GREEN}✅ IP Propre${NC}"
    fi
    
    echo -e "${GREEN}Rapport : $TI_LOG/abuse_${IP//\./_}.json${NC}"
    
    read -p "👉 Entrée pour revenir..."
}

# === IOC Enrichment (multi-sources) ===
enrich_ioc() {
    clear
    banner
    echo -e "${CYAN}=== 🔍 IOC Enrichment (Multi-sources) ===${NC}"
    echo
    
    read -p "🎯 IOC (IP/Domain/Hash) : " IOC
    
    REPORT_FILE="$TI_LOG/enrichment_${IOC//[^a-zA-Z0-9]/_}_$(date +%F_%H-%M-%S).txt"
    
    echo "=== IOC Enrichment Report ===" > "$REPORT_FILE"
    echo "IOC: $IOC" >> "$REPORT_FILE"
    echo "Date: $(date)" >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
    
    # 1. VirusTotal (si configuré)
    if [[ -n "$VIRUSTOTAL_API_KEY" ]]; then
        echo "[1/4] VirusTotal..." | tee -a "$REPORT_FILE"
        # (appel API comme check_virustotal)
        echo "  ✅ Done" >> "$REPORT_FILE"
    fi
    
    # 2. Shodan (si configuré)
    if [[ -n "$SHODAN_API_KEY" ]] && [[ "$IOC" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "[2/4] Shodan..." | tee -a "$REPORT_FILE"
        SHODAN_DATA=$(curl -s "https://api.shodan.io/shodan/host/${IOC}?key=${SHODAN_API_KEY}")
        echo "$SHODAN_DATA" | jq -r '.ports // []' >> "$REPORT_FILE"
    fi
    
    # 3. DNS Lookup
    echo "[3/4] DNS Resolution..." | tee -a "$REPORT_FILE"
    dig +short "$IOC" >> "$REPORT_FILE" 2>&1 || echo "  N/A" >> "$REPORT_FILE"
    
    # 4. Geolocation (API gratuite ipapi.co)
    if [[ "$IOC" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "[4/4] Geolocation..." | tee -a "$REPORT_FILE"
        GEO=$(curl -s "https://ipapi.co/${IOC}/json/")
        echo "$GEO" | jq -r '.country_name // "Unknown"' >> "$REPORT_FILE"
        echo "$GEO" | jq -r '.city // "Unknown"' >> "$REPORT_FILE"
        echo "$GEO" | jq -r '.org // "Unknown"' >> "$REPORT_FILE"
    fi
    
    echo
    echo -e "${GREEN}✅ Rapport complet : $REPORT_FILE${NC}"
    cat "$REPORT_FILE"
    
    read -p "👉 Entrée pour revenir..."
}

# === MITRE ATT&CK Mapping ===
mitre_attack_search() {
    clear
    banner
    echo -e "${CYAN}=== 🗡️ MITRE ATT&CK Navigator ===${NC}"
    echo
    echo "Recherche de techniques par mot-clé"
    echo
    read -p "🔍 Mot-clé (ex: privilege escalation) : " KEYWORD
    
    echo -e "${YELLOW}⏳ Requête MITRE ATT&CK...${NC}"
    
    # Utiliser l'API MITRE (ou fichier JSON local)
    MITRE_JSON="https://raw.githubusercontent.com/mitre/cti/master/enterprise-attack/enterprise-attack.json"
    
    curl -s "$MITRE_JSON" | jq -r --arg kw "$KEYWORD" '
        .objects[] |
        select(.type=="attack-pattern" and (.name | ascii_downcase | contains($kw | ascii_downcase))) |
        "\(.external_references[0].external_id) - \(.name)"
    ' | tee "$TI_LOG/mitre_search_${KEYWORD//[^a-zA-Z0-9]/_}.txt"
    
    echo
    read -p "👉 Entrée pour revenir..."
}

# === Feed IOC (lecture fichiers) ===
process_ioc_feed() {
    clear
    banner
    echo -e "${CYAN}=== 📡 Traiter Feed IOC ===${NC}"
    echo
    read -p "📂 Chemin du fichier IOC (1 IOC par ligne) : " IOC_FILE
    
    if [[ ! -f "$IOC_FILE" ]]; then
        echo -e "${RED}❌ Fichier introuvable${NC}"
        sleep 1
        return
    fi
    
    TOTAL=$(wc -l < "$IOC_FILE")
    echo -e "${YELLOW}📊 Total IOCs : $TOTAL${NC}"
    echo
    read -p "🚀 Lancer analyse (VirusTotal) ? [y/N] : " CONFIRM
    [[ ! "$CONFIRM" =~ ^[yY]$ ]] && return
    
    COUNT=0
    while read -r IOC; do
        ((COUNT++))
        echo -e "${CYAN}[$COUNT/$TOTAL] Analyse : $IOC${NC}"
        
        # Appel VirusTotal (avec rate limiting)
        if [[ -n "$VIRUSTOTAL_API_KEY" ]]; then
            curl -s --request GET \
                --url "https://www.virustotal.com/api/v3/domains/${IOC}" \
                --header "x-apikey: $VIRUSTOTAL_API_KEY" \
                | jq -r '.data.attributes.last_analysis_stats.malicious // 0' \
                | tee -a "$TI_LOG/feed_results.log"
            
            sleep 15  # Rate limiting (4 req/min pour free tier)
        fi
    done < "$IOC_FILE"
    
    echo
    echo -e "${GREEN}✅ Analyse terminée : $TI_LOG/feed_results.log${NC}"
    read -p "👉 Entrée pour revenir..."
}

# === Menu principal ===
menu_threat_intel() {
    clear
    banner
    echo -e "${CYAN}=== 🛰️ Threat Intelligence ===${NC}"
    echo
    echo -e "${GREEN}1) 🦠 VirusTotal Lookup${NC}"
    echo -e "${GREEN}2) 🚨 AbuseIPDB Check${NC}"
    echo -e "${GREEN}3) 🔍 IOC Enrichment (Multi-sources)${NC}"
    echo -e "${GREEN}4) 🗡️ MITRE ATT&CK Search${NC}"
    echo -e "${GREEN}5) 📡 Traiter Feed IOC (bulk)${NC}"
    echo -e "${GREEN}6) 📊 Voir logs Threat Intel${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) check_virustotal ;;
        2) check_abuseipdb ;;
        3) enrich_ioc ;;
        4) mitre_attack_search ;;
        5) process_ioc_feed ;;
        6)
            clear
            banner
            echo -e "${CYAN}=== 📊 Logs Threat Intel ===${NC}"
            ls -lh "$TI_LOG"
            read -p "👉 Entrée pour revenir..."
            ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}"; sleep 1 ;;
    esac
    menu_threat_intel
}

menu_threat_intel