# OpenWeatherMap-wather-conky-master

conky with openWeatherMap API plus a compass to indicate wind direction and moon phases using perl

More info: https://drcalambre.blogspot.com/2023/09/conky-implementando-perl-para-las-fases.html

Although my blog is in Spanish, there is a language translator for a better understanding. 

Best regards 

☕ Buy me a coffee :)

[![Invitame un café en cafecito.app](https://cdn.cafecito.app/imgs/buttons/button_1.svg)](https://cafecito.app/drcalambre)

* * *
# **Update in 05/01/26**
**
## 🔄 **New Requirement: Real Transparency with Picom (IceWM / AntiX)**

> **Important**: To achieve *real transparency* in Conky when using IceWM (AntiX), a compositor **must be running before Conky starts**.
> This project is tested and confirmed working with **picom**.

### Why this is required

IceWM does **not provide native compositing**.
Without a compositor:

* `own_window_transparent = true` only produces *pseudo-transparency*
* ARGB transparency will **not work correctly**
* Fonts, icons and background blending may look broken or opaque

Picom provides real compositing and ARGB support.

---

## ✅ Required Packages

Install picom if it is not already installed:

```bash
sudo apt install picom
```

---

## ▶️ Startup Order (Very Important)

**Picom must start BEFORE Conky.**

In AntiX / IceWM, edit your startup file:

```bash
~/.desktop-session/startup
```

### Correct example configuration

```bash
## --- Compositor (must start first) ---
picom --backend xrender --vsync &

## --- Conky ---
conky &
```

📌 **Key point**:
If Conky starts **before** picom, transparency will not be applied correctly.

---

## ⚙️ Recommended Conky Settings

Make sure your `conky.conf` includes the following options:

```lua
own_window = true,
own_window_type = 'override',
own_window_transparent = true,
own_window_argb_visual = true,
own_window_argb_value = 0,
double_buffer = true,
override_utf8_locale = true,
```

These options ensure:

* Real ARGB transparency
* No window borders or decorations
* Correct font and icon rendering

---

## 🧪 Troubleshooting

### Conky appears with solid background

✔ Verify picom is running:

```bash
pgrep picom
```

✔ Restart Conky **after** picom:

```bash
killall conky
conky &
```

---

### Transparency works only after restarting Conky

This indicates that picom is starting **after** Conky.
Fix the startup order as shown above.

---

### Performance notes (low-end systems)

For older GPUs or lightweight systems, the following picom options are recommended:

```bash
picom --backend xrender --vsync &
```

This avoids OpenGL overhead and works well with IceWM on AntiX.

---

## 🖥️ Tested Environment

* **Window Manager**: IceWM
* **Distribution**: AntiX Linux
* **Compositor**: picom (xrender backend)
* **Conky**: v1.10+

---


* * *
# **Update in 05/03/25**
**This update introduces a new Conky configuration that displays the remaining daylight hours until sunrise/sunset, calculated using a new script `horas_luz.sh`.**

## The new feature "Remaining Daylight":
![conky from my antiX desktop](screenshot/conky.gif)

## Conky Integration

The Conky configuration displays countdown timers for the time until sunrise and sunset, using the updated `horas_luz.sh` script and a stopwatch icon from the Material Design Icons font.

### Updated Features (June 2025)
- **Enhanced `horas_luz.sh` Script**:
  - Accepts two parameters: `--sunset <time>` and `--sunrise <time>` (e.g., `--sunset 17:34:00 --sunrise 08:33:00).
  - Computes countdown timers in `hh:mm:ss` format for:
    - **Time Until Sunset**: Time remaining until sunset, using the `--sunset` parameter.
    - **Time Until Sunrise**: Time until the next sunrise, using the `--sunrise` parameter.
  - Outputs a single value without delimiters (e.g., `04:28:00`).
  - Handles edge cases (e.g., `00:XX:XX` times) with default value assignments (e.g., `${hora_atardecer:-0}`) to prevent arithmetic errors.
- **Conky Display**:
  - **Countdown Timers**: Updated every minute (`execi 60`) via `horas_luz.sh`.
  - **Fonts and Icons**:
    - **DejaVu Sans (bold, size 9)**: Used for text labels and timer values.
    - **Material Design Icons (size 12)**: Displays the stopwatch icon (🕛, U+F51C) for both countdown timers, symbolizing the passage of time.
  - **Layout**: Centered alignment (`${alignc}`) with color formatting (`${color4}`) for labels and a vertical offset (`${voffset -3}`) for icon positioning.
- **Example Output** (simulated for June 5, 2025, 13:13 -03):

  Amanecer: 08:33:00 🕛 19:20:00
  Atardecer: 17:34:00 🕛 04:21:00


### Usage
- Ensure `horas_luz.sh` is executable:
```bash
chmod +x ~/.config/conky/scripts/horas_luz.sh
```
- **Install the Material Design Icons font:

```bash
    sudo apt install fonts-materialdesignicons-webfont
```
- **Add the following to your ~/.conkyrc:

```plaintext
    # --- Sunrise / Sunset ---#
    # --- Luz restante amanecer / atardecer ---#
    ${alignc}${color4}Amanecer: ${color}${font DejaVu:bold:size=9}${execi 1800 cat ~/.cache/openweathermap.json | jq -r .sys.sunrise | awk '{print strftime("%H:%M:%S",$1)}'} ${alignc}${font}${color4}${voffset -3}${font Material Design Icons:size=12}🕛${font}${font DejaVu:bold:size=9}${color}${exec ~/.config/conky/scripts/horas_luz.sh --sunrise "$(cat ~/.cache/openweathermap.json | jq -r .sys.sunset | awk '{print strftime("%H:%M:%S",$1)}')" "$(cat ~/.cache/openweathermap.json | jq -r .sys.sunrise | awk '{print strftime("%H:%M:%S",$1)}')"}${font}
    ${alignc}${color4}Atardecer: ${color}${font DejaVu:bold:size=9}${execi 1800 cat ~/.cache/openweathermap.json | jq -r .sys.sunset | awk '{print strftime("%H:%M:%S",$1)}'} ${alignc}${font}${color4}${voffset -3}${font Material Design Icons:size=12}🕛${font}${font DejaVu:bold:size=9}${color}${exec ~/.config/conky/scripts/horas_luz.sh --sunset "$(cat ~/.cache/openweathermap.json | jq -r .sys.sunset | awk '{print strftime("%H:%M:%S",$1)}')" "$(cat ~/.cache/openweathermap.json | jq -r .sys.sunrise | awk '{print strftime("%H:%M:%S",$1)}')"}${font}
```
- **Notes

    If the stopwatch icon (🕛) does not render, verify that the Material Design Icons font is installed:
    bash

```bash
    fc-list | grep "Material Design Icons"
```
- **Ensure override_utf8_locale = true is set in your Conky configuration and that ~/.conkyrc is saved in UTF-8 encoding:

```bash
    file -i ~/.conkyrc
    iconv -f ISO-8859-1 -t UTF-8 ~/.conkyrc -o ~/.conkyrc.new
    mv ~/.conkyrc.new ~/.conkyrc
```

* * *
# **Update in 03/08/24**
**This update introduces a new `conky.conf` configuration that monitors the temperature of two hard drives and displays an alert if the temperature is critical.**

```markdown
## Updated `conky.conf` File


```plaintext
conky.config = {
    alignment = 'top_right',
    background = false,
    double_buffer = true,
    update_interval = 1.0,
    total_run_times = 0,
    own_window = true,
    own_window_type = 'override',
    own_window_transparent = true,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    draw_borders = false,
    draw_graph_borders = true,
    default_color = 'white',
    default_shade_color = 'black',
    default_outline_color = 'black',
    use_xft = true,
    font = 'DejaVu Sans Mono:size=10',
    xftalpha = 0.8,
    override_utf8_locale = true,
    draw_outline = false,
    draw_shades = false,
    no_buffers = true,
    uppercase = false,
    cpu_avg_samples = 2,
    net_avg_samples = 2,
    text_buffer_size = 2048,
};

conky.text = [[
${color grey}Temperature of /dev/sda: ${execi 8 sudo smartctl -A /dev/sda | grep -i 'temperature_celsius' | awk '{if ($10 >= 50) print "ALERT! CRITICAL: " $10 "°C"; else print $10 "°C";}'}
${color grey}Temperature of /dev/sdb: ${execi 8 sudo smartctl -A /dev/sdb | grep -i 'temperature_celsius' | awk '{if ($10 >= 50) print "ALERT! CRITICAL: " $10 "°C"; else print $10 "°C";}'}
]];
```

### Explanation

1. **`execi` Command**: Executes an external command at specified intervals (in this case, every 8 seconds).
2. **`sudo smartctl -A /dev/sda`**: Retrieves the SMART information of the disk.
3. **`grep -i 'temperature_celsius'`**: Filters the line containing the temperature.
4. **`awk`**: Compares the temperature to a critical value (50°C). If the temperature is equal to or greater than 50°C, it displays an alert; otherwise, it shows the normal temperature.

### `sudo` Permissions

To allow Conky to execute `smartctl` with `sudo` without requiring a password, add a rule to `sudoers`. Edit the `sudoers` file with `visudo`:

```plaintext
sudo visudo
```

Add the following line at the end of the file, replacing `your_username` with the appropriate username:

```plaintext
your_username ALL=(ALL) NOPASSWD: /usr/sbin/smartctl
```

This will enable `smartctl` to run with `sudo` without requiring a password when invoked by Conky.

With these changes, Conky will directly display the temperature of the disks and highlight if any of them reach a critical level.

## Screenshots
![conky from my antiX desktop](screenshot/screenshot_conk_current_and_next_station.jpg)

![conky from my antiX desktop](screenshot/screenshot_conky.jpg)

The desktop wallpaper is a photograph of a sunset on one of my bicycle rides along the Rio Gallegos coastal (Argentina).
![conky from my antiX desktop](screenshot/screenshot_antix_rox-icewm_desktop.jpg)


* * *
# **Update in 02/06/24**
**calculate if it is spring, summer, autumn or winter.**

## The new icons for the stations:
![conky from my antiX desktop](icons/spring.png)
![conky from my antiX desktop](icons/summer.png)
![conky from my antiX desktop](icons/autumn.png)
![conky from my antiX desktop](icons/winter.png)

This update for Conky is useful for those who want to have updated information about the seasons of 
the year and the days remaining until the change of season, based on their geographical location. 

With this implementation, Conky can dynamically display the current season of the year and the remaining
days until the next season right on your desktop.

## Description of the Script
In `~/.config/conky/scripts/GetStation.sh`


This script calculates the current season (whether spring, summer, fall or winter) and the days remaining 
for the next season based on the current location.

Get Latitude: The script utilizes the ipinfo.io service to obtain the latitude of the user's current location.

Determine Hemisphere: 
Based on the obtained latitude, the script determines whether the user is in the northern or southern hemisphere.

Get Current Date: The script obtains the current date in the YYYY-MM-DD format.

Set Season Start Dates:

For the Northern Hemisphere:

Spring: March 21
Summer: June 21
Autumn: September 21
Winter: December 21

For the Southern Hemisphere:

Spring: September 21
Summer: December 21
Autumn: March 21
Winter: June 20

Calculate Current and Next Season: 
The script compares the current date with the season start dates to determine the current season and the next season.

Calculate Remaining Days for Next Season: 
The script calculates the number of days remaining until the start of the next season.
Determine Text for Remaining Days: Depending on the number of remaining days, the script generates 
appropriate text (e.g., "one day until" or "X days until").

Copy Season Icons: 
The script copies the corresponding icons for the current season and the next season to the user's temporary directory.

Show Results: Finally, the script displays the current season, the icon of the current season, the next season, the icon 
of the next season, and the text for the remaining days.

## Argentine Postcards and the seasons:

In San Martin de los Andes, a city in the southwest of the province of Neuquén, nestled in the Andes Mountains.
The transition from autumn to winter.
A beautiful mix of colors with the early arrival of the snow.

![conky from my antiX desktop](screenshot/otoño-invierno-Patagonia.jpg)
