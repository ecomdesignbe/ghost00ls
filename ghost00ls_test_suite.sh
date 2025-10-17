#!/bin/bash
# ghost00ls_test_suite.sh
# Suite de tests complète pour Ghost00ls Framework
# Usage: bash ghost00ls_test_suite.sh [--module MODULE_NAME]

set -e

# Couleurs
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'

GHOST_ROOT="${HOME}/ghost00ls"
TEST_LOG="${GHOST_ROOT}/logs/system/test_results_$(date +%F_%H-%M-%S).log"
PASSED=0
FAILED=0
SKIPPED=0

# === Fonctions utilitaires ===
test_start() {
    echo -e "\n${CYAN}▶ Test: $1${NC}"
    echo "[$1]" >> "$TEST_LOG"
}

test_pass() {
    echo -e "${GREEN}  ✅ PASS${NC}"
    echo "  PASS" >> "$TEST_LOG"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}  ❌ FAIL: $1${NC}"
    echo "  FAIL: $1" >> "$TEST_LOG"
    ((FAILED++))
}

test_skip() {
    echo -e "${YELLOW}  ⏭️ SKIP: $1${NC}"
    echo "  SKIP: $1" >> "$TEST_LOG"
    ((SKIPPED++))
}

# Banner
clear
cat << "EOF"
   _____ _               _   ___   ___  _     
  / ____| |             | | / _ \ / _ \| |    
 | |  __| |__   ___  ___| || | | | | | | |___ 
 | | |_ | '_ \ / _ \/ __| || | | | | | | / __|
 | |__| | | | | (_) \__ \ || |_| | |_| | \__ \
  \_____|_| |_|\___/|___| | \___/ \___/|_|___/
                        |_|                    
              TEST SUITE v1.0
EOF

echo -e "${CYAN}=================================================${NC}"
echo -e "${YELLOW}🧪 Ghost00ls - Tests Automatisés${NC}"
echo -e "${CYAN}=================================================${NC}"
echo

mkdir -p "$(dirname "$TEST_LOG")"
echo "Test Suite lancée le $(date)" > "$TEST_LOG"

# === 1. Tests Structure Projet ===
echo -e "${YELLOW}[1/10] Tests Structure Projet${NC}"

test_start "Vérifier présence ghost-menu.sh"
if [[ -f "$GHOST_ROOT/ghost-menu.sh" ]]; then
    test_pass
else
    test_fail "ghost-menu.sh introuvable"
fi

test_start "Vérifier présence lib/colors.sh"
if [[ -f "$GHOST_ROOT/lib/colors.sh" ]]; then
    test_pass
else
    test_fail "lib/colors.sh introuvable"
fi

test_start "Vérifier présence lib/config.sh"
if [[ -f "$GHOST_ROOT/lib/config.sh" ]]; then
    test_pass
else
    test_fail "lib/config.sh introuvable"
fi

test_start "Vérifier dossier modules/offensive"
if [[ -d "$GHOST_ROOT/modules/offensive" ]]; then
    test_pass
else
    test_fail "modules/offensive introuvable"
fi

test_start "Vérifier dossier logs/"
if [[ -d "$GHOST_ROOT/logs" ]]; then
    test_pass
else
    test_fail "logs/ introuvable"
fi

# === 2. Tests Permissions Sécurité ===
echo
echo -e "${YELLOW}[2/10] Tests Permissions Sécurité${NC}"

test_start "Vérifier permissions config.sh (doit être 600 ou 400)"
CONFIG_PERMS=$(stat -c %a "$GHOST_ROOT/lib/config.sh" 2>/dev/null)
if [[ "$CONFIG_PERMS" == "600" || "$CONFIG_PERMS" == "400" ]]; then
    test_pass
else
    test_fail "Permissions dangereuses: $CONFIG_PERMS (attendu 600)"
fi

test_start "Vérifier propriétaire config.sh"
CONFIG_OWNER=$(stat -c %U "$GHOST_ROOT/lib/config.sh" 2>/dev/null)
if [[ "$CONFIG_OWNER" == "$(whoami)" ]]; then
    test_pass
else
    test_fail "Propriétaire inattendu: $CONFIG_OWNER"
