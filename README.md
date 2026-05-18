# MH Balance — Garmin Energy Watch Face

> *Your energy matters more than your step count.*

A clean, minimalist Garmin Connect IQ watch face built around two core health signals:

| Arc | Metric | Colour |
|-----|--------|--------|
| Left semi-circle  | **Body Battery** (0–100) | 🔵 Blue → 🟠 Orange when ≤ 30 % |
| Right semi-circle | **Stress level** (0–100) | 🔴 Red |

When energy drops below **30 %** the Body Battery arc turns orange and a **"REST · RECOVER"** warning appears — a gentle reminder to slow down before you burn out.

---

## Why this project exists

Most Garmin watch faces are designed for athletes and training metrics.  
This one is designed for **daily life energy management**.

The two metrics that matter most:
- **Body Battery** — how much energy you have right now
- **Stress** — how hard your nervous system is working

Built during the era of AI-assisted *vibe coding* — proof that curiosity + the right tools can replace years of specialized knowledge.

---

## Features

- ⏱ Large, readable clock (12 h / 24 h respects system setting)
- 🔵 Body Battery semi-circle arc (left side)
- 🔴 Stress semi-circle arc (right side)
- 🟠 Low-energy warning at ≤ 30 % Body Battery
- 📅 Date displayed below the time
- 🔢 Metric percentages labelled on each side
- ⚫ Minimal black background — low distraction

---

## Philosophy

> Productivity without recovery eventually becomes self-destruction.

Energy is the foundation of everything: business, creativity, relationships, health, and happiness.

---

## Project structure

```
mh-balance_garmin/
├── manifest.xml                    — App manifest (ID, permissions, supported devices)
├── monkey.jungle                   — Build configuration
├── source/
│   ├── MhBalanceApp.mc             — Application entry point
│   └── MhBalanceView.mc            — Watch face drawing logic
└── resources/
    ├── drawables/
    │   ├── drawables.xml
    │   └── launcher_icon.png
    ├── layouts/
    │   └── layout.xml
    └── strings/
        └── strings.xml
```

---

## Compatibility

Requires **Garmin Connect IQ 3.4.0+** and a device with **Body Battery** support.

Included device targets (from `manifest.xml`):

- Fenix 6 / 6S / 6X / 6 Pro series, Fenix 7 / 7S / 7X / 7 Pro series
- Forerunner 245 / 745 / 945 / 955 / 265 / 965
- Venu / Venu 2 / Venu 2S / Venu 2 Plus / Venu SQ / Venu SQ 2
- Vivoactive 4 / 4S / 5
- Epix / Epix 2 / Epix 2 Pro

---

## Building

1. Install the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/).
2. Clone this repository.
3. Build with the SDK:
   ```bash
   monkeyc -o MhBalance.prg -f monkey.jungle -y developer_key.der -d venu2
   ```
4. Deploy to the simulator or a physical device.

---

## Author

**Arman Toskanbayev** — [@toskanbayev.a](https://www.instagram.com/toskanbayev.a)
