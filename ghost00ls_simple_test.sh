#!/bin/bash
# ghost00ls_simple_test.sh - Version simplifiée sans erreurs
# Usage: bash ghost00ls_simple_test.sh

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'

GHOST_ROOT="${HOME}/ghost00ls"
PASSED=0
FAILED=0
SKIPPED=0

echo -e "${CYAN}=================================================${NC}"
echo -e "${YELLOW}🧪 Ghost00ls - Tests Rapides${NC}"
echo -e "${CYAN}=================================================${NC}"
echo

# Test 1: Structure de base
echo -e "${YELLOW}[1/5] Structure de base${NC}"
for file in ghost-menu.sh lib/colors.sh lib/config.sh; do
    if [[ -f "$GHOST_ROOT/$file" ]]; then
        echo -e "${GREEN}✅${NC} $file"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC} $file manquant"
        ((FAILED++))
    fi
done

# Test 2: Permissions config.sh
echo
echo -e "${YELLOW}[2/5] Sécurité${NC}"
PERMS=$(stat -c %a "$GHOST_ROOT/lib/config.sh" 2>/dev/null)
if [[ "$PERMS" == "600" ]] || [[ "$PERMS" == "400" ]]; then
    echo -e "${GREEN}✅${NC} config.sh permissions: $PERMS"
    ((PASSED++))
else
    echo -e "${RED}❌${NC} config.sh permissions dangereuses: $PERMS"
    ((FAILED++))
fi

# Test 3: Modules essentiels
echo
echo -e "${YELLOW}[3/5] Modules essentiels${NC}"
for module in modules/install.sh modules/ghostgpt.sh modules/reporting.sh; do
    if [[ -f "$GHOST_ROOT/$module" ]]; then
        echo -e "${GREEN}✅${NC} $module"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC} $module manquant"
        ((FAILED++))
    fi
done

# Test 4: Dossiers logs
echo
echo -e "${YELLOW}[4/5] Dossiers${NC}"
for dir in logs reports tmp cron; do
    if [[ -d "$GHOST_ROOT/$dir" ]]; then
        echo -e "${GREEN}✅${NC} $dir/"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️${NC} $dir/ manquant (sera créé)"
        mkdir -p "$GHOST_ROOT/$dir" 2>/dev/null && ((PASSED++)) || ((FAILED++))
    fi
done

# Test 5: Fixes critiques
echo
echo -e "${YELLOW}[5/5] Fixes critiques${NC}"

# Check install.sh protégé
if grep -q "if (( total > 0 ))" "$GHOST_ROOT/modules/install.sh" 2>/dev/null; then
    echo -e "${GREEN}✅${NC} install.sh: division par zéro protégée"
    ((PASSED++))
else
    echo -e "${RED}❌${NC} install.sh: protection division/0 manquante"
    ((FAILED++))
fi

# Check sanitize.sh existe
if [[ -f "$GHOST_ROOT/lib/sanitize.sh" ]]; then
    echo -e "${GREEN}✅${NC} sanitize.sh créé"
    ((PASSED++))
else
    echo -e "${YELLOW}⏭️${NC} sanitize.sh manquant (optionnel)"
    ((SKIPPED++))
fi

# Résumé
echo
echo -e "${CYAN}=================================================${NC}"
echo -e "${YELLOW}📊 Résultats${NC}"
echo -e "${CYAN}=================================================${NC}"
echo -e "   ${GREEN}✅ PASS  : $PASSED${NC}"
echo -e "   ${RED}❌ FAIL  : $FAILED${NC}"
echo -e "   ${YELLOW}⏭️ SKIP  : $SKIPPED${NC}"

TOTAL=$((PASSED + FAILED))
if (( TOTAL > 0 )); then
    SCORE=$((PASSED * 100 / TOTAL))
else
    SCORE=0
fi

echo
echo -e "${CYAN}Score : ${SCORE}%${NC}"

if (( FAILED == 0 )); then
    echo -e "${GREEN}🎉 Tous les tests critiques passent !${NC}"
    exit 0
else
    echo -e "${RED}⚠️ ${FAILED} échec(s) détecté(s)${NC}"
    exit 1
fi
