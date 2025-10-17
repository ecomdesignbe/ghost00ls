# 📘 Ghost00ls - Documentation Technique

## 🏗️ Architecture

### Structure des fichiers

```
ghost00ls/
├── ghost-menu.sh              # Point d'entrée (menu principal)
├── setup.sh                   # Script d'installation initiale
│
├── lib/                       # Bibliothèques partagées
│   ├── colors.sh              # Constantes couleurs ANSI
│   ├── banner.sh              # Logo ASCII
│   └── config.sh              # Configuration globale (API keys)
│
├── modules/                   # Modules fonctionnels
│   ├── ghostgpt.sh            # Assistant IA (Groq)
│   ├── install.sh             # Gestionnaire d'outils
│   ├── labs.sh                # Labs vulnérables (DVWA, Juice Shop)
│   ├── logs.sh                # Visualisation logs
│   ├── reporting.sh           # Génération rapports
│   ├── automation.sh          # Tâches planifiées (cron)
│   │
│   ├── offensive/             # Modules offensifs
│   │   ├── pentest.sh
│   │   ├── redteam.sh
│   │   ├── wireless.sh
│   │   └── exploitdev.sh
│   │
│   ├── defensive/             # Modules défensifs
│   │   ├── blueteam.sh
│   │   ├── ir_threat_hunting.sh
│   │   ├── forensics.sh
│   │   └── siem.sh
│   │
│   ├── cross/                 # Domaines transverses
│   │   ├── webappsec.sh
│   │   ├── cloud.sh
│   │   ├── socialeng.sh
│   │   ├── osint.sh
│   │   └── threat_intel.sh    # NEW: Threat Intelligence
│   │
│   ├── governance/
│   │   ├── compliance.sh
│   │   └── training.sh
│   │
│   ├── labs/                  # Labs intégrés
│   │   ├── dvwa/
│   │   │   ├── dvwa.sh
│   │   │   ├── config/
│   │   │   └── exploits.sh
│   │   └── juiceshop/
│   │       ├── juiceshop.sh
│   │       └── exploits.sh
│   │
│   └── system/                # Config système
│       ├── system_menu.sh
│       ├── hardening.sh
│       ├── config.sh
│       └── updater.sh
│
├── logs/                      # Logs centralisés
│   ├── system/
│   ├── automated_scans/
│   ├── monitoring/
│   ├── threat_intel/
│   └── [module_name]/
│
├── reports/                   # Rapports générés
│   ├── *.md
│   ├── *.html
│   └── *.csv
│
├── wordlists/                 # Wordlists personnalisées
│   └── xss_payloads.txt
│
├── cron/                      # Scripts cron
│   ├── daily_scan_*.sh
│   ├── auto_backup.sh
│   └── continuous_monitor.sh
│
└── tmp/                       # Fichiers temporaires
```

---

## 🔧 Conventions de développement

### Naming conventions

- **Modules** : `snake_case.sh` (ex: `threat_intel.sh`)
- **Fonctions** : `snake_case()` (ex: `check_virustotal()`)
- **Variables globales** : `SCREAMING_SNAKE_CASE` (ex: `LOG_DIR`)
- **Variables locales** : `snake_case` (ex: `report_file`)

### Structure d'un module

```bash
#!/bin/bash
# module_name.sh - Description courte
# Place in: ~/ghost00ls/modules/category/module_name.sh

source ~/ghost00ls/lib/colors.sh
source ~/ghost00ls/lib/banner.sh
source ~/ghost00ls/lib/config.sh

# Variables locales
MODULE_LOG=~/ghost00ls/logs/module_name
mkdir -p "$MODULE_LOG"

# === Fonctions ===
function_one() {
    clear
    banner
    echo -e "${CYAN}=== Titre Fonction ===${NC}"
    
    # Logique...
    
    read -p "👉 Entrée pour revenir..."
}

function_two() {
    # ...
}

# === Menu principal ===
menu_module() {
    clear
    banner
    echo -e "${CYAN}=== 📋 Module Name ===${NC}"
    echo
    echo -e "${GREEN}1) Option 1${NC}"
    echo -e "${GREEN}2) Option 2${NC}"
    echo -e "${RED}0) Retour${NC}"
    echo
    read -p "👉 Choix : " choice

    case $choice in
        1) function_one ;;
        2) function_two ;;
        0) return ;;
        *) echo -e "${RED}Option invalide${NC}"; sleep 1 ;;
    esac
    menu_module
}

menu_module
```