fi

test_start "Vérifier scripts exécutables"
if [[ -x "$GHOST_ROOT/ghost-menu.sh" ]]; then
    test_pass
else
    test_fail "ghost-menu.sh non exécutable"
fi

# === 3. Tests Syntaxe Bash ===
echo
echo -e "${YELLOW}[3/10] Tests Syntaxe Bash${NC}"

test_start "Vérifier syntaxe ghost-menu.sh"
if bash -n "$GHOST_ROOT/ghost-menu.sh" 2>/dev/null; then
    test_pass
else
    test_fail "Erreurs syntaxe détectées"
fi

test_start "Vérifier syntaxe modules/install.sh"
if bash -n "$GHOST_ROOT/modules/install.sh" 2>/dev/null; then
    test_pass
else
    test_fail "Erreurs syntaxe détectées"
fi

test_start "Vérifier syntaxe lib/colors.sh"
if bash -n "$GHOST_ROOT/lib/colors.sh" 2>/dev/null; then
    test_pass
else
    test_fail "Erreurs syntaxe détectées"
fi

# === 4. Tests Configuration ===
echo
echo -e "${YELLOW}[4/10] Tests Configuration${NC}"

test_start "Vérifier GROQ_API_KEY défini"
source "$GHOST_ROOT/lib/config.sh" 2>/dev/null
if [[ -n "$GROQ_API_KEY" ]]; then
    test_pass
else
    test_skip "GROQ_API_KEY non configuré (optionnel)"
fi

test_start "Vérifier GHOST_ROOT défini"
if [[ -n "$GHOST_ROOT" ]]; then
    test_pass
else
    test_fail "GHOST_ROOT non défini"
fi

test_start "Vérifier chemins par défaut"
if [[ -d "$GHOST_LOGS" ]]; then
    test_pass
else
    test_fail "GHOST_LOGS ($GHOST_LOGS) introuvable"
fi

# === 5. Tests Dépendances Système ===
echo
echo -e "${YELLOW}[5/10] Tests Dépendances Système${NC}"

DEPS_CRITICAL=(bash curl jq git)
for dep in "${DEPS_CRITICAL[@]}"; do
    test_start "Vérifier présence $dep"
    if command -v "$dep" &>/dev/null; then
        test_pass
    else
        test_fail "$dep non installé (CRITIQUE)"
    fi
done

# === 6. Tests Modules Core ===
echo
echo -e "${YELLOW}[6/10] Tests Modules Core${NC}"

MODULES=(
    "modules/install.sh"
    "modules/ghostgpt.sh"
    "modules/reporting.sh"
    "modules/automation.sh"
    "modules/logs.sh"
)

for module in "${MODULES[@]}"; do
    test_start "Vérifier existence $module"
    if [[ -f "$GHOST_ROOT/$module" ]]; then
        test_pass
    else
        test_fail "$module introuvable"
    fi
done

# === 7. Tests GhostGPT ===
echo
echo -e "${YELLOW}[7/10] Tests GhostGPT${NC}"

test_start "Vérifier modules/ghostgpt/functions.sh"
if [[ -f "$GHOST_ROOT/modules/ghostgpt/functions.sh" ]]; then
    test_pass
else
    test_fail "functions.sh introuvable"
fi

test_start "Vérifier fonction ask_groq existe"
if grep -q "ask_groq()" "$GHOST_ROOT/modules/ghostgpt/functions.sh" 2>/dev/null; then
    test_pass
else
    test_fail "Fonction ask_groq() introuvable"
fi

test_start "Vérifier logs GhostGPT accessibles"
if [[ -d "$GHOST_ROOT/logs/ghostgpt" ]] || mkdir -p "$GHOST_ROOT/logs/ghostgpt" 2>/dev/null; then
    test_pass
else
    test_fail "Impossible créer logs/ghostgpt"
fi

# === 8. Tests Labs DVWA ===
echo
echo -e "${YELLOW}[8/10] Tests Labs DVWA${NC}"

test_start "Vérifier modules/labs/dvwa/exploits.sh"
if [[ -f "$GHOST_ROOT/modules/labs/dvwa/exploits.sh" ]]; then
    test_pass
