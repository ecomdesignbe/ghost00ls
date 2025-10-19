#!/bin/bash
# Ghost00ls v2.2 - Installation Script CORRIGÉ
# 112 outils cybersécurité ARM64
# Emplacement : ~/ghost00ls/modules/install.sh

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

LOG_DIR=~/ghost00ls/logs/system
mkdir -p "$LOG_DIR"

# ============================================
# Vérification architecture
# ============================================
arch_check() {
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo -e "${RED}⚠️ ARM64 recommandé (détecté : $(uname -m))${NC}"
    fi
}

# ============================================
# NOUVEAU : Installation des dépendances système
# ============================================
install_dependencies() {
    clear
    banner
    echo -e "${CYAN}=== 🔧 Vérification des dépendances système ===${NC}"
    echo
    
    local deps_missing=0
    
    # Python & pip
    echo -ne "🐍 Python3... "
    if command -v python3 &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}KO${NC}"
        sudo apt install -y python3 >>"$LOG_DIR/dependencies.log" 2>&1
        ((deps_missing++))
    fi
    
    echo -ne "📦 pip3... "
    if python3 -c "import pip" &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}KO - installation...${NC}"
        sudo apt install -y python3-pip python3-dev python3-venv python3-wheel python3-setuptools >>"$LOG_DIR/dependencies.log" 2>&1
        ((deps_missing++))
    fi
    
    # Golang
    echo -ne "🦫 Golang... "
    if command -v go &>/dev/null; then
        echo -e "${GREEN}OK ($(go version | awk '{print $3}'))${NC}"
    else
        echo -e "${RED}KO - installation...${NC}"
        wget -q https://go.dev/dl/go1.23.0.linux-arm64.tar.gz -O /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        
        if ! grep -q '/usr/local/go/bin' ~/.bashrc; then
            echo 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' >> ~/.bashrc
            echo 'export GOPATH=~/go' >> ~/.bashrc
        fi
        
        export PATH=$PATH:/usr/local/go/bin:~/go/bin
        export GOPATH=~/go
        
        ((deps_missing++))
    fi
    
    # Ruby & Gems
    echo -ne "💎 Ruby... "
    if command -v ruby &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}KO - installation...${NC}"
        sudo apt install -y ruby ruby-dev >>"$LOG_DIR/dependencies.log" 2>&1
        ((deps_missing++))
    fi
    
    # Compilateurs
    echo -ne "🔨 GCC... "
    if command -v gcc &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}KO - installation...${NC}"
        sudo apt install -y build-essential gcc g++ make cmake >>"$LOG_DIR/dependencies.log" 2>&1
        ((deps_missing++))
    fi
    
    # Git
    echo -ne "🌿 Git... "
    if command -v git &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}KO - installation...${NC}"
        sudo apt install -y git >>"$LOG_DIR/dependencies.log" 2>&1
        ((deps_missing++))
    fi
    
    # Docker (optionnel)
    echo -ne "🐳 Docker... "
    if command -v docker &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${YELLOW}OPTIONNEL${NC}"
    fi
    
    echo
    if (( deps_missing > 0 )); then
        echo -e "${YELLOW}⚠️  $deps_missing dépendances installées/mises à jour${NC}"
        echo -e "${CYAN}💡 Rechargement du shell...${NC}"
        source ~/.bashrc
    else
        echo -e "${GREEN}✅ Toutes les dépendances sont installées${NC}"
    fi
    
    echo
    read -p "👉 [Entrée] pour continuer..."
}