### Gestion des logs

**Toujours logger dans le bon répertoire :**

```bash
LOG_DIR=~/ghost00ls/logs/module_name
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%F_%H-%M-%S)
LOG_FILE="$LOG_DIR/action_${TIMESTAMP}.log"

# Exemple de log
echo "[$(date)] Action effectuée" | tee -a "$LOG_FILE"
```

### Gestion des erreurs

```bash
# Vérifier commande disponible
if ! command -v tool &>/dev/null; then
    echo -e "${RED}❌ 'tool' non installé${NC}"
    echo -e "${YELLOW}Installe-le via : sudo apt install tool${NC}"
    return 1
fi

# Vérifier fichier existe
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}❌ Fichier introuvable : $CONFIG_FILE${NC}"
    return 1
fi
```

---

## 🎨 Style Guide

### Couleurs (via lib/colors.sh)

```bash
RED='\e[31m'      # Erreurs, warnings critiques
GREEN='\e[32m'    # Succès, confirmations
YELLOW='\e[33m'   # Avertissements
CYAN='\e[36m'     # Titres, informations
MAGENTA='\e[35m'  # Highlights spéciaux
NC='\e[0m'        # Reset
```

### Emojis standardisés

```bash
🔴 Critique / Erreur
🟠 Warning / Attention
🟢 Succès / OK
🔵 Info
⏳ En cours...
✅ Terminé avec succès
❌ Échec
🎯 Cible / Target
🔑 API Key / Credentials
📊 Stats / Résultats
📂 Fichiers / Dossiers
🚀 Lancement / Action
🛡️ Sécurité
💣 Offensif
🔍 Recherche / OSINT
```

### Messages utilisateur

**DO:**
```bash
echo -e "${GREEN}✅ Installation terminée${NC}"
echo -e "${YELLOW}⚠️ Attention : Cette action est irréversible${NC}"
read -p "🎯 Cible IP : " TARGET_IP
```

**DON'T:**
```bash
echo "Installation OK"  # Pas de couleur
echo "WARNING"          # Pas d'emoji/contexte
read -p "IP: " ip       # Pas clair
```

---

## 🔌 API Intégrations

### Groq (GhostGPT)

**Endpoint** : `https://api.groq.com/openai/v1/chat/completions`

**Modèles disponibles :**
- `llama-3.1-70b-versatile` (recommandé)
- `llama-3.1-8b-instant` (rapide)
- `mixtral-8x7b-32768` (long contexte)

**Exemple de requête :**
```bash
curl -s -X POST "$GROQ_URL" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$GROQ_MODEL\",
    \"messages\": [{\"role\":\"user\",\"content\":\"$PROMPT\"}],
    \"temperature\": 0.7,
    \"max_tokens\": 1024
  }" | jq -r '.choices[0].message.content'
```

### VirusTotal

**Endpoint** : `https://www.virustotal.com/api/v3/`

**Rate limits (free tier)** : 4 req/min, 500 req/day

**Exemple :**
```bash
curl -s --request GET \
  --url "https://www.virustotal.com/api/v3/ip-addresses/$IP" \
  --header "x-apikey: $VIRUSTOTAL_API_KEY" \
  | jq '.data.attributes.last_analysis_stats'
```

### Shodan

**Endpoint** : `https://api.shodan.io/`

**Exemple :**
```bash
curl -s "https://api.shodan.io/shodan/host/$IP?key=$SHODAN_API_KEY" \
  | jq '.ports'
```

---

## 🧪 Tests

### Tester un module