else
    test_skip "DVWA exploits non installé"
fi

test_start "Vérifier HTML exploits non tronqué"
if grep -q 'background:#111;color:#eee;padding:12px}table' "$GHOST_ROOT/modules/labs/dvwa/exploits.sh" 2>/dev/null; then
    test_pass
else
    test_fail "HTML tronqué détecté (exécuter ghost00ls_critical_fixes.sh)"
fi

# === 9. Tests Sécurité Code ===
echo
echo -e "${YELLOW}[9/10] Tests Sécurité Code${NC}"

test_start "Vérifier absence hardcoded passwords"
if ! grep -r "password=" "$GHOST_ROOT/modules" 2>/dev/null | grep -v "read -p"; then
    test_pass
else
    test_fail "Passwords hardcodés détectés"
fi

test_start "Vérifier absence API keys hardcodées"
if ! grep -rE 'gsk_[a-zA-Z0-9]{40}' "$GHOST_ROOT/modules" 2>/dev/null; then
    test_pass
else
    test_fail "API keys hardcodées détectées"
fi

test_start "Vérifier sanitize.sh existe"
if [[ -f "$GHOST_ROOT/lib/sanitize.sh" ]]; then
    test_pass
else
    test_skip "sanitize.sh non installé (exécuter fixes)"
fi

# === 10. Tests Automation ===
echo
echo -e "${YELLOW}[10/10] Tests Automation${NC}"

test_start "Vérifier automation.sh syntaxe"
if bash -n "$GHOST_ROOT/modules/automation.sh" 2>/dev/null; then
    test_pass
else
    test_fail "Erreurs syntaxe automation.sh"
fi

test_start "Vérifier absence typo path"
if ! grep -q "~/ghostmodules/automation.sh" "$GHOST_ROOT/modules/automation.sh" 2>/dev/null; then
    test_pass
else
    test_fail "Typo path détecté (exécuter fixes)"
fi

test_start "Vérifier dossier cron/"
if [[ -d "$GHOST_ROOT/cron" ]]; then
    test_pass
else
    test_fail "Dossier cron/ introuvable"
fi

# === Résumé Final ===
echo
echo -e "${CYAN}=================================================${NC}"
echo -e "${YELLOW}📊 Résultats Tests${NC}"
echo -e "${CYAN}=================================================${NC}"
echo
echo -e "   ${GREEN}✅ PASS  : $PASSED${NC}"
echo -e "   ${RED}❌ FAIL  : $FAILED${NC}"
echo -e "   ${YELLOW}⏭️ SKIP  : $SKIPPED${NC}"
echo
echo -e "   ${CYAN}📝 Log complet : $TEST_LOG${NC}"
echo

TOTAL=$((PASSED + FAILED + SKIPPED))
SCORE=0
if (( TOTAL > 0 )); then
    SCORE=$(( PASSED * 100 / (PASSED + FAILED) ))
fi

echo -e "${CYAN}=================================================${NC}"
if (( FAILED == 0 )); then
    echo -e "${GREEN}🎉 TOUS LES TESTS PASSÉS ! Score: 100%${NC}"
elif (( SCORE >= 80 )); then
    echo -e "${GREEN}✅ Tests OK ! Score: ${SCORE}%${NC}"
elif (( SCORE >= 60 )); then
    echo -e "${YELLOW}⚠️ Tests partiels. Score: ${SCORE}%${NC}"
else
    echo -e "${RED}❌ Échecs critiques ! Score: ${SCORE}%${NC}"
fi
echo -e "${CYAN}=================================================${NC}"
echo

# Actions recommandées
if (( FAILED > 0 )); then
    echo -e "${YELLOW}🔧 Actions recommandées :${NC}"
    echo -e "   1. Exécuter les correctifs :"
    echo -e "      ${GREEN}bash ~/ghost00ls/ghost00ls_critical_fixes.sh${NC}"
    echo -e "   2. Réexécuter les tests :"
    echo -e "      ${GREEN}bash ~/ghost00ls/ghost00ls_test_suite.sh${NC}"
    echo -e "   3. Consulter le log :"
    echo -e "      ${GREEN}cat $TEST_LOG${NC}"
    echo
fi

exit $FAILED