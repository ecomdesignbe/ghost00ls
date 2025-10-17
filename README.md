# 👻 Ghost00ls Framework

**Boîte à outils cybersécurité portable pour Raspberry Pi 5 (ARM64)**

Framework Bash interactif centralisant les principaux outils de pentest, défense, OSINT et forensics, optimisé pour ParrotOS Linux ARM64.

---

## 🎯 Objectifs

- ⚡ **Automatisation** des tâches répétitives (recon, scans, brute force)
- 🔧 **Centralisation** de 100+ outils cybersécurité avec vérification/installation auto
- 🧪 **Labs intégrés** (DVWA, Juice Shop, CTF) pour training
- 🤖 **GhostGPT** : Assistant IA contextuel (powered by Groq)
- 📊 **Gestion logs** unifiée et génération de rapports

---

## 📋 Prérequis

### Matériel
- **Raspberry Pi 5** (16 Go RAM recommandé)
- **NVMe 1 To** (pour logs et datasets)
- Architecture **ARM64** obligatoire

### Système
- **ParrotOS Linux ARM64** (ou Kali ARM64)
- **Git**, **Bash 4+**, **curl**, **jq**
- **Docker** (optionnel pour labs)

---

## 🚀 Installation

```bash
# Clone le repo
git clone https://github.com/ecomdesignbe/ghost00ls.git
cd ghost00ls

# Rendre le script principal exécutable
chmod +x ghost-menu.sh

# Lancer Ghost00ls
./ghost-menu.sh
```

### Installation automatique des outils

Au premier lancement :
1. Menu `2) Installation des outils`
2. Choisir `8) Install ALL` (ou par catégorie)
3. Les **fallbacks ARM64** se déclenchent automatiquement si un outil manque

---

## 📂 Structure du projet

```
ghost00ls/
├── ghost-menu.sh          # Point d'entrée principal
├── lib/                   # Bibliothèques partagées
│   ├── colors.sh          # Codes couleurs ANSI
│   ├── banner.sh          # Logo ASCII
│   └── config.sh          # Configuration globale
├── modules/               # Modules par domaine
│   ├── offensive/         # Pentest, Red Team, Wireless
│   ├── defensive/         # Blue Team, SIEM, Forensics
│   ├── cross/             # Web, Cloud, OSINT
│   ├── governance/        # Compliance, Training
│   ├── labs/              # DVWA, Juice Shop, CTF
│   ├── ghostgpt/          # Assistant IA
│   └── system/            # Hardening, Config
├── logs/                  # Logs centralisés par module
├── wordlists/             # Wordlists personnalisées
└── tmp/                   # Fichiers temporaires
```

---

## 🔥 Fonctionnalités clés

### 1. **GhostGPT** 🤖
Assistant IA intégré (Groq API) avec modes spécialisés :
- 💬 **General** : Questions cybersec
- 🔍 **Pentest** : Analyse de rapports Nmap/Nikto
- 🛡️ **Blue Team** : Interprétation logs SIEM
- 🧠 **Learning** : Explications pédagogiques

**Configuration** :
```bash
# Ajouter ta clé Groq dans config.sh
echo 'export GROQ_API_KEY="gsk_XXXXX"' >> ~/ghost00ls/lib/config.sh
```

### 2. **Labs vulnérables** 🧪
- **DVWA** : Exploitation web classique (SQLi, XSS, CSRF...)
- **Juice Shop** : OWASP Top 10 moderne
- **CTF tools** : Scripts custom pour challenges

### 3. **Modules Offensive** 💣
- **Pentest** : Nmap, Nikto, SQLmap, Metasploit
- **Red Team** : Responder, CrackMapExec, BloodHound
- **Wireless** : Aircrack-ng, Kismet, Bettercap
- **Exploit Dev** : GDB, Ghidra, Radare2

### 4. **Modules Defensive** 🛡️
- **Blue Team** : Suricata, Zeek, YARA
- **Forensics** : Volatility, Autopsy, Bulk Extractor
- **SIEM** : ELK Stack, Splunk (config only)
- **Threat Hunting** : MITRE ATT&CK mapping

### 5. **Gestion logs** 📊
- Logs centralisés par module dans `~/ghost00ls/logs/`
- Export CSV/JSON/HTML selon les besoins
- Nettoyage sélectif ou global

---

## 🎮 Usage rapide

### Lancer un scan Nmap complet
```bash
./ghost-menu.sh
# → 4) Pentest → 1) Nmap Scan → Scan complet
```

### Exploiter DVWA (SQLi)
```bash
./ghost-menu.sh
# → 3) Labs → 1) DVWA → 4) Exploits → 2) SQL Injection
```

### Demander à GhostGPT d'analyser un rapport
```bash
./ghost-menu.sh
# → 1) GhostGPT → 2) Pentest Assistant
# Upload ton fichier Nmap XML
```

---

## 🔧 Configuration avancée

### Clé API Groq (GhostGPT)
1. Créer un compte sur [Groq Cloud](https://console.groq.com)
2. Générer une clé API
3. Modifier `~/ghost00ls/lib/config.sh` :
```bash
export GROQ_API_KEY="gsk_VOTRE_CLE"
```

### Ajout d'outils personnalisés
```bash
# Éditer modules/install.sh
install_tools "custom" <nom_outil1> <nom_outil2>
```

### Hardening du Raspberry Pi
```bash
./ghost-menu.sh
# → 19) System & Hardening
# Active UFW, fail2ban, désactive services inutiles
```

---

## 🛡️ Sécurité & Avertissements

⚠️ **Ce framework contient des outils offensifs puissants.**

- ✅ Usage **strictement légal** : pentest autorisé uniquement
- ✅ Environnement **isolé recommandé** (VM, lab network)
- ✅ Ne **jamais** pointer vers des cibles en production sans autorisation
- ✅ Logs sensibles → chiffrement/suppression après usage

**Ghost00ls est conçu pour :**
- Formation en cybersécurité
- Labs personnels
- Pentest avec contrat signé
- Recherche académique

---

## 🤝 Contribution

Pull requests bienvenues ! 🎉

### Améliorations prioritaires
- [ ] Module **Threat Intelligence** (MISP, OpenCTI)
- [ ] Support **containers** (Podman rootless)
- [ ] **Reporting automatique** Markdown/PDF
- [ ] Intégration **CI/CD** (GitLab CI, GitHub Actions)
- [ ] Mode **headless** (API REST)

---

## 📜 License

**MIT License** - Usage libre, pas de garantie

---

## 📧 Contact

**Auteur** : Steve Vandenbossche  
**GitHub** : [@ecomdesignbe](https://github.com/ecomdesignbe)  
**Site** : [ecomdesign.be](https://ecomdesign.be)

---

## 🙏 Remerciements

- Communauté **Parrot Security**
- **OWASP** pour DVWA/Juice Shop
- **Groq** pour l'API LLM rapide
- Mainteneurs des outils open-source intégrés

---

**Hack responsibly, learn continuously, secure relentlessly.** 👻🔐