```bash
# Lancer directement le module
bash ~/ghost00ls/modules/category/module.sh

# Vérifier les logs
tail -f ~/ghost00ls/logs/module_name/*.log

# Checker les erreurs
bash -x ~/ghost00ls/modules/module.sh  # Mode debug
```

### Checklist avant commit

- [ ] Le module source bien `lib/colors.sh`, `banner.sh`, `config.sh`
- [ ] Les logs sont écrits dans `~/ghost00ls/logs/module_name/`
- [ ] Les variables sensibles utilisent `$HOME` pas `/home/user`
- [ ] Les chemins absolus utilisent `~/ghost00ls/` ou `$GHOST_ROOT`
- [ ] Gestion d'erreur pour commandes manquantes
- [ ] Option "Retour" (0) dans tous les menus
- [ ] Permissions 755 sur les .sh, 600 sur config.sh

---

## 🚀 Performance

### Optimisations ARM64

```bash
# Préférer des outils natifs ARM
crackmapexec → netexec (Python, plus rapide sur ARM)
masscan → nmap (mieux supporté)

# Limiter threads sur Raspberry Pi
nmap -T3 (pas -T4/-T5)
hydra -t 8 (pas -t 64)
```

### Gestion mémoire

```bash
# Nettoyer tmp régulièrement
rm -rf ~/ghost00ls/tmp/* 2>/dev/null

# Compresser vieux logs
find ~/ghost00ls/logs -name "*.log" -mtime +30 -exec gzip {} \;
```

---

## 🔐 Sécurité

### Stockage credentials

**JAMAIS** en dur dans les scripts :
```bash
# ❌ BAD
API_KEY="gsk_abc123..."

# ✅ GOOD
API_KEY="${GROQ_API_KEY:-}"
if [[ -z "$API_KEY" ]]; then
    echo "Configure GROQ_API_KEY dans lib/config.sh"
    exit 1
fi
```

### Permissions fichiers

```bash
chmod 600 ~/ghost00ls/lib/config.sh      # Config avec secrets
chmod 700 ~/ghost00ls/logs               # Logs sensibles
chmod 755 ~/ghost00ls/modules/*.sh       # Scripts exécutables
```

### Sanitization inputs

```bash
# Valider IP
if [[ ! "$IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "IP invalide"
    return 1
fi

# Échapper caractères dangereux
SAFE_INPUT=$(echo "$USER_INPUT" | sed 's/[^a-zA-Z0-9._-]//g')
```

---

## 📦 Ajout de nouveaux modules

### 1. Créer le fichier

```bash
touch ~/ghost00ls/modules/category/new_module.sh
chmod +x ~/ghost00ls/modules/category/new_module.sh
```

### 2. Utiliser le template (voir ci-dessus)

### 3. Ajouter au menu principal

Éditer `ghost-menu.sh` :
```bash
case $choice in
    ...
    23) bash ~/ghost00ls/modules/category/new_module.sh ;;
    ...
esac
```

### 4. Tester

```bash
bash ~/ghost00ls/modules/category/new_module.sh
```

### 5. Commit

```bash
git add modules/category/new_module.sh
git commit -m "feat: add new_module for X functionality"
git push origin main
```

---

## 🐛 Debugging

### Mode verbose

```bash
bash -x ~/ghost00ls/ghost-menu.sh  # Trace toutes les commandes
```

### Logs système

```bash
tail -f ~/ghost00ls/logs/automation.log
journalctl -u ghost00ls -f  # Si systemd service
```

### Variables d'environnement

```bash
env | grep GHOST  # Vérifier variables Ghost00ls
env | grep API    # Vérifier API keys
```

---

## 🤝 Contribution

1. Fork le repo
2. Crée une branche : `git checkout -b feature/ma-feature`
3. Code en respectant les conventions ci-dessus
4. Commit : `git commit -m "feat: description"`
5. Push : `git push origin feature/ma-feature`
6. Crée une Pull Request sur GitHub

---

**Maintenu par** : Steve Vandenbossche (ecomdesign.be)  
**License** : MIT
