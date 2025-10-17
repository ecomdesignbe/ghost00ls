#!/bin/bash
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

LOG_DIR=~/ghost00ls/logs/system
mkdir -p "$LOG_DIR"

# Vérifie si ARM64
arch_check() {
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo -e "${RED}⚠️ Attention : Ce script est optimisé pour ARM64 (Raspberry Pi 5).${NC}"
    fi
}

# Fonction d’installation avec fallback ARM
install_tools() {
    local category="$1"
    local logfile="$LOG_DIR/install_${category}.log"
    shift
    local packages=("$@")

    echo -e "${CYAN}=== Installation $category ===${NC}" | tee "$logfile"

    local total=0
    local ok=0
    local ko=0

    for pkg in "${packages[@]}"; do
        ((total++))
        echo -e "⏳ Vérification : $pkg" | tee -a "$logfile"

        if ! command -v $pkg &>/dev/null; then
            echo -e "${YELLOW}⏳ Installation : $pkg${NC}" | tee -a "$logfile"
            sudo apt install -y $pkg >>"$logfile" 2>&1
        fi

        if command -v $pkg &>/dev/null; then
            echo -e "🟢 ${GREEN}$pkg (installé)${NC}" | tee -a "$logfile"
            ((ok++))
        else
            echo -e "🔴 ${RED}$pkg (KO)${NC}" | tee -a "$logfile"
            ((ko++))

            # 🎯 Fallbacks
            case $pkg in
                crackmapexec)
                    pip3 install git+https://github.com/Pennyw0rth/NetExec.git >>"$logfile" 2>&1
                    command -v netexec &>/dev/null && echo -e "🟢 Fallback : netexec installé (remplace crackmapexec)" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                clamav)
                    sudo apt install -y clamav-daemon >>"$logfile" 2>&1
                    command -v clamdscan &>/dev/null && echo -e "🟢 Fallback : clamdscan installé (remplace clamav)" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                holehe)
                    pip3 install socialscan maigret >>"$logfile" 2>&1
                    command -v socialscan &>/dev/null && echo -e "🟢 Fallback : socialscan installé" | tee -a "$logfile" && ((ok++))
                    command -v maigret &>/dev/null && echo -e "🟢 Fallback : maigret installé" | tee -a "$logfile" && ((ok++))
                    ((ko--))
                    ;;
                wpscan)
                    sudo apt install -y skipfish >>"$logfile" 2>&1
                    command -v skipfish &>/dev/null && echo -e "🟢 Fallback : skipfish installé (remplace wpscan)" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                awscli)
                    pip3 install awscli --upgrade --user >>"$logfile" 2>&1
                    command -v aws &>/dev/null && echo -e "🟢 Fallback : aws installé (remplace awscli)" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                docker.io)
                    curl -fsSL https://get.docker.com | sh >>"$logfile" 2>&1
                    command -v docker &>/dev/null && echo -e "🟢 Fallback : docker installé (remplace docker.io)" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                kubectl)
                    curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/arm64/kubectl" >>"$logfile" 2>&1
                    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl >>"$logfile" 2>&1
                    command -v kubectl &>/dev/null && echo -e "🟢 Fallback : kubectl ARM64 installé" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                golang-go)
                    wget -q https://go.dev/dl/go1.22.5.linux-arm64.tar.gz -O /tmp/go.tar.gz
                    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
                    export PATH=$PATH:/usr/local/go/bin
                    command -v go &>/dev/null && echo -e "🟢 Fallback : go installé (remplace golang-go)" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                python3-pip)
                    curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
                    sudo python3 /tmp/get-pip.py >>"$logfile" 2>&1
                    command -v pip3 &>/dev/null && echo -e "🟢 Fallback : pip3 installé (remplace python3-pip)" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
            esac
        fi
    done

    echo
    echo -e "${YELLOW}Résumé [$category] :${NC}"
    echo -e "   🟢 $ok installés (incl. fallbacks)"
    echo -e "   🔴 $ko manquants"

    local percent=$(( ok * 100 / total ))
    echo -e "   📊 Couverture : ${CYAN}${percent}%${NC} sur $total attendus"
    echo
    read -p "👉 Appuie sur [Entrée] pour revenir au menu..."
}

