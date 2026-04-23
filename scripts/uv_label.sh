#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------
# File: uv_label.sh
# Type: Bash Shell Script
# By Julio Alberto Lascano http://drcalambre.blogspot.com/
#________          _________        .__                ___.                  
#\______ \_______  \_   ___ \_____  |  | _____    _____\_ |_________   ____  
# |    |  \_  __ \ /    \  \/\__  \ |  | \__  \  /     \| __ \_  __ \_/ __ \ 
# |    `   \  | \/ \     \____/ __ \|  |__/ __ \|  Y Y  \ \_\ \  | \/\  ___/ 
#/_______  /__|     \______  (____  /____(____  /__|_|  /___  /__|    \___  >
#        \/                \/     \/          \/      \/    \/            \/ 
#
# Last modified:2026-01-08
# ----------------------------------------------------------------------------------------------------------------------------
# This script reads uv.json and returns short text, ready to display.
# ----------------------------------------------------------------------------------------------------------------------------

CACHE="$HOME/.cache/uv.json"

[ ! -f "$CACHE" ] && exit 0

uv=$(jq -r '.current.uv_index' "$CACHE")

# In case null comes
[ "$uv" = "null" ] && echo "UV sin datos" && exit 0

# Simple rounding for classification - locale vs formato decimal
uv_clean=$(echo "$uv" | tr ',' '.')
uv_int=$(LC_NUMERIC=C printf "%.0f" "$uv_clean" 2>/dev/null)

# fallback por si algo falla
[ -z "$uv_int" ] && uv_int=0

if   [ "$uv_int" -le 2 ]; then
    echo "bajo · protección mínima"
elif [ "$uv_int" -le 5 ]; then
    echo "moderado · requiere protección"
elif [ "$uv_int" -le 7 ]; then
    echo "alto · requiere protección"
elif [ "$uv_int" -le 10 ]; then
    echo "muy alto · protección especial"
else
    echo "extremo · protección especial"
fi
