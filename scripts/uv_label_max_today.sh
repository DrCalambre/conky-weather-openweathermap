#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------
# File: uv_label_max_today.sh
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
# -------------------------------------------------------------------
# Shows today's maximum UV index and time (model-based)
# -------------------------------------------------------------------

CACHE="$HOME/.cache/uv_hourly.json"
[ ! -f "$CACHE" ] && exit 0

today=$(date +%F)

jq -r '
.hourly.time as $t |
.hourly.uv_index as $u |
range(0; $u|length) |
select($t[.] | startswith("'"$today"'")) |
"\($t[.]) \($u[.])"
' "$CACHE" |
awk '
BEGIN { max=-1 }
{
  if ($2 > max) {
    max=$2
    hora=$1
  }
}
END {
  if (max >= 0)
    printf "máx hoy %.1f · %s\n", max, substr(hora,12,5)
}'