# Résumé global
install_summary() {
    clear
    banner
    echo -e "${CYAN}📊 Résumé global des installations (ARM64 Ready)${NC}"
    echo

    declare -A categories
    categories["📦 Dépendances de base"]="jq curl git tree ip"
    categories["💣 Offensive Tools"]="nmap hydra sqlmap wfuzz responder crackmapexec"
    categories["🛡️ Defensive Tools"]="suricata zeek tshark yara lynis clamav rkhunter chkrootkit"
    categories["🛰️ OSINT Tools"]="theharvester recon-ng amass holehe sherlock"
    categories["🌐 Web/AppSec Tools"]="nikto wpscan zaproxy feroxbuster whatweb dirb"
    categories["☁️ Cloud & Container"]="awscli kubectl trivy docker.io podman"
    categories["🖥️ Dev & Scripting"]="python3-pip virtualenv golang-go nodejs npm rustc cargo"

    declare -A fallbacks
    fallbacks["holehe"]="socialscan maigret"
    fallbacks["clamav"]="clamdscan clamscan"
    fallbacks["zeek"]="falco arkime-start"
    fallbacks["crackmapexec"]="netexec psexec.py"
    fallbacks["wpscan"]="whatwaf skipfish"
    fallbacks["zaproxy"]="skipfish"
    fallbacks["awscli"]="aws"
    fallbacks["docker.io"]="docker"
    fallbacks["golang-go"]="go"
    fallbacks["python3-pip"]="pip3"

    for cat in "📦 Dépendances de base" \
               "💣 Offensive Tools" \
               "🛡️ Defensive Tools" \
               "🛰️ OSINT Tools" \
               "🌐 Web/AppSec Tools" \
               "☁️ Cloud & Container" \
               "🖥️ Dev & Scripting"; do
        local ok=0
        local total=0
        local ko=0

        for tool in ${categories[$cat]}; do
            ((total++))
            if command -v $tool &>/dev/null; then
                ((ok++))
            elif [[ -n "${fallbacks[$tool]}" ]]; then
                local replaced=0
                for alt in ${fallbacks[$tool]}; do
                    if command -v $alt &>/dev/null; then
                        ((ok++))
                        replaced=1
                        break
                    fi
                done
                if (( replaced == 0 )); then
                    ((ko++))
                fi
            else
                ((ko++))
            fi
        done

        if (( ko == 0 )); then
            echo -e "✅ ${CYAN}$cat${NC} : ${GREEN}100%${NC} ($ok/$total installés, incl. fallbacks)"
        else
            local percent=$(( ok * 100 / total ))
            # ⚠️ Correction ici : un seul espace après ⚠️
            echo -e "⚠️ ${CYAN}$cat${NC} : ${YELLOW}${percent}%${NC} ($ok/$total installés, ${RED}$ko manquants${NC})"
        fi
    done

    echo
    read -p "👉 Appuie sur [Entrée] pour revenir au menu..."
}


# Gestion des logs
view_logs() {
    clear; banner
    echo -e "${CYAN}=== 📂 Logs Installation ===${NC}"
    echo
    ls -1 "$LOG_DIR" | nl
    echo
    read -p "👉 Choisis le numéro du log à afficher (0 = retour) : " choice
    if [[ "$choice" != "0" ]]; then
        file=$(ls -1 "$LOG_DIR" | sed -n "${choice}p")
        [[ -n "$file" ]] && less "$LOG_DIR/$file"
    fi
}

clear_logs() {
    clear; banner
    echo -e "${CYAN}=== 🧹 Vider logs Installation ===${NC}"
    echo "1) Supprimer un log spécifique"
    echo "2) Supprimer tous les logs"
    echo "0) Retour"
    echo
    read -p "👉 Choix : " choice
    case $choice in
        1)
            ls -1 "$LOG_DIR" | nl
            read -p "👉 Numéro du log à supprimer : " num
            file=$(ls -1 "$LOG_DIR" | sed -n "${num}p")
            [[ -n "$file" ]] && rm "$LOG_DIR/$file" && echo -e "${GREEN}✅ Supprimé${NC}"
            ;;
        2)
            rm -f "$LOG_DIR"/* && echo -e "${GREEN}✅ Tous les logs supprimés${NC}"
            ;;
    esac
    sleep 1
}

# Menu principal
menu_install() {
    clear
    banner
    arch_check
    echo -e "${CYAN}=== 🛠️ Installation des outils (ARM64 Ready) ===${NC}"
    echo
    echo -e "${GREEN} 1) 📦 Dépendances de base${NC}"
    echo -e "${GREEN} 2) 💣 Offensive Tools${NC}"
    echo -e "${GREEN} 3) 🛡️ Defensive Tools${NC}"
    echo -e "${GREEN} 4) 🛰️ OSINT Tools${NC}"
    echo -e "${GREEN} 5) 🌐 Web/AppSec Tools${NC}"
    echo -e "${GREEN} 6) ☁️ Cloud & Container${NC}"
    echo -e "${GREEN} 7) 🖥️ Dev & Scripting${NC}"
    echo -e "${GREEN} 8) 🚀 Install ALL${NC}"
    echo -e "${YELLOW} 9) 📊 Résumé global des installations${NC}"
    echo -e "${YELLOW}10) 📂 Voir logs Installation${NC}"
    echo -e "${YELLOW}11) 🧹 Vider logs Installation${NC}"
    echo -e "${RED}0) ❌ Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) install_tools "base" jq curl git tree ip ;;
        2) install_tools "offensive" nmap hydra sqlmap wfuzz responder crackmapexec ;;
        3) install_tools "defensive" suricata zeek tshark yara lynis clamav rkhunter chkrootkit ;;
        4) install_tools "osint" theharvester recon-ng amass holehe sherlock ;;
        5) install_tools "web" nikto wpscan zaproxy feroxbuster whatweb dirb ;;
        6) install_tools "cloud" awscli kubectl trivy docker.io podman ;;
        7) install_tools "dev" python3-pip virtualenv golang-go nodejs npm rustc cargo ;;
        8)
            install_tools "base" jq curl git tree ip
            install_tools "offensive" nmap hydra sqlmap wfuzz responder crackmapexec
            install_tools "defensive" suricata zeek tshark yara lynis clamav rkhunter chkrootkit
            install_tools "osint" theharvester recon-ng amass holehe sherlock
            install_tools "web" nikto wpscan zaproxy feroxbuster whatweb dirb
            install_tools "cloud" awscli kubectl trivy docker.io podman
            install_tools "dev" python3-pip virtualenv golang-go nodejs npm rustc cargo
            ;;
        9) install_summary ;;
        10) view_logs ;;
        11) clear_logs ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}" ;;
    esac
    menu_install
}

menu_install
