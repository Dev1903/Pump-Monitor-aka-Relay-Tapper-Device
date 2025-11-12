# Smart Pump Monitoring System

This repository contains a **complete smart home pump monitoring system** with both a **mobile app** and **microcontroller firmware** along with a [ready made autocut pump controller](https://amzn.in/d/gPgMTBA). The project allows monitoring and controlling devices like **pump, fan, light, and lamp** with notifications for state changes.

---

## Repository Structure

```yaml
repo-root/
├─ App/ # Flutter mobile app code
│ └─ README.md # Detailed setup & usage for the app
├─ Microcontroller Code/ # ESP32/ESP8266 firmware code
│ └─ README.md # Detailed setup & usage for microcontroller
└─ README.md # This overview file
```

---

## Overview

- **App Folder**: Contains the Flutter project for Android/iOS.
  - Features:
    - Real-time device monitoring.
    - Device control (pump, fan, light, lamp).
    - Local notifications on pump state changes.
    - Message panel showing events.
  - See `App/README.md` for **detailed setup instructions**.

- **Microcontroller Code Folder**: Contains ESP32/ESP8266 firmware.
  - Features:
    - Reads relay states via optocouplers.
    - Sends device states to Firebase or Blynk.
    - Example code for pump monitoring and relay control.
  - See `Microcontroller Code/README.md` for **detailed setup instructions**.

---

## Components Overview
```

          ┌─────────────┐
          │  User App   │
          │  (Flutter)  │
          └─────┬───────┘
                │
                │ Read/Update Device States
                │
          ┌─────▼───────┐
          │   Firebase  │
          │ / Blynk API │
          └─────┬───────┘
                │
                │ Send Commands / Receive Status
                │
          ┌─────▼─────────────┐
          │ Microcontroller   │
          │  (ESP32/ESP8266)  │
          └─────┬─────────────┘
                │
     ┌──────────┴───────────┐
     │                      │
 ┌───▼───┐              ┌───▼───┐
 │ Relay │              │ Relay │
 │Pump   │              │ Fan,  |
 │       |              | Light,|
 |       |              | NghtLmp
 └───┬───┘              └───┬───┘
     │                      │
   Devices                Devices
     │                      │
 ┌───▼───┐              ┌───▼───┐
 │ Pump  │              │ Elect.│
 └───────┘              └───────┘
 ```


---

## How It Works

1. **Microcontroller reads device states** through optocouplers.
2. **Device states are sent to Firebase/Blynk** in real time.
3. **Flutter app fetches states** and updates the UI accordingly.
4. **Local notifications** alert the user only when the pump state changes.
5. User can **toggle devices** from the app, sending commands back to the microcontroller via cloud.
6. Refer to [**SHARP repo**](https://github.com/Dev1903/S.H.A.R.P.-Home-Automation-2.0) for controlling devices via app

---

## Notes

- Each folder has its **own README** with full setup instructions, wiring diagrams, and code examples.
- Use this root README for **overall understanding and navigation**.

---
