#!/bin/bash
set -e
echo "=== DVWA Entrypoint Patch ==="
DVWAPAGE="/var/www/html/dvwa/includes/dvwaPage.inc.php"
if [ -f "$DVWAPAGE" ]; then
    count=$(grep -c "Security Level:" "$DVWAPAGE" 2>/dev/null || echo "0")
    if [ "$count" -gt "1" ]; then
        echo "⚠️  Found $count occurrences - applying patch..."
        cp "$DVWAPAGE" "${DVWAPAGE}.backup"
        awk 'NR==1{print; prev=$0; next} $0!=prev{print; prev=$0}' "$DVWAPAGE" > "${DVWAPAGE}.tmp"
        mv "${DVWAPAGE}.tmp" "$DVWAPAGE"
        new_count=$(grep -c "Security Level:" "$DVWAPAGE" 2>/dev/null || echo "0")
        [ "$new_count" -eq "1" ] && echo "✅ Patch successful: $count → 1" || echo "⚠️  Still $new_count occurrences"
    else
        echo "✅ No duplicate ($count occurrence)"
    fi
fi
echo "=== Starting Apache ==="
exec apache2-foreground