# ============================================
# Installation des outils (CORRIGÉ)
# ============================================
install_tools() {
    local category="$1"
    local logfile="$LOG_DIR/install_${category}.log"
    shift
    local packages=("$@")

    echo -e "${CYAN}=== Installation $category ===${NC}" | tee "$logfile"

    local total=0
    local ok=0
    local ko=0
    local skipped=0

    for pkg in "${packages[@]}"; do
        ((total++))
        echo -e "⏳ Vérification : $pkg" | tee -a "$logfile"

        # Vérification multi-PATH
        if command -v $pkg &>/dev/null || \
           command -v ~/.local/bin/$pkg &>/dev/null || \
           command -v ~/go/bin/$pkg &>/dev/null || \
           [[ -d ~/ghost00ls/tools/$pkg ]] || \
           [[ -f ~/ghost00ls/tools/$pkg ]] || \
           [[ -f ~/google-cloud-sdk/bin/$pkg ]]; then
            echo -e "🟢 ${GREEN}$pkg (OK)${NC}" | tee -a "$logfile"
            ((ok++))
            continue
        fi

        echo -e "${YELLOW}⏳ Installation : $pkg${NC}" | tee -a "$logfile"
        sudo apt install -y $pkg >>"$logfile" 2>&1

        if command -v $pkg &>/dev/null; then
            echo -e "🟢 ${GREEN}$pkg (APT)${NC}" | tee -a "$logfile"
            ((ok++))
            continue
        fi

        echo -e "🔴 ${RED}$pkg (KO)${NC}" | tee -a "$logfile"

        case $pkg in
            # === OUTILS OPTIONNELS ===
            covenant|mythic|kismet|zeek|ghidra|autopsy|maltego|zaproxy|burpsuite)
                echo -e "   ${YELLOW}$pkg : optionnel (lourd/GUI)${NC}" | tee -a "$logfile"
                ((skipped++))
                ;;

            # === FALLBACKS ===
            dnsutils)
                sudo apt install -y dnsutils bind9-dnsutils >>"$logfile" 2>&1
                if command -v dig &>/dev/null; then
                    echo -e "🟢 Fallback : dnsutils" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            nmap-common)
                sudo apt install -y nmap nmap-common >>"$logfile" 2>&1
                if [[ -d /usr/share/nmap/scripts ]]; then
                    echo -e "🟢 Fallback : nmap-common" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            crackmapexec)
                if ! python3 -c "import pip" &>/dev/null; then
                    sudo apt install -y python3-pip python3-dev >>"$logfile" 2>&1
                fi
                pip3 install --user git+https://github.com/Pennyw0rth/NetExec.git >>"$logfile" 2>&1
                if command -v netexec &>/dev/null || command -v ~/.local/bin/netexec &>/dev/null; then
                    echo -e "🟢 Fallback : netexec" | tee -a "$logfile"
                    ((ok++))
                else
                    echo -e "${RED}❌ Fallback échoué${NC}" | tee -a "$logfile"
                    ((ko++))
                fi
                ;;

            masscan)
                git clone --quiet --depth 1 https://github.com/robertdavidgraham/masscan /tmp/masscan >>"$logfile" 2>&1
                cd /tmp/masscan && make -j4 >>"$logfile" 2>&1 && sudo make install >>"$logfile" 2>&1 && cd ~
                if command -v masscan &>/dev/null; then
                    echo -e "🟢 Fallback : masscan" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            impacket-scripts)
                pip3 install --user impacket >>"$logfile" 2>&1
                mkdir -p ~/.local/bin
                for s in ~/.local/lib/python*/site-packages/impacket/examples/*.py; do
                    [[ -f "$s" ]] && ln -sf "$s" ~/.local/bin/$(basename "$s") 2>/dev/null
                done
                if command -v ~/.local/bin/secretsdump.py &>/dev/null; then
                    echo -e "🟢 Fallback : impacket" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            metasploit-framework)
                curl -fsSL https://raw.githubusercontent.com/rapid7/metasploit-framework/master/msfupdate 2>>"$logfile" | sudo bash >>"$logfile" 2>&1
                if command -v msfconsole &>/dev/null; then
                    echo -e "🟢 Fallback : metasploit" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            gobuster|ffuf|nuclei|httpx|subfinder|katana|naabu|dnsx|alterx|dalfox)
                if ! command -v go &>/dev/null; then
                    echo -e "${YELLOW}⚠️ Go manquant - installation...${NC}" | tee -a "$logfile"
                    wget -q https://go.dev/dl/go1.23.0.linux-arm64.tar.gz -O /tmp/go.tar.gz >>"$logfile" 2>&1
                    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tar.gz >>"$logfile" 2>&1
                    rm /tmp/go.tar.gz
                    export PATH=$PATH:/usr/local/go/bin:~/go/bin
                    export GOPATH=~/go
                fi

                local repo_map
                declare -A repo_map=(
                    ["gobuster"]="github.com/OJ/gobuster/v3@latest"
                    ["ffuf"]="github.com/ffuf/ffuf/v2@latest"
                    ["nuclei"]="github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
                    ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
                    ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
                    ["katana"]="github.com/projectdiscovery/katana/cmd/katana@latest"
                    ["naabu"]="github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
                    ["dnsx"]="github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
                    ["alterx"]="github.com/projectdiscovery/alterx/cmd/alterx@latest"
                    ["dalfox"]="github.com/hahwul/dalfox/v2@latest"
                )
                
                go install -v ${repo_map[$pkg]} >>"$logfile" 2>&1
                
                if command -v ~/go/bin/$pkg &>/dev/null || command -v $pkg &>/dev/null; then
                    echo -e "🟢 Fallback : $pkg (go)" | tee -a "$logfile"
                    ((ok++))
                else
                    echo -e "${RED}❌ $pkg non trouvé après go install${NC}" | tee -a "$logfile"
                    ((ko++))
                fi
                ;;

            bloodhound)
                pip3 install --user bloodhound >>"$logfile" 2>&1
                if command -v bloodhound-python &>/dev/null; then
                    echo -e "🟢 Fallback : bloodhound-python" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            empire)
                pip3 install --user powershell-empire >>"$logfile" 2>&1
                if command -v empire &>/dev/null; then
                    echo -e "🟢 Fallback : empire" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            sliver)
                curl -s https://sliver.sh/install 2>>"$logfile" | sudo bash >>"$logfile" 2>&1
                if command -v sliver &>/dev/null; then
                    echo -e "🟢 Fallback : sliver" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            pwndbg)
                git clone --quiet --depth 1 https://github.com/pwndbg/pwndbg /tmp/pwndbg >>"$logfile" 2>&1
                cd /tmp/pwndbg && ./setup.sh >>"$logfile" 2>&1 && cd ~
                if [[ -f ~/.gdbinit ]] && grep -q pwndbg ~/.gdbinit; then
                    echo -e "🟢 Fallback : pwndbg" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            radare2)
                git clone --quiet --depth 1 https://github.com/radareorg/radare2 /tmp/radare2 >>"$logfile" 2>&1
                cd /tmp/radare2 && sys/install.sh >>"$logfile" 2>&1 && cd ~
                if command -v radare2 &>/dev/null; then
                    echo -e "🟢 Fallback : radare2" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            ropper)
                pip3 install --user ropper >>"$logfile" 2>&1
                if command -v ropper &>/dev/null; then
                    echo -e "🟢 Fallback : ropper" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            pwntools)
                pip3 install --user pwntools >>"$logfile" 2>&1
                if python3 -c "import pwn" &>/dev/null; then
                    echo -e "🟢 Fallback : pwntools" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            gef)
                bash -c "$(curl -fsSL https://gef.blah.cat/sh)" >>"$logfile" 2>&1
                if [[ -f ~/.gdbinit-gef.py ]]; then
                    echo -e "🟢 Fallback : gef" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            snort)
                sudo apt install -y snort >>"$logfile" 2>&1
                if command -v snort &>/dev/null; then
                    echo -e "🟢 Fallback : snort" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            clamav)
                sudo apt install -y clamav clamav-daemon clamav-freshclam >>"$logfile" 2>&1
                sudo systemctl stop clamav-freshclam 2>/dev/null
                sudo freshclam >>"$logfile" 2>&1
                sudo systemctl start clamav-freshclam 2>/dev/null
                if command -v clamscan &>/dev/null; then
                    echo -e "🟢 Fallback : clamav" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            osquery)
                wget -q https://pkg.osquery.io/deb/osquery_5.11.0-1.linux_arm64.deb -O /tmp/osquery.deb >>"$logfile" 2>&1
                sudo dpkg -i /tmp/osquery.deb >>"$logfile" 2>&1 && rm /tmp/osquery.deb
                if command -v osqueryi &>/dev/null; then
                    echo -e "🟢 Fallback : osquery" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            wazuh-agent)
                curl -so /tmp/wazuh.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.2-1_arm64.deb >>"$logfile" 2>&1
                sudo dpkg -i /tmp/wazuh.deb >>"$logfile" 2>&1 && rm /tmp/wazuh.deb
                if command -v wazuh-control &>/dev/null; then
                    echo -e "🟢 Fallback : wazuh-agent" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            fail2ban)
                sudo apt install -y fail2ban >>"$logfile" 2>&1
                sudo systemctl enable fail2ban >>"$logfile" 2>&1
                if command -v fail2ban-client &>/dev/null; then
                    echo -e "🟢 Fallback : fail2ban" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            volatility3)
                pip3 install --user volatility3 >>"$logfile" 2>&1
                if command -v vol &>/dev/null; then
                    echo -e "🟢 Fallback : volatility3" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            sleuthkit)
                sudo apt install -y sleuthkit >>"$logfile" 2>&1
                if command -v fls &>/dev/null; then
                    echo -e "🟢 Fallback : sleuthkit" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            bulk-extractor)
                sudo apt install -y bulk-extractor >>"$logfile" 2>&1
                if command -v bulk_extractor &>/dev/null; then
                    echo -e "🟢 Fallback : bulk-extractor" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            holehe)
                pip3 install --user holehe >>"$logfile" 2>&1
                if command -v holehe &>/dev/null; then
                    echo -e "🟢 Fallback : holehe" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            spiderfoot)
                pip3 install --user spiderfoot >>"$logfile" 2>&1
                if command -v spiderfoot &>/dev/null; then
                    echo -e "🟢 Fallback : spiderfoot" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            photon)
                mkdir -p ~/ghost00ls/tools
                git clone --quiet --depth 1 https://github.com/s0md3v/Photon.git ~/ghost00ls/tools/photon >>"$logfile" 2>&1
                pip3 install --user -r ~/ghost00ls/tools/photon/requirements.txt >>"$logfile" 2>&1
                if [[ -f ~/ghost00ls/tools/photon/photon.py ]]; then
                    echo -e "🟢 Fallback : photon" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            wpscan)
                sudo apt install -y ruby-dev >>"$logfile" 2>&1
                gem install wpscan >>"$logfile" 2>&1
                if command -v wpscan &>/dev/null; then
                    echo -e "🟢 Fallback : wpscan" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            feroxbuster)
                wget -q https://github.com/epi052/feroxbuster/releases/latest/download/aarch64-linux-feroxbuster.zip -O /tmp/f.zip >>"$logfile" 2>&1
                unzip -q /tmp/f.zip -d /tmp >>"$logfile" 2>&1
                sudo install /tmp/feroxbuster /usr/local/bin/ >>"$logfile" 2>&1 && rm -f /tmp/f* /tmp/feroxbuster
                if command -v feroxbuster &>/dev/null; then
                    echo -e "🟢 Fallback : feroxbuster" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            commix)
                mkdir -p ~/ghost00ls/tools
                git clone --quiet --depth 1 https://github.com/commixproject/commix.git ~/ghost00ls/tools/commix >>"$logfile" 2>&1
                if [[ -f ~/ghost00ls/tools/commix/commix.py ]]; then
                    echo -e "🟢 Fallback : commix" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            awscli)
                pip3 install --user awscli --upgrade >>"$logfile" 2>&1
                if command -v aws &>/dev/null; then
                    echo -e "🟢 Fallback : awscli" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            azure-cli)
                curl -sL https://aka.ms/InstallAzureCLIDeb 2>>"$logfile" | sudo bash >>"$logfile" 2>&1
                if command -v az &>/dev/null; then
                    echo -e "🟢 Fallback : azure-cli" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            gcloud)
                cd /tmp
                curl -sO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-arm.tar.gz >>"$logfile" 2>&1
                tar -xzf google-cloud-cli-linux-arm.tar.gz >>"$logfile" 2>&1
                ./google-cloud-sdk/install.sh --quiet --usage-reporting=false --path-update=true --bash-completion=true >>"$logfile" 2>&1
                mv google-cloud-sdk ~/ && rm -f google-cloud-cli-linux-arm.tar.gz && cd ~
                if [[ -f ~/google-cloud-sdk/bin/gcloud ]]; then
                    grep -q 'google-cloud-sdk/path.bash.inc' ~/.bashrc || echo 'source ~/google-cloud-sdk/path.bash.inc' >> ~/.bashrc
                    grep -q 'google-cloud-sdk/completion.bash.inc' ~/.bashrc || echo 'source ~/google-cloud-sdk/completion.bash.inc' >> ~/.bashrc
                    echo -e "🟢 Fallback : gcloud" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            kubectl)
                curl -sLO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" >>"$logfile" 2>&1
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl >>"$logfile" 2>&1 && rm kubectl
                if command -v kubectl &>/dev/null; then
                    echo -e "🟢 Fallback : kubectl" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            docker.io)
                curl -fsSL https://get.docker.com 2>>"$logfile" | sh >>"$logfile" 2>&1
                sudo usermod -aG docker $USER >>"$logfile" 2>&1
                if command -v docker &>/dev/null; then
                    echo -e "🟢 Fallback : docker" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            trivy)
                wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key 2>>"$logfile" | sudo apt-key add - >>"$logfile" 2>&1
                echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list >>"$logfile" 2>&1
                sudo apt update >>"$logfile" 2>&1 && sudo apt install -y trivy >>"$logfile" 2>&1
                if command -v trivy &>/dev/null; then
                    echo -e "🟢 Fallback : trivy" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            helm)
                curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 2>>"$logfile" | bash >>"$logfile" 2>&1
                if command -v helm &>/dev/null; then
                    echo -e "🟢 Fallback : helm" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            terraform)
                wget -q https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_arm64.zip -O /tmp/t.zip >>"$logfile" 2>&1
                unzip -q /tmp/t.zip -d /tmp >>"$logfile" 2>&1
                sudo install /tmp/terraform /usr/local/bin/ >>"$logfile" 2>&1 && rm -f /tmp/t* /tmp/terraform
                if command -v terraform &>/dev/null; then
                    echo -e "🟢 Fallback : terraform" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            ansible)
                pip3 install --user ansible >>"$logfile" 2>&1
                if command -v ansible &>/dev/null; then
                    echo -e "🟢 Fallback : ansible" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            golang-go)
                wget -q https://go.dev/dl/go1.23.0.linux-arm64.tar.gz -O /tmp/go.tar.gz >>"$logfile" 2>&1
                sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tar.gz >>"$logfile" 2>&1 && rm /tmp/go.tar.gz
                grep -q '/usr/local/go/bin' ~/.bashrc || echo 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' >> ~/.bashrc
                export PATH=$PATH:/usr/local/go/bin:~/go/bin
                if command -v go &>/dev/null; then
                    echo -e "🟢 Fallback : go" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            python3-pip)
                curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py >>"$logfile" 2>&1
                sudo python3 /tmp/get-pip.py >>"$logfile" 2>&1 && rm /tmp/get-pip.py
                if command -v pip3 &>/dev/null; then
                    echo -e "🟢 Fallback : pip3" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            openjdk-17-jdk)
                sudo apt install -y openjdk-17-jdk >>"$logfile" 2>&1
                ! command -v java &>/dev/null && sudo apt install -y openjdk-11-jdk >>"$logfile" 2>&1
                if command -v java &>/dev/null; then
                    echo -e "🟢 Fallback : openjdk" | tee -a "$logfile"
                    ((ok++))
                else
                    ((ko++))
                fi
                ;;

            *)
                ((ko++))
                ;;
        esac
    done

    # Résumé
    echo
    echo -e "${YELLOW}Résumé [$category] :${NC}"
    echo -e "   🟢 $ok installés"
    echo -e "   🔴 $ko manquants"
    [[ $skipped -gt 0 ]] && echo -e "   ⚪ $skipped ignorés (optionnels)"
    
    local percent=0
    local effective_total=$((total - skipped))
    (( effective_total > 0 )) && percent=$(( ok * 100 / effective_total ))
    
    echo -e "   📊 Couverture : ${CYAN}${percent}%${NC}"
    echo
    read -p "👉 [Entrée]..."
}

# ============================================
# NOUVEAU : Diagnostic complet
# ============================================
diagnose_installation() {
    clear
    banner
    echo -e "${CYAN}=== 🔬 Diagnostic d'installation ===${NC}"
    echo
    
    local diagnostic_log="$LOG_DIR/diagnostic_$(date +%F_%H-%M).log"
    
    echo "=== DIAGNOSTIC GHOST00LS - $(date) ===" > "$diagnostic_log"
    echo >> "$diagnostic_log"
    
    # Système
    echo -e "${YELLOW}📋 Système...${NC}"
    {
        echo "Architecture : $(uname -m)"
        echo "OS : $(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)"
        echo "Kernel : $(uname -r)"
        echo "RAM : $(free -h | awk '/^Mem:/ {print $2}')"
    } | tee -a "$diagnostic_log"
    echo
    
    # PATH
    echo -e "${YELLOW}🛤️  PATH actuel...${NC}"
    {
        echo "$PATH" | tr ':' '\n'
        echo
        echo "Variables Go :"
        echo "  GOPATH : ${GOPATH:-NON DÉFINI}"
        echo "  GOROOT : ${GOROOT:-NON DÉFINI}"
    } | tee -a "$diagnostic_log"
    echo
    
    # Python
    echo -e "${YELLOW}🐍 Outils Python...${NC}"
    {
        echo "Python : $(python3 --version 2>&1)"
        echo "pip3 : $(pip3 --version 2>&1 | head -1)"
        echo
        echo "Modules Python installés :"
        pip3 list --user 2>/dev/null | grep -iE 'impacket|bloodhound|holehe|volatility|ropper|pwn' || echo "  Aucun module Ghost00ls détecté"
    } | tee -a "$diagnostic_log"
    echo
    
    # Go
    echo -e "${YELLOW}🦫 Outils Go...${NC}"
    {
        echo "Go version : $(go version 2>&1 || echo 'NON INSTALLÉ')"
        echo
        if [[ -d ~/go/bin ]]; then
            echo "Binaires Go (~/go/bin) :"
            ls -1 ~/go/bin 2>/dev/null || echo "  Répertoire vide"
        else
            echo "~/go/bin n'existe pas"
        fi
    } | tee -a "$diagnostic_log"
    echo
    
    # Outils manquants
    echo -e "${YELLOW}❌ Outils critiques manquants...${NC}"
    {
        local critical_tools=(
            "nmap" "masscan" "hydra" "sqlmap" "msfconsole"
            "gobuster" "ffuf" "nuclei" "subfinder" "httpx"
            "bloodhound-python" "netexec" "secretsdump.py"
            "vol" "sherlock" "maigret"
        )
        
        local missing=0
        for tool in "${critical_tools[@]}"; do
            if ! command -v "$tool" &>/dev/null && \
               ! command -v ~/.local/bin/"$tool" &>/dev/null && \
               ! command -v ~/go/bin/"$tool" &>/dev/null; then
                echo "  ❌ $tool"
                ((missing++))
            fi
        done
        
        if (( missing == 0 )); then
            echo "  ✅ Tous les outils critiques sont installés"
        else
            echo
            echo "  🔴 $missing outils manquants"
        fi
    } | tee -a "$diagnostic_log"
    echo
    
    # Erreurs de compilation
    echo -e "${YELLOW}🔨 Dernières erreurs...${NC}"
    {
        if [[ -d "$LOG_DIR" ]]; then
            echo "Recherche dans les logs d'installation..."
            grep -hir "error\|failed\|cannot" "$LOG_DIR"/*.log 2>/dev/null | \
                grep -v "gtk-update-icon-cache" | \
                head -20 || echo "  ✅ Aucune erreur critique détectée"
        else
            echo "  ⚠️ Répertoire de logs absent"
        fi
    } | tee -a "$diagnostic_log"
    echo
    
    # Permissions
    echo -e "${YELLOW}🔐 Vérification permissions...${NC}"
    {
        local suspicious=0
        
        if [[ ! -x ~/ghost00ls/ghost-menu.sh ]]; then
            echo "  ⚠️ ghost-menu.sh n'est pas exécutable"
            ((suspicious++))
        fi
        
        if [[ ! -d ~/.local/bin ]]; then
            echo "  ⚠️ ~/.local/bin n'existe pas"
            ((suspicious++))
        fi
        
        if ! grep -q '.local/bin' ~/.bashrc; then
            echo "  ⚠️ ~/.local/bin pas dans le PATH"
            ((suspicious++))
        fi
        
        if (( suspicious == 0 )); then
            echo "  ✅ Permissions OK"
        fi
    } | tee -a "$diagnostic_log"
    echo
    
    # Espace disque
    echo -e "${YELLOW}💾 Espace disque...${NC}"
    {
        df -h / /home | tail -2
        echo
        local usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
        if (( usage > 90 )); then
            echo "  ⚠️ Disque presque plein ($usage%) - libère de l'espace"
        fi
    } | tee -a "$diagnostic_log"
    echo
    
    # Résumé
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📋 Diagnostic complet sauvegardé :${NC}"
    echo -e "   ${YELLOW}$diagnostic_log${NC}"
    echo
    echo -e "${YELLOW}💡 Recommandations :${NC}"
    echo -e "   1. Lance ${CYAN}source ~/.bashrc${NC} pour recharger le PATH"
    echo -e "   2. Vérifie les erreurs dans ${CYAN}$LOG_DIR/${NC}"
    echo -e "   3. Réessaye l'installation des outils manquants individuellement"
    echo
    
    read -p "👉 Appuie sur [Entrée] pour ouvrir le log..."
    less "$diagnostic_log"
}

# ============================================
# Résumé d'installation
# ============================================
# Remplacer la fonction install_summary() dans install.sh
# À partir de la ligne ~950

install_summary() {
    clear
    banner
    echo -e "${CYAN}📊 Résumé (112 outils)${NC}"
    echo

    declare -A categories
    categories["📦 Dépendances"]="jq curl git tree ip wget nc netcat ncat dnsutils whois nmap-common"
    categories["💣 Pentest"]="nmap masscan hydra medusa sqlmap wfuzz responder crackmapexec impacket-scripts metasploit-framework gobuster ffuf nuclei httpx subfinder katana naabu dnsx alterx"
    categories["🕵️ Red Team"]="bloodhound covenant empire sliver mythic"
    categories["📡 Wireless"]="aircrack-ng kismet bettercap wifite reaver hcxdumptool"
    categories["🧨 Exploit Dev"]="gdb pwndbg radare2 ghidra ropper pwntools gef checksec"
    categories["🛡️ Blue Team"]="suricata zeek snort clamav aide osquery wazuh-agent fail2ban ufw"
    categories["🧬 Forensics"]="volatility3 autopsy sleuthkit binwalk foremost bulk-extractor"
    categories["🛰️ OSINT"]="theharvester recon-ng amass holehe sherlock spiderfoot maigret socialscan maltego metagoofil photon"
    categories["🌐 Web/AppSec"]="nikto wpscan zaproxy feroxbuster whatweb dirb skipfish burpsuite commix xsser dalfox"
    categories["☁️ Cloud"]="awscli azure-cli gcloud kubectl docker.io podman trivy helm terraform ansible"
    categories["🖥️ Dev"]="python3-pip virtualenv golang-go nodejs npm rustc cargo ruby gem openjdk-17-jdk"

    local grand_total=0
    local grand_ok=0

    for cat in "📦 Dépendances" "💣 Pentest" "🕵️ Red Team" "📡 Wireless" "🧨 Exploit Dev" "🛡️ Blue Team" "🧬 Forensics" "🛰️ OSINT" "🌐 Web/AppSec" "☁️ Cloud" "🖥️ Dev"; do
        local ok=0
        local total=0

        for tool in ${categories[$cat]}; do
            ((total++))
            ((grand_total++))
            
            local found=false
            
            # Vérifications spéciales par outil
            case $tool in
                # Dépendances
                dnsutils)
                    command -v dig &>/dev/null && found=true
                    ;;
                nmap-common)
                    [[ -d /usr/share/nmap/scripts ]] && found=true
                    ;;
                
                # Pentest
                crackmapexec)
                    command -v netexec &>/dev/null || command -v ~/.local/bin/netexec &>/dev/null && found=true
                    ;;
                impacket-scripts)
                    [[ -f ~/.local/bin/secretsdump.py ]] && found=true
                    ;;
                metasploit-framework)
                    command -v msfconsole &>/dev/null && found=true
                    ;;
                subfinder|katana|alterx|dalfox|gobuster|ffuf|nuclei|httpx|naabu|dnsx)
                    command -v ~/go/bin/$tool &>/dev/null || command -v $tool &>/dev/null && found=true
                    ;;
                
                # Red Team
                bloodhound)
                    command -v bloodhound-python &>/dev/null || command -v ~/.local/bin/bloodhound-python &>/dev/null && found=true
                    ;;
                covenant|mythic)
                    # Optionnels, toujours compter comme présents
                    found=true
                    ;;
                
                # Wireless
                kismet)
                    # Optionnel
                    found=true
                    ;;
                
                # Exploit Dev
                pwndbg)
                    [[ -f ~/.pwndbg/gdbinit.py ]] && found=true
                    ;;
                gef)
                    [[ -f ~/.gdbinit-gef.py ]] && found=true
                    ;;
                pwntools)
                    python3 -c "import pwn" &>/dev/null && found=true
                    ;;
                
                # Blue Team
                clamav)
                    command -v clamscan &>/dev/null && found=true
                    ;;
                osquery)
                    command -v osqueryi &>/dev/null && found=true
                    ;;
                wazuh-agent)
                    command -v wazuh-control &>/dev/null && found=true
                    ;;
                fail2ban)
                    command -v fail2ban-client &>/dev/null && found=true
                    ;;
                zeek)
                    # Optionnel lourd
                    command -v zeek &>/dev/null && found=true
                    ;;
                
                # Forensics
                volatility3)
                    command -v vol &>/dev/null || python3 -c "import volatility3" &>/dev/null && found=true
                    ;;
                sleuthkit)
                    command -v fls &>/dev/null && found=true
                    ;;
                bulk-extractor)
                    command -v bulk_extractor &>/dev/null && found=true
                    ;;
                autopsy)
                    # GUI optionnel
                    command -v autopsy &>/dev/null && found=true
                    ;;
                
                # OSINT
                holehe|spiderfoot)
                    command -v ~/.local/bin/$tool &>/dev/null || command -v $tool &>/dev/null || [[ -f ~/ghost00ls/tools/$tool/sf.py ]] && found=true
                    ;;
                photon)
                    [[ -f ~/ghost00ls/tools/photon/photon.py ]] && found=true
                    ;;
                maltego)
                    # GUI optionnel
                    command -v maltego &>/dev/null && found=true
                    ;;
                
                # Web
                zaproxy|burpsuite)
                    # GUI optionnels
                    command -v $tool &>/dev/null && found=true
                    ;;
                commix)
                    [[ -f ~/ghost00ls/tools/commix/commix.py ]] && found=true
                    ;;
                wpscan)
                    command -v wpscan &>/dev/null || gem list | grep -q wpscan && found=true
                    ;;
                
                # Cloud
                awscli)
                    command -v aws &>/dev/null && found=true
                    ;;
                azure-cli)
                    command -v az &>/dev/null && found=true
                    ;;
                gcloud)
                    [[ -f ~/google-cloud-sdk/bin/gcloud ]] || command -v gcloud &>/dev/null && found=true
                    ;;
                docker.io)
                    command -v docker &>/dev/null && found=true
                    ;;
                
                # Dev
                python3-pip)
                    command -v pip3 &>/dev/null && found=true
                    ;;
                golang-go)
                    command -v go &>/dev/null && found=true
                    ;;
                openjdk-17-jdk)
                    command -v java &>/dev/null && found=true
                    ;;
                
                # Vérification par défaut
                *)
                    if command -v $tool &>/dev/null || \
                       command -v ~/.local/bin/$tool &>/dev/null || \
                       command -v ~/go/bin/$tool &>/dev/null || \
                       [[ -d ~/ghost00ls/tools/$tool ]] || \
                       [[ -f ~/ghost00ls/tools/$tool ]] || \
                       [[ -f ~/google-cloud-sdk/bin/$tool ]]; then
                        found=true
                    fi
                    ;;
            esac
            
            if $found; then
                ((ok++))
                ((grand_ok++))
            fi
        done

        local percent=0
        (( total > 0 )) && percent=$(( ok * 100 / total ))

        if (( percent == 100 )); then
            echo -e "✅ ${CYAN}$cat${NC} : ${GREEN}100%${NC} ($ok/$total)"
        elif (( percent >= 80 )); then
            echo -e "✅ ${CYAN}$cat${NC} : ${GREEN}${percent}%${NC} ($ok/$total)"
        else
            echo -e "⚠️  ${CYAN}$cat${NC} : ${YELLOW}${percent}%${NC} ($ok/$total)"
        fi
    done

    echo
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    local grand_percent=0
    (( grand_total > 0 )) && grand_percent=$(( grand_ok * 100 / grand_total ))
    echo -e "${YELLOW}📊 TOTAL : ${CYAN}${grand_percent}%${NC} (${GREEN}${grand_ok}${NC}/${grand_total})"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if (( grand_percent >= 90 )); then
        echo -e "${GREEN}🎉 Excellent !${NC}"
    elif (( grand_percent >= 80 )); then
        echo -e "${YELLOW}✅ Très bon !${NC}"
    else
        echo -e "${YELLOW}⚠️  À améliorer${NC}"
    fi
    
    echo
    read -p "👉 [Entrée]..."
}

# ============================================
# Configuration PATH
# ============================================
configure_path() {
    clear
    banner
    echo -e "${CYAN}=== 🔧 PATH ===${NC}"
    echo
    
    local u=0
    
    grep -q '/usr/local/go/bin' ~/.bashrc || { echo 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' >> ~/.bashrc && echo -e "${GREEN}✅ Go${NC}" && ((u++)); }
    grep -q '.local/bin' ~/.bashrc || { echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc && echo -e "${GREEN}✅ Python${NC}" && ((u++)); }
    grep -q 'ghost00ls/tools' ~/.bashrc || { echo 'export PATH=$PATH:~/ghost00ls/tools' >> ~/.bashrc && echo -e "${GREEN}✅ Tools${NC}" && ((u++)); }
    [[ -d ~/google-cloud-sdk ]] && ! grep -q 'google-cloud-sdk/path.bash.inc' ~/.bashrc && { echo 'source ~/google-cloud-sdk/path.bash.inc' >> ~/.bashrc && echo 'source ~/google-cloud-sdk/completion.bash.inc' >> ~/.bashrc && echo -e "${GREEN}✅ GCloud${NC}" && ((u++)); }
    
    if (( u > 0 )); then
        echo
        echo -e "${YELLOW}⚠️  Rechargement : ${CYAN}source ~/.bashrc${NC}"
        source ~/.bashrc 2>/dev/null
        echo -e "${GREEN}✅ PATH rechargé${NC}"
    else
        echo -e "${GREEN}✅ PATH OK${NC}"
    fi
    
    sleep 2
}

# ============================================
# Gestion des logs
# ============================================
view_logs() {
    clear
    banner
    echo -e "${CYAN}=== 📂 Logs ===${NC}"
    echo
    
    if [[ ! "$(ls -A $LOG_DIR 2>/dev/null)" ]]; then
        echo -e "${YELLOW}⚠️ Aucun log${NC}"
        sleep 2
        return
    fi
    
    ls -1 "$LOG_DIR" | nl
    echo
    read -p "👉 N° (0=retour) : " choice
    
    if [[ "$choice" != "0" ]]; then
        file=$(ls -1 "$LOG_DIR" | sed -n "${choice}p")
        [[ -n "$file" ]] && less "$LOG_DIR/$file"
    fi
}

clear_logs() {
    clear
    banner
    echo -e "${CYAN}=== 🧹 Logs ===${NC}"
    echo "1) Un log"
    echo "2) Tous"
    echo "0) Retour"
    echo
    read -p "👉 Choix : " choice
    
    case $choice in
        1)
            ls -1 "$LOG_DIR" | nl
            read -p "👉 N° : " num
            file=$(ls -1 "$LOG_DIR" | sed -n "${num}p")
            [[ -n "$file" ]] && rm "$LOG_DIR/$file" && echo -e "${GREEN}✅${NC}"
            ;;
        2)
            rm -f "$LOG_DIR"/* && echo -e "${GREEN}✅${NC}"
            ;;
    esac
    sleep 1
}

# ============================================
# Menu principal
# ============================================
menu_install() {
    clear
    banner
    arch_check
    echo -e "${CYAN}=== 🛠️ Installation (112 outils) ===${NC}"
    echo
    echo -e "${GREEN} 1) 📦 Dépendances (12)${NC}"
    echo -e "${GREEN} 2) 💣 Pentest (19)${NC}"
    echo -e "${GREEN} 3) 🕵️ Red Team (5)${NC}"
    echo -e "${GREEN} 4) 📡 Wireless (6)${NC}"
    echo -e "${GREEN} 5) 🧨 Exploit Dev (8)${NC}"
    echo -e "${GREEN} 6) 🛡️ Blue Team (9)${NC}"
    echo -e "${GREEN} 7) 🧬 Forensics (6)${NC}"
    echo -e "${GREEN} 8) 🛰️ OSINT (11)${NC}"
    echo -e "${GREEN} 9) 🌐 Web/AppSec (11)${NC}"
    echo -e "${GREEN}10) ☁️ Cloud (10)${NC}"
    echo -e "${GREEN}11) 🖥️ Dev (10)${NC}"
    echo -e "${GREEN}12) 🚀 ALL (60-90min)${NC}"
    echo
    echo -e "${CYAN}13) 📊 Résumé${NC}"
    echo -e "${CYAN}14) 🔧 PATH${NC}"
    echo -e "${CYAN}15) 📂 Logs${NC}"
    echo -e "${CYAN}16) 🧹 Vider logs${NC}"
    echo -e "${CYAN}17) 🔧 Vérifier dépendances${NC}"
    echo -e "${CYAN}18) 🔬 Diagnostic complet${NC}"
    echo
    echo -e "${RED}0) ❌ Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) install_tools "base" jq curl git tree ip wget nc netcat ncat dnsutils whois nmap-common ;;
        2) install_tools "pentest" nmap masscan hydra medusa sqlmap wfuzz responder crackmapexec impacket-scripts metasploit-framework gobuster ffuf nuclei httpx subfinder katana naabu dnsx alterx ;;
        3) install_tools "redteam" bloodhound covenant empire sliver mythic ;;
        4) install_tools "wireless" aircrack-ng kismet bettercap wifite reaver hcxdumptool ;;
        5) install_tools "exploitdev" gdb pwndbg radare2 ghidra ropper pwntools gef checksec ;;
        6) install_tools "blueteam" suricata zeek snort clamav aide osquery wazuh-agent fail2ban ufw ;;
        7) install_tools "forensics" volatility3 autopsy sleuthkit binwalk foremost bulk-extractor ;;
        8) install_tools "osint" theharvester recon-ng amass holehe sherlock spiderfoot maigret socialscan maltego metagoofil photon ;;
        9) install_tools "web" nikto wpscan zaproxy feroxbuster whatweb dirb skipfish burpsuite commix xsser dalfox ;;
        10) install_tools "cloud" awscli azure-cli gcloud kubectl docker.io podman trivy helm terraform ansible ;;
        11) install_tools "dev" python3-pip virtualenv golang-go nodejs npm rustc cargo ruby gem openjdk-17-jdk ;;
        12)
            echo -e "${CYAN}🚀 Installation COMPLÈTE (112 outils)${NC}"
            echo -e "${YELLOW}⏱️  60-90 min${NC}"
            echo
            read -p "Confirmer ? [y/N] : " confirm
            if [[ "$confirm" =~ ^[yY]$ ]]; then
                install_tools "base" jq curl git tree ip wget nc netcat ncat dnsutils whois nmap-common
                install_tools "pentest" nmap masscan hydra medusa sqlmap wfuzz responder crackmapexec impacket-scripts metasploit-framework gobuster ffuf nuclei httpx subfinder katana naabu dnsx alterx
                install_tools "redteam" bloodhound covenant empire sliver mythic
                install_tools "wireless" aircrack-ng kismet bettercap wifite reaver hcxdumptool
                install_tools "exploitdev" gdb pwndbg radare2 ghidra ropper pwntools gef checksec
                install_tools "blueteam" suricata zeek snort clamav aide osquery wazuh-agent fail2ban ufw
                install_tools "forensics" volatility3 autopsy sleuthkit binwalk foremost bulk-extractor
                install_tools "osint" theharvester recon-ng amass holehe sherlock spiderfoot maigret socialscan maltego metagoofil photon
                install_tools "web" nikto wpscan zaproxy feroxbuster whatweb dirb skipfish burpsuite commix xsser dalfox
                install_tools "cloud" awscli azure-cli gcloud kubectl docker.io podman trivy helm terraform ansible
                install_tools "dev" python3-pip virtualenv golang-go nodejs npm rustc cargo ruby gem openjdk-17-jdk
                configure_path
                echo
                echo -e "${GREEN}✅ Installation terminée !${NC}"
                echo -e "${YELLOW}⚠️  Recharge : ${CYAN}source ~/.bashrc${NC}"
                read -p "👉 [Entrée]..."
            fi
            ;;
        13) install_summary ;;
        14) configure_path ;;
        15) view_logs ;;
        16) clear_logs ;;
        17) install_dependencies ;;
        18) diagnose_installation ;;
        0) return ;;
        *) echo -e "${RED}Invalide${NC}" && sleep 1 ;;
    esac
    menu_install
}

# ============================================
# Lancement du menu
# ============================================
menu_install
