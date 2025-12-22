#!/bin/bash

# GetStation.sh
# Versión corregida: arregla días negativos al cruzar el año (verano → otoño en sur, invierno → primavera en norte)

# Obtener la latitud usando ipinfo.io
latitude=$(curl -s https://ipinfo.io/ | jq -r '.loc' | cut -d ',' -f 1)

# Determinar el hemisferio basado en la latitud
if (( $(echo "$latitude > 0" | bc -l) )); then
    hemisphere="norte"
else
    hemisphere="sur"
fi

# Obtener la fecha actual
current_date=$(date +%Y-%m-%d)
current_year=$(date +%Y)

# Establecer las fechas de inicio de las estaciones según el hemisferio (año actual)
if [[ "$hemisphere" == "norte" ]]; then
    spring_start=$(date -d "${current_year}-03-21" +%Y-%m-%d)
    summer_start=$(date -d "${current_year}-06-21" +%Y-%m-%d)
    autumn_start=$(date -d "${current_year}-09-21" +%Y-%m-%d)
    winter_start=$(date -d "${current_year}-12-21" +%Y-%m-%d)
else
    spring_start=$(date -d "${current_year}-09-21" +%Y-%m-%d)
    summer_start=$(date -d "${current_year}-12-21" +%Y-%m-%d)
    autumn_start=$(date -d "${current_year}-03-21" +%Y-%m-%d)
    winter_start=$(date -d "${current_year}-06-20" +%Y-%m-%d)
fi

# Fechas del año siguiente (solo las que pueden cruzarse)
next_year=$((current_year + 1))
next_year_autumn=$(date -d "${next_year}-03-21" +%Y-%m-%d)
next_year_spring_norte=$(date -d "${next_year}-03-21" +%Y-%m-%d)

# Calcular la estación actual y la próxima estación
if [[ "$hemisphere" == "norte" ]]; then
    if [[ "$current_date" > "$winter_start" ]] || [[ "$current_date" < "$spring_start" ]]; then
        current_season="Invierno"
        next_season="Primavera"
        # Corrección clave: si ya pasó el 21-dic, primavera es del año siguiente
        if [[ "$current_date" > "$winter_start" ]]; then
            next_season_date=$next_year_spring_norte
        else
            next_season_date=$spring_start
        fi
        current_icon="winter"
        next_icon="spring"
    elif [[ "$current_date" < "$summer_start" ]]; then
        current_season="Primavera"
        next_season="Verano"
        next_season_date=$summer_start
        current_icon="spring"
        next_icon="summer"
    elif [[ "$current_date" < "$autumn_start" ]]; then
        current_season="Verano"
        next_season="Otoño"
        next_season_date=$autumn_start
        current_icon="summer"
        next_icon="autumn"
    else
        current_season="Otoño"
        next_season="Invierno"
        next_season_date=$winter_start
        current_icon="autumn"
        next_icon="winter"
    fi
else
    # Hemisferio sur
    if [[ "$current_date" > "$summer_start" ]] || [[ "$current_date" < "$autumn_start" ]]; then
        current_season="Verano"
        next_season="Otoño"
        # Corrección clave: si ya comenzó el verano (después del 21-dic), otoño es del año siguiente
        if [[ "$current_date" > "$summer_start" ]]; then
            next_season_date=$next_year_autumn
        else
            next_season_date=$autumn_start
        fi
        current_icon="summer"
        next_icon="autumn"
    elif [[ "$current_date" < "$winter_start" ]]; then
        current_season="Otoño"
        next_season="Invierno"
        next_season_date=$winter_start
        current_icon="autumn"
        next_icon="winter"
    elif [[ "$current_date" < "$spring_start" ]]; then
        current_season="Invierno"
        next_season="Primavera"
        next_season_date=$spring_start
        current_icon="winter"
        next_icon="spring"
    else
        current_season="Primavera"
        next_season="Verano"
        next_season_date=$summer_start
        current_icon="spring"
        next_icon="summer"
    fi
fi

# Calcular los días restantes para la próxima estación
current_date_sec=$(date -d "$current_date" +%s)
next_season_date_sec=$(date -d "$next_season_date" +%s)
days_until_next_season=$(( (next_season_date_sec - current_date_sec) / 86400 ))

# Determinar el texto de los días restantes
if [ "$days_until_next_season" -eq 1 ]; then
    days_text="un día para"
else
    days_text="$days_until_next_season días para"
fi

# Copiar iconos (quitamos -r porque no es necesario y a veces falla)
cp ~/.config/conky/icons/${current_icon}.png ~/.cache/current_station.png 2>/dev/null
cp ~/.config/conky/icons/${next_icon}.png ~/.cache/next_station.png 2>/dev/null

# Mostrar salida
echo "$current_season;$current_icon;$next_season;$next_icon;$days_text"
