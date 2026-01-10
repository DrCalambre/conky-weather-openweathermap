#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------
# File: openMeteo-uv.sh
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
# RGL : Rio Gallegos city, Argentina lat= -51.6226&lon=-69.2181
# ----------------------------------------------------------------------------------------------------------------------------
# API call
# https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=uv_index
# ----------------------------------------------------------------------------------------------------------------------------
# get the {lat}{lon} coordinates from https://open-meteo.com/en/docs corresponding to your location and replace as appropriate
# ----------------------------------------------------------------------------------------------------------------------------
# Clear conceptual separation
# dedicated cache ~/.cache/uv.json
# Explicit dependency of OWM for sun window only

CACHE="$HOME/.cache/uv.json"
OWM="$HOME/.cache/openweathermap.json"

# Security: If there's no database, we exit
[ ! -f "$OWM" ] && exit 0

now=$(date +%s)
sunrise=$(jq -r '.sys.sunrise' "$OWM")
sunset=$(jq -r '.sys.sunset' "$OWM")

# Security: In case OWM ever returns null:
[ "$sunrise" = "null" ] || [ "$sunset" = "null" ] && exit 0

# Explicit nighttime policy: Only consult UV between dawn and dusk
if [ "$now" -ge "$sunrise" ] && [ "$now" -le "$sunset" ]; then
    curl -s "https://api.open-meteo.com/v1/forecast?latitude=-51.6226&longitude=-69.2181&current=uv_index" \
    -o "$CACHE"
else
    # Night → UV = 0 (coherent cache)
    echo '{"current":{"uv_index":0}}' > "$CACHE"
fi
