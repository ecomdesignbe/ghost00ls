#!/bin/bash
# Ghost00ls v2.1 - Installation Script FINAL OPTIMISÉ
# 112 outils cybersécurité ARM64
# Copier-coller ce fichier dans ~/ghost00ls/modules/install.sh

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh

LOG_DIR=~/ghost00ls/logs/system
mkdir -p "$LOG_DIR"

arch_check() {
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo -e "${RED}⚠️ ARM64 recommandé (détecté : $(uname -m))${NC}"
    fi
}

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
        else
            echo -e "🔴 ${RED}$pkg (KO)${NC}" | tee -a "$logfile"
            ((ko++))

            case $pkg in
                dnsutils)
                    sudo apt install -y dnsutils bind9-dnsutils >>"$logfile" 2>&1
                    command -v dig &>/dev/null && echo -e "🟢 Fallback : dnsutils" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                nmap-common)
                    sudo apt install -y nmap nmap-common >>"$logfile" 2>&1
                    [[ -d /usr/share/nmap/scripts ]] && echo -e "🟢 Fallback : nmap-common" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                crackmapexec)
                    pip3 install --user git+https://github.com/Pennyw0rth/NetExec.git >>"$logfile" 2>&1
                    command -v netexec &>/dev/null && echo -e "🟢 Fallback : netexec" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                masscan)
                    git clone --quiet --depth 1 https://github.com/robertdavidgraham/masscan /tmp/masscan >>"$logfile" 2>&1
                    cd /tmp/masscan && make -j4 >>"$logfile" 2>&1 && sudo make install >>"$logfile" 2>&1 && cd ~
                    command -v masscan &>/dev/null && echo -e "🟢 Fallback : masscan" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                impacket-scripts)
                    pip3 install --user impacket >>"$logfile" 2>&1
                    mkdir -p ~/.local/bin
                    for s in ~/.local/lib/python*/site-packages/impacket/examples/*.py; do
                        [[ -f "$s" ]] && ln -sf "$s" ~/.local/bin/$(basename "$s") 2>/dev/null
                    done
                    command -v ~/.local/bin/secretsdump.py &>/dev/null && echo -e "🟢 Fallback : impacket" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                metasploit-framework)
                    curl -fsSL https://raw.githubusercontent.com/rapid7/metasploit-framework/master/msfupdate 2>>"$logfile" | sudo bash >>"$logfile" 2>&1
                    command -v msfconsole &>/dev/null && echo -e "🟢 Fallback : metasploit" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                gobuster|ffuf|nuclei|httpx|subfinder|katana|naabu|dnsx|alterx|dalfox)
                    local repo_map=(
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
                    command -v ~/go/bin/$pkg &>/dev/null && echo -e "🟢 Fallback : $pkg (go)" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                bloodhound)
                    pip3 install --user bloodhound >>"$logfile" 2>&1
                    command -v bloodhound-python &>/dev/null && echo -e "🟢 Fallback : bloodhound-python" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                empire)
                    pip3 install --user powershell-empire >>"$logfile" 2>&1
                    command -v empire &>/dev/null && echo -e "🟢 Fallback : empire" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                sliver)
                    curl -s https://sliver.sh/install 2>>"$logfile" | sudo bash >>"$logfile" 2>&1
                    command -v sliver &>/dev/null && echo -e "🟢 Fallback : sliver" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                pwndbg)
                    git clone --quiet --depth 1 https://github.com/pwndbg/pwndbg /tmp/pwndbg >>"$logfile" 2>&1
                    cd /tmp/pwndbg && ./setup.sh >>"$logfile" 2>&1 && cd ~
                    [[ -f ~/.gdbinit ]] && grep -q pwndbg ~/.gdbinit && echo -e "🟢 Fallback : pwndbg" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                radare2)
                    git clone --quiet --depth 1 https://github.com/radareorg/radare2 /tmp/radare2 >>"$logfile" 2>&1
                    cd /tmp/radare2 && sys/install.sh >>"$logfile" 2>&1 && cd ~
                    command -v radare2 &>/dev/null && echo -e "🟢 Fallback : radare2" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                ropper)
                    pip3 install --user ropper >>"$logfile" 2>&1
                    command -v ropper &>/dev/null && echo -e "🟢 Fallback : ropper" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                pwntools)
                    pip3 install --user pwntools >>"$logfile" 2>&1
                    python3 -c "import pwn" &>/dev/null && echo -e "🟢 Fallback : pwntools" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                gef)
                    bash -c "$(curl -fsSL https://gef.blah.cat/sh)" >>"$logfile" 2>&1
                    [[ -f ~/.gdbinit-gef.py ]] && echo -e "🟢 Fallback : gef" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                snort)
                    sudo apt install -y snort >>"$logfile" 2>&1
                    command -v snort &>/dev/null && echo -e "🟢 Fallback : snort" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                clamav)
                    sudo apt install -y clamav clamav-daemon clamav-freshclam >>"$logfile" 2>&1
                    sudo systemctl stop clamav-freshclam 2>/dev/null
                    sudo freshclam >>"$logfile" 2>&1
                    sudo systemctl start clamav-freshclam 2>/dev/null
                    command -v clamscan &>/dev/null && echo -e "🟢 Fallback : clamav" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                osquery)
                    wget -q https://pkg.osquery.io/deb/osquery_5.11.0-1.linux_arm64.deb -O /tmp/osquery.deb >>"$logfile" 2>&1
                    sudo dpkg -i /tmp/osquery.deb >>"$logfile" 2>&1 && rm /tmp/osquery.deb
                    command -v osqueryi &>/dev/null && echo -e "🟢 Fallback : osquery" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                wazuh-agent)
                    curl -so /tmp/wazuh.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.2-1_arm64.deb >>"$logfile" 2>&1
                    sudo dpkg -i /tmp/wazuh.deb >>"$logfile" 2>&1 && rm /tmp/wazuh.deb
                    command -v wazuh-control &>/dev/null && echo -e "🟢 Fallback : wazuh-agent" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                fail2ban)
                    sudo apt install -y fail2ban >>"$logfile" 2>&1
                    sudo systemctl enable fail2ban >>"$logfile" 2>&1
                    command -v fail2ban-client &>/dev/null && echo -e "🟢 Fallback : fail2ban" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                volatility3)
                    pip3 install --user volatility3 >>"$logfile" 2>&1
                    command -v vol &>/dev/null && echo -e "🟢 Fallback : volatility3" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                sleuthkit)
                    sudo apt install -y sleuthkit >>"$logfile" 2>&1
                    command -v fls &>/dev/null && echo -e "🟢 Fallback : sleuthkit" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                bulk-extractor)
                    sudo apt install -y bulk-extractor >>"$logfile" 2>&1
                    command -v bulk_extractor &>/dev/null && echo -e "🟢 Fallback : bulk-extractor" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                holehe)
                    pip3 install --user holehe >>"$logfile" 2>&1
                    command -v holehe &>/dev/null && echo -e "🟢 Fallback : holehe" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                spiderfoot)
                    pip3 install --user spiderfoot >>"$logfile" 2>&1
                    command -v spiderfoot &>/dev/null && echo -e "🟢 Fallback : spiderfoot" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                photon)
                    mkdir -p ~/ghost00ls/tools
                    git clone --quiet --depth 1 https://github.com/s0md3v/Photon.git ~/ghost00ls/tools/photon >>"$logfile" 2>&1
                    pip3 install --user -r ~/ghost00ls/tools/photon/requirements.txt >>"$logfile" 2>&1
                    [[ -f ~/ghost00ls/tools/photon/photon.py ]] && echo -e "🟢 Fallback : photon" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                wpscan)
                    sudo apt install -y ruby-dev >>"$logfile" 2>&1
                    gem install wpscan >>"$logfile" 2>&1
                    command -v wpscan &>/dev/null && echo -e "🟢 Fallback : wpscan" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                feroxbuster)
                    wget -q https://github.com/epi052/feroxbuster/releases/latest/download/aarch64-linux-feroxbuster.zip -O /tmp/f.zip >>"$logfile" 2>&1
                    unzip -q /tmp/f.zip -d /tmp >>"$logfile" 2>&1
                    sudo install /tmp/feroxbuster /usr/local/bin/ >>"$logfile" 2>&1 && rm -f /tmp/f* /tmp/feroxbuster
                    command -v feroxbuster &>/dev/null && echo -e "🟢 Fallback : feroxbuster" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                commix)
                    mkdir -p ~/ghost00ls/tools
                    git clone --quiet --depth 1 https://github.com/commixproject/commix.git ~/ghost00ls/tools/commix >>"$logfile" 2>&1
                    [[ -f ~/ghost00ls/tools/commix/commix.py ]] && echo -e "🟢 Fallback : commix" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                awscli)
                    pip3 install --user awscli --upgrade >>"$logfile" 2>&1
                    command -v aws &>/dev/null && echo -e "🟢 Fallback : awscli" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                azure-cli)
                    curl -sL https://aka.ms/InstallAzureCLIDeb 2>>"$logfile" | sudo bash >>"$logfile" 2>&1
                    command -v az &>/dev/null && echo -e "🟢 Fallback : azure-cli" | tee -a "$logfile" && ((ok++)) && ((ko--))
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
                        echo -e "🟢 Fallback : gcloud" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    fi
                    ;;
                kubectl)
                    curl -sLO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" >>"$logfile" 2>&1
                    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl >>"$logfile" 2>&1 && rm kubectl
                    command -v kubectl &>/dev/null && echo -e "🟢 Fallback : kubectl" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                docker.io)
                    curl -fsSL https://get.docker.com 2>>"$logfile" | sh >>"$logfile" 2>&1
                    sudo usermod -aG docker $USER >>"$logfile" 2>&1
                    command -v docker &>/dev/null && echo -e "🟢 Fallback : docker" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                trivy)
                    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key 2>>"$logfile" | sudo apt-key add - >>"$logfile" 2>&1
                    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list >>"$logfile" 2>&1
                    sudo apt update >>"$logfile" 2>&1 && sudo apt install -y trivy >>"$logfile" 2>&1
                    command -v trivy &>/dev/null && echo -e "🟢 Fallback : trivy" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                helm)
                    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 2>>"$logfile" | bash >>"$logfile" 2>&1
                    command -v helm &>/dev/null && echo -e "🟢 Fallback : helm" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                terraform)
                    wget -q https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_arm64.zip -O /tmp/t.zip >>"$logfile" 2>&1
                    unzip -q /tmp/t.zip -d /tmp >>"$logfile" 2>&1
                    sudo install /tmp/terraform /usr/local/bin/ >>"$logfile" 2>&1 && rm -f /tmp/t* /tmp/terraform
                    command -v terraform &>/dev/null && echo -e "🟢 Fallback : terraform" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                ansible)
                    pip3 install --user ansible >>"$logfile" 2>&1
                    command -v ansible &>/dev/null && echo -e "🟢 Fallback : ansible" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                golang-go)
                    wget -q https://go.dev/dl/go1.23.0.linux-arm64.tar.gz -O /tmp/go.tar.gz >>"$logfile" 2>&1
                    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tar.gz >>"$logfile" 2>&1 && rm /tmp/go.tar.gz
                    grep -q '/usr/local/go/bin' ~/.bashrc || echo 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' >> ~/.bashrc
                    export PATH=$PATH:/usr/local/go/bin:~/go/bin
                    command -v go &>/dev/null && echo -e "🟢 Fallback : go" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                python3-pip)
                    curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py >>"$logfile" 2>&1
                    sudo python3 /tmp/get-pip.py >>"$logfile" 2>&1 && rm /tmp/get-pip.py
                    command -v pip3 &>/dev/null && echo -e "🟢 Fallback : pip3" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                openjdk-17-jdk)
                    sudo apt install -y openjdk-17-jdk >>"$logfile" 2>&1
                    ! command -v java &>/dev/null && sudo apt install -y openjdk-11-jdk >>"$logfile" 2>&1
                    command -v java &>/dev/null && echo -e "🟢 Fallback : openjdk" | tee -a "$logfile" && ((ok++)) && ((ko--))
                    ;;
                covenant|mythic|kismet|zeek|ghidra|autopsy|maltego|zaproxy|burpsuite)
                    echo -e "   ${YELLOW}$pkg : optionnel (lourd/GUI)${NC}" | tee -a "$logfile"
                    ;;
            esac
        fi
    done

    echo
    echo -e "${YELLOW}Résumé [$category] :${NC}"
    echo -e "   🟢 $ok installés"
    echo -e "   🔴 $ko manquants"
    local percent=0
    (( total > 0 )) && percent=$(( ok * 100 / total ))
    echo -e "   📊 Couverture : ${CYAN}${percent}%${NC}"
    echo
    read -p "👉 [Entrée]..."
}

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
            
            if command -v $tool &>/dev/null || \
               command -v ~/.local/bin/$tool &>/dev/null || \
               command -v ~/go/bin/$tool &>/dev/null || \
               [[ -d ~/ghost00ls/tools/$tool ]] || \
               [[ -f ~/ghost00ls/tools/$tool ]] || \
               [[ -f ~/google-cloud-sdk/bin/$tool ]]; then
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
    
    (( u > 0 )) && echo -e "\n${YELLOW}⚠️  Recharge : ${CYAN}source ~/.bashrc${NC}" || echo -e "${GREEN}✅ PATH OK${NC}"
    sleep 2
}

view_logs() {
    clear; banner
    echo -e "${CYAN}=== 📂 Logs ===${NC}"
    echo
    [[ ! "$(ls -A $LOG_DIR 2>/dev/null)" ]] && echo -e "${YELLOW}⚠️ Aucun log${NC}" && sleep 2 && return
    ls -1 "$LOG_DIR" | nl
    echo
    read -p "👉 N° (0=retour) : " choice
    [[ "$choice" != "0" ]] && file=$(ls -1 "$LOG_DIR" | sed -n "${choice}p") && [[ -n "$file" ]] && less "$LOG_DIR/$file"
}

clear_logs() {
    clear; banner
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
    echo -e "${YELLOW}13) 📊 Résumé${NC}"
    echo -e "${YELLOW}14) 🔧 PATH${NC}"
    echo -e "${YELLOW}15) 📂 Logs${NC}"
    echo -e "${YELLOW}16) 🧹 Vider logs${NC}"
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
        0) return ;;
        *) echo -e "${RED}Invalide${NC}" && sleep 1 ;;
    esac
    menu_install
}

menu_install
