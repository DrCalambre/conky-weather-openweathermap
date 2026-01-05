# OpenWeatherMap-wather-conky-master

A Conky configuration using the **OpenWeatherMap API**, featuring:
- Weather information
- Wind direction compass
- Moon phases
- Seasonal indicators
- Remaining daylight until sunrise/sunset

Implemented using **Bash, Perl and Conky**, designed and tested primarily on **AntiX Linux + IceWM**.

📖 More info (Spanish):  
https://drcalambre.blogspot.com/2023/09/conky-implementando-perl-para-las-fases.html  
(A language translator is available on the blog.)

---

☕ Buy me a coffee :)

[![Invitame un café en cafecito.app](https://cdn.cafecito.app/imgs/buttons/button_1.svg)](https://cafecito.app/drcalambre)

---

## 🛠️ Installation

### 🔄 Real Transparency Requirement (IceWM / AntiX)

> **Important**  
> To achieve *real transparency* in Conky when using **IceWM**, a compositor **must be running before Conky starts**.  
> This project is tested and confirmed working with **picom**.

### Why this is required

IceWM does **not provide native compositing**.

Without a compositor:
- `own_window_transparent = true` only produces *pseudo-transparency*
- ARGB transparency will **not work correctly**
- Fonts, icons and background blending may appear opaque or broken

Picom provides real compositing and proper ARGB support.

---

### ✅ Required Packages
Make sure the following packages are installed:
```bash
sudo apt install conky picom jq curl fonts-materialdesignicons-webfont
```

Optional (only if you use disk temperature monitoring):

```bash
sudo apt install smartmontools
```

---

## 2️⃣ Clone the Repository

```bash
git clone https://github.com/DrCalambre/OpenWeatherMap-wather-conky-master.git
cd OpenWeatherMap-wather-conky-master
```

Copy the files to your Conky directory:

```bash
mkdir -p ~/.config/conky
cp -r * ~/.config/conky/
```

---

## 3️⃣ Make Scripts Executable

Ensure all scripts are executable:

```bash
chmod +x ~/.config/conky/scripts/*.sh
chmod +x ~/.config/conky/scripts/*.pl
```

---

## 4️⃣ Configure OpenWeatherMap API

Edit the weather script and insert your OpenWeatherMap API key:

```bash
nano ~/.config/conky/scripts/openweathermap.sh
```

Replace:

```bash
API_KEY="your_api_key_here"
```

---
## 5️⃣ Enable Real Transparency (IceWM / AntiX)

Install picom if it is not already installed:

```bash
sudo apt install picom
````

---

### ▶️ Startup Order (Very Important)

**Picom must start BEFORE Conky.**

Edit the AntiX startup file:

```bash
~/.desktop-session/startup
```

#### Correct example configuration

```bash
## --- Compositor (must start first) ---
picom --backend xrender --vsync &

## --- Conky ---
sleep 1
bash /usr/local/bin/conkytoggle.sh &

```

📌 If Conky starts **before** picom, transparency will not be applied correctly.

---

### ⚙️ Recommended Conky Settings

Ensure your `conky.conf` includes:

```lua
own_window = true,
own_window_type = 'dock',
own_window_hints = 'undecorated,sticky,skip_taskbar,skip_pager,below',
own_window_transparent = true,
own_window_argb_visual = true,
own_window_argb_value = 80,
double_buffer = true,
override_utf8_locale = true,
```

This ensures:

* Real ARGB transparency
* No window borders or decorations
* Correct font and icon rendering

---

### 🧪 Troubleshooting

**Conky shows a solid background**

```bash
pgrep picom
```

Restart Conky **after** picom:

```bash
killall conky
conky &
```

**Transparency only works after restarting Conky**
Picom is starting too late. Fix the startup order.

---

### 🖥️ Tested Environment

* **Window Manager**: IceWM
* **Distribution**: AntiX Linux
* **Compositor**: picom (xrender backend)
* **Conky**: v1.10+

---

## 🆕 Updates & Technical History

---

### **Update — 05/01/26**

**Real transparency support using Picom (IceWM / AntiX)**
Introduces mandatory compositor usage to enable proper ARGB transparency in Conky.

---

### **Update — 05/03/25**

**Remaining daylight until sunrise/sunset**

![conky from my antiX desktop](screenshot/conky.gif)

Introduces a new Conky block showing:

* Time until sunrise
* Time until sunset

Powered by the `horas_luz.sh` script.

#### Highlights

* Countdown timers in `hh:mm:ss`
* Material Design Icons stopwatch (🕛)
* Automatic edge-case handling

(See full configuration and usage below.)

---

### **Update — 03/08/24**

**Hard drive temperature monitoring**

Displays SMART temperature for two disks and triggers alerts when critical.

Includes:

* `smartctl` integration
* Optional passwordless sudo configuration
* Visual alerts in Conky

---

### **Update — 02/06/24**

**Season detection and remaining days**

Automatically detects:

* Current season
* Next season
* Days remaining until season change

Supports both hemispheres and displays seasonal icons dynamically.

![conky from my antiX desktop](icons/spring.png)
![conky from my antiX desktop](icons/summer.png)
![conky from my antiX desktop](icons/autumn.png)
![conky from my antiX desktop](icons/winter.png)

---

## 📸 Screenshots

![conky from my antiX desktop](screenshot/screenshot_conk_current_and_next_station.jpg)
![conky from my antiX desktop](screenshot/screenshot_conky.jpg)

The desktop wallpaper is a photograph taken during a bicycle ride along the Río Gallegos coastline (Argentina).

![conky from my antiX desktop](screenshot/screenshot_antix_rox-icewm_desktop.jpg)

