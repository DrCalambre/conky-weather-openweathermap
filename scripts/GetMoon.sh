#!/bin/bash

# -------------------------------------------------------------------
# File: GetMoon.sh                                       /\
# Type: Bash Shell Script                               /_.\
# By Fernando Gilli fernando<at>wekers(dot)org    _,.-'/ `",\'-.,_
# ------------------------                     -~^    /______\`~~-^~:
# Get Moon data from moongiant.com
# / OS : $Linux, $FreeBSD (X Window)
# ------------------------
# adapted for the current version by: 
#________          _________        .__                ___.                  
#\______ \_______  \_   ___ \_____  |  | _____    _____\_ |_________   ____  
# |    |  \_  __ \ /    \  \/\__  \ |  | \__  \  /     \| __ \_  __ \_/ __ \ 
# |    `   \  | \/ \     \____/ __ \|  |__/ __ \|  Y Y  \ \_\ \  | \/\  ___/ 
#/_______  /__|     \______  (____  /____(____  /__|_|  /___  /__|    \___  >
#        \/                \/     \/          \/      \/    \/            \/ 
# Julio Alberto Lascano http://drcalambre.blogspot.com/
# Last modified:2023-09-21
# -------------------------------------------------------------------

# Working directory
DirShell="$HOME/.cache"
DirScripts="$HOME/.config/conky/scripts"

# ****************************
wget -q -O ${DirShell}/raw "https://www.moongiant.com/phase/today" > /dev/null 2>&1

[ -f ${DirShell}/moon_tmp.jpg ] && rm ${DirShell}/moon_tmp.jpg
[ -f ${DirShell}/moon.jpg ] && rm ${DirShell}/moon.jpg

# Obtener imagen actual desde moongiant (nuevo formato HTML)
img_in=$(grep -oP '(?<=id="todayMoonContainer"><img src=")[^"]+' ${DirShell}/raw)

# Descargar imagen desde moongiant solo si se encontró ruta
if [ -n "$img_in" ]; then
    wget -q -O ${DirShell}/moon_tmp.jpg "https://www.moongiant.com${img_in}" > /dev/null 2>&1
fi

# Limpiar texto
sed -i -e '/^ *$/d' -e 's/^ *//g' ${DirShell}/raw
sed -i '/Illumination/!d' ${DirShell}/raw
sed -i 's/<br>/\n/g' ${DirShell}/raw
sed -i 's|<[^>]*>||g' ${DirShell}/raw
sed -i -e '4d' ${DirShell}/raw

# Ejecutar procesamiento final
bash ${DirScripts}/lune_die.sh > /dev/null 2>&1

#EOF
