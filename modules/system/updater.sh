#!/bin/bash
source ~/ghost00ls/lib/colors.sh

echo -e "${CYAN}=== 🔄 Mise à jour Ghost-Framework ===${NC}"

cd ~/ghost00ls || exit
if [ -d .git ]; then
    git pull
    echo -e "${GREEN}✅ Framework mis à jour depuis Git${NC}"
else
    echo -e "${RED}❌ Pas de repo Git détecté. Mets-le sur GitHub pour utiliser updater.sh${NC}"
fi
