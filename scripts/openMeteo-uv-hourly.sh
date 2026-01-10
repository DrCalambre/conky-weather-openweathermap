#!/bin/bash
# ----------------------------------------------------------------------------------------------------------------------------
# File: openMeteo-uv-hourly.sh
# Type: Bash Shell Script
# By Julio Alberto Lascano
# Last modified: 2026-01-08
# ----------------------------------------------------------------------------------------------------------------------------
# RGL : Rio Gallegos city, Argentina lat=-51.6226 lon=-69.2181
# API:
# https://api.open-meteo.com/v1/forecast?latitude=-51.6226&longitude=-69.2181&hourly=uv_index&timezone=auto
# ----------------------------------------------------------------------------------------------------------------------------
# Purpose:
# - Download hourly UV index forecast
# - Dedicated cache for later processing (max UV, hour, etc.)
# - No presentation logic
# ----------------------------------------------------------------------------------------------------------------------------

CACHE="$HOME/.cache/uv_hourly.json"

curl -s \
"https://api.open-meteo.com/v1/forecast?latitude=-51.6226&longitude=-69.2181&hourly=uv_index&timezone=auto" \
-o "$CACHE"
