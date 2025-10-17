#!/bin/bash
# Ghost-Framework - Full CyberSec Edition
# Author: Steve Vandenbossche (ecomdesign.be)
# Platform: Raspberry Pi 5 - Kali Linux

# === Imports ===
source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/lib/config.sh


# === Menu Principal ===
while true; do
    clear
    banner
    echo -e "${CYAN}================= MENU PRINCIPAL =================${NC}"
    echo
    echo -e "${GREEN} 1) 🤖  GhostGPT LIVE${NC}"
    echo -e "${GREEN} 2) 🛠️  Installation des outils${NC}"
    echo -e "${GREEN} 3) 🧪  Labs / CTF / Vuln Labs${NC}"
    echo
    echo -e "${YELLOW}--- Offensive Security ---${NC}"
    echo -e "${CYAN} 4) 💣  Pentest${NC}"
    echo -e "${CYAN} 5) 🕵️  Red Team${NC}"
    echo -e "${CYAN} 6) 📡  Wireless / Mobile / IoT${NC}"
    echo -e "${CYAN} 7) 🧨  Exploit-Dev / Reverse${NC}"
    echo
    echo -e "${YELLOW}--- Defensive Security ---${NC}"
    echo -e "${CYAN} 8) 🔐  Blue Team${NC}"
    echo -e "${CYAN} 9) 🚨  Incident Response / Threat Hunting${NC}"
    echo -e "${CYAN}10) 🧬  Forensics / Malware Analysis${NC}"
    echo -e "${CYAN}11) 📊  SIEM / Monitoring${NC}"
    echo
    echo -e "${YELLOW}--- Cross-Domain & Emerging ---${NC}"
    echo -e "${CYAN}12) 🌐  Web / AppSec${NC}"
    echo -e "${CYAN}13) ☁️  Cloud / Container / DevSecOps${NC}"
    echo -e "${CYAN}14) 🎭  Social Engineering / Awareness${NC}"
    echo -e "${CYAN}15) ⚖️  Legal-Lab (scénarios légaux)${NC}"
    echo -e "${CYAN}16) 🛰️  OSINT / Threat Intel${NC}"
    echo
    echo -e "${YELLOW}--- Governance & Knowledge ---${NC}"
    echo -e "${CYAN}17) 📜  Compliance / Standards (NIST, ISO, NIS2…)${NC}"
    echo -e "${CYAN}18) 🎓  Training & Learn (TryHackMe / HTB / Labs)${NC}"
    echo
    echo -e "${YELLOW}--- System ---${NC}"
    echo -e "${CYAN}19) 🧱  System & Hardening${NC}"
    echo -e "${CYAN}20) 📂  Logs${NC}"
    echo
    echo -e "${RED}0) ❌  Quitter${NC}"
    echo
    read -p "👉 Choisis une option : ${NC}" choice

    case $choice in
        1) bash ~/ghost00ls/modules/ghostgpt.sh ;;
        2) bash ~/ghost00ls/modules/install.sh ;;
        3) bash ~/ghost00ls/modules/labs.sh ;;
        4) bash ~/ghost00ls/modules/offensive/pentest.sh ;;
        5) bash ~/ghost00ls/modules/offensive/redteam.sh ;;
        6) bash ~/ghost00ls/modules/offensive/wireless.sh ;;
        7) bash ~/ghost00ls/modules/offensive/exploitdev.sh ;;
        8) bash ~/ghost00ls/modules/defensive/blueteam.sh ;;
        9) bash ~/ghost00ls/modules/defensive/ir_threat_hunting.sh ;;
        10) bash ~/ghost00ls/modules/defensive/forensics.sh ;;
        11) bash ~/ghost00ls/modules/defensive/siem.sh ;;
        12) bash ~/ghost00ls/modules/cross/webappsec.sh ;;
        13) bash ~/ghost00ls/modules/cross/cloud.sh ;;
        14) bash ~/ghost00ls/modules/cross/socialeng.sh ;;
        15) bash ~/ghost00ls/modules/cross/legallab.sh ;;
        16) bash ~/ghost00ls/modules/cross/osint.sh ;;
        17) bash ~/ghost00ls/modules/governance/compliance.sh ;;
        18) bash ~/ghost00ls/modules/governance/training.sh ;;
        19) bash ~/ghost00ls/modules/system/system_menu.sh ;;
        20) bash ~/ghost00ls/modules/logs.sh ;;
        0) echo -e "${GREEN}Bye 👻 ${NC}"; exit 0 ;;
        *) echo -e "${RED}Option invalide !${NC}"; sleep 1 ;;
    esac
done
