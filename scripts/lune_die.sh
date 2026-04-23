#!/bin/bash


# -------------------------------------------------------------------
# File: lune_die.sh                                      /\
# Type: Bash Shell Script                               /_.\
# By Fernando Gilli fernando<at>wekers(dot)org    _,.-'/ `",\'-.,_
# Last modified:2023-10-13                     -~^    /______\`~~-^~:
# ------------------------
# Get Moon data from moongiant.com
# / OS : $Linux, $FreeBSD (X Window)
# -------------------------------------------------------------------
# adapted for the current version by: 
#________          _________        .__                ___.                  
#\______ \_______  \_   ___ \_____  |  | _____    _____\_ |_________   ____  
# |    |  \_  __ \ /    \  \/\__  \ |  | \__  \  /     \| __ \_  __ \_/ __ \ 
# |    `   \  | \/ \     \____/ __ \|  |__/ __ \|  Y Y  \ \_\ \  | \/\  ___/ 
#/_______  /__|     \______  (____  /____(____  /__|_|  /___  /__|    \___  >
#        \/                \/     \/          \/      \/    \/            \/ 
# Julio Alberto Lascano http://drcalambre.blogspot.com/
# Last modified:2023-10-29
# -------------------------------------------------------------------


# set language
lang="pt-es"

# put your hemisphere here:
# n for north
# s for south
hemisphere="s"

# Working directory
DirShell="$HOME/.cache"
DirScripts="$HOME/.config/conky/scripts"

cd ${DirShell}
touch ${DirShell}/moon_phase_die

perl ${DirScripts}/moon.pl

sleep 3
# Translate pt-es

case $lang in
	pt-es)
		sed -i -e 's/New Moon/Luna Nueva/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Full Moon/Luna Llena/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Waxing Crescent/Luna Creciente/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Waxing Gibbous/Gibosa Creciente/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Waning Crescent/Creciente Menguante/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Waning Gibbous/Gibosa Menguante/g' ${DirShell}/moon_phase_die
          sed -i -e 's/First Quarter/Cuarto Creciente/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Last Quarter/Cuarto Menguante/g' ${DirShell}/moon_phase_die
     #months
          sed -i -e 's/Apr/Abr/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Aug/Ago/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Set/Sep/g' ${DirShell}/moon_phase_die
          sed -i -e 's/Dec/Dic/g' ${DirShell}/moon_phase_die
     #others
          sed -i -e 's/in /en /g' ${DirShell}/moon_phase_die
          sed -i -e 's/and/y/g' ${DirShell}/moon_phase_die
          sed -i -e '/^$/d' ${DirShell}/moon_phase_die
     #Translate moon phase name
          sed -i -e 's/New Moon/Luna Nueva/g' ${DirShell}/raw
          sed -i -e 's/Full Moon/Luna Llena/g' ${DirShell}/raw
          sed -i -e 's/Waxing Crescent/Luna Creciente/g' ${DirShell}/raw
          sed -i -e 's/Waxing Gibbous/Gibosa Creciente/g' ${DirShell}/raw
          sed -i -e 's/Waning Crescent/Creciente Menguante/g' ${DirShell}/raw
          sed -i -e 's/Waning Gibbous/Gibosa Menguante/g' ${DirShell}/raw
          sed -i -e 's/First Quarter/Cuarto Creciente/g' ${DirShell}/raw
          sed -i -e 's/Last Quarter/Cuarto Menguante/g' ${DirShell}/raw
          ;;
	
esac



# mirror + integración por contraste (sin transparencia)

if [[ $hemisphere == "s" ]]; then
  /usr/bin/convert ${DirShell}/moon_tmp.jpg \
    -flop \
    -brightness-contrast -8x18 \
    -gamma 0.92 \
    ${DirShell}/moon.jpg
else
  /usr/bin/convert ${DirShell}/moon_tmp.jpg \
    -brightness-contrast -8x18 \
    -gamma 0.92 \
    ${DirShell}/moon.jpg
fi

rm -f ${DirShell}/moon_tmp.jpg
#EOF
