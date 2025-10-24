#!/bin/bash
# diagnose_juice_v19.sh - Diagnostic Juice Shop v19.0.0
# Identifie les challenge keys réels et leur état

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

IP="${1:-localhost}"
PORT="${2:-3000}"
BASE="http://${IP}:${PORT}"

echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Diagnostic Juice Shop v19.0.0                  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo
echo -e "${YELLOW}Target: $BASE${NC}"
echo

# Test connexion
echo -e "${CYAN}[1/4] Test connexion...${NC}"
if ! curl -s -o /dev/null -w "%{http_code}" "$BASE" | grep -q "200"; then
    echo -e "${RED}❌ Juice Shop non accessible${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Juice Shop accessible${NC}"
echo

# Récupérer tous les challenges
echo -e "${CYAN}[2/4] Récupération des challenges...${NC}"
CHALLENGES=$(curl -s "${BASE}/api/Challenges" 2>/dev/null)

if [ -z "$CHALLENGES" ]; then
    echo -e "${RED}❌ API Challenges non accessible${NC}"
    exit 1
fi

TOTAL=$(echo "$CHALLENGES" | jq '.data | length' 2>/dev/null)
SOLVED=$(echo "$CHALLENGES" | jq '[.data[] | select(.solved==true)] | length' 2>/dev/null)

echo -e "${GREEN}✅ API OK${NC}"
echo -e "${CYAN}   Total: $TOTAL challenges${NC}"
echo -e "${GREEN}   Résolus: $SOLVED challenges${NC}"
echo

# Afficher les challenges résolus
echo -e "${CYAN}[3/4] Challenges résolus:${NC}"
if [ "$SOLVED" -gt 0 ]; then
    echo "$CHALLENGES" | jq -r '.data[] | select(.solved==true) | "  ✅ [\(.difficulty)⭐] \(.name)\n     Key: \(.key)"' 2>/dev/null
else
    echo -e "${YELLOW}  Aucun challenge résolu${NC}"
fi
echo

# Créer fichier de mapping
echo -e "${CYAN}[4/4] Création mapping complet...${NC}"

OUTPUT_FILE="juice_v19_challenges_mapping.json"

echo "$CHALLENGES" | jq '.data | map({
    name: .name,
    key: .key,
    difficulty: .difficulty,
    category: .category,
    solved: .solved,
    description: .description
}) | sort_by(.difficulty)' > "$OUTPUT_FILE"

echo -e "${GREEN}✅ Fichier créé: $OUTPUT_FILE${NC}"
echo

# Afficher les 20 premiers challenges par difficulté
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Top 20 Challenges (par difficulté)             ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo

echo "$CHALLENGES" | jq -r '.data | sort_by(.difficulty) | .[0:20] | .[] | 
    "[\(.difficulty)⭐] \(.name)\n   Key: \(.key)\n   Cat: \(.category)\n   ✓: \(if .solved then "OUI" else "NON" end)\n"' 2>/dev/null

# Statistiques par catégorie
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Statistiques par Catégorie                     ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo

echo "$CHALLENGES" | jq -r '.data | group_by(.category) | .[] | 
    "\(.[]|.category): \(length) challenges (\([.[] | select(.solved==true)] | length) résolus)"' 2>/dev/null

echo
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Diagnostic terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${YELLOW}📄 Fichier de mapping : $OUTPUT_FILE${NC}"
echo -e "${CYAN}💡 Utilise ce fichier pour corriger les challenge keys${NC}"
echo

# Comparer avec nos keys
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Comparaison avec nos Challenge Keys            ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo

# Liste de nos keys
OUR_KEYS=(
    "loginAdminChallenge"
    "domXssChallenge"
    "scoreBoardChallenge"
    "adminSectionChallenge"
    "basketAccessChallenge"
    "passwordStrengthChallenge"
    "persistedXssFeedbackChallenge"
    "noSqlCommandChallenge"
)

echo -e "${YELLOW}Vérification de nos keys dans Juice Shop v19:${NC}"
echo

for key in "${OUR_KEYS[@]}"; do
    if echo "$CHALLENGES" | jq -e ".data[] | select(.key==\"$key\")" >/dev/null 2>&1; then
        local name=$(echo "$CHALLENGES" | jq -r ".data[] | select(.key==\"$key\") | .name" 2>/dev/null)
        echo -e "${GREEN}  ✅ $key${NC} → $name"
    else
        echo -e "${RED}  ❌ $key${NC} → INTROUVABLE dans v19"
    fi
done

echo
echo -e "${CYAN}💡 Cherche les vrais keys dans le fichier JSON généré${NC}"
echo
