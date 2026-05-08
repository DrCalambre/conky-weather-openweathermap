# get_temp.sh
#!/bin/bash
jq -r .main.temp ~/.cache/openweathermap.json | awk '{printf "%.0f", $1}' > ~/.cache/current_temp
