# Pump Relay Monitoring Setup or Relay Tapper Device

This project explains how to monitor a **pump relay state** using an **optocoupler (PC817/PS817C)** and an **ESP8266/ESP32** for smart home applications. It ensures **electrical isolation** between your microcontroller and the relay board.

---

## ⚙️ Components Required

| Component | Quantity | Description |
|-----------|----------|-------------|
| ESP8266 / ESP32 | 1 | Microcontroller to read relay state and send updates |
| Optocoupler (PC817 / PS817C) | 1 | Isolates relay voltage from ESP |
| Relay Module (Auto-cut) | 1 | Controls the pump |
| Resistors | 1–2 | 22 kΩ series resistor for LED side of optocoupler |
| Wires / Jumper cables | — | For connections |
| Optional Buzzer / LED | 1 | For local notifications when pump state changes |

---

## 🔌 Connections

| Relay Side | Optocoupler Side | ESP Side | Notes |
|------------|-----------------|----------|-------|
| Relay Coil + | → 22 kΩ or 12 kΩ series → PC817 pin 1 (Anode) | — | Limits current to LED inside optocoupler |
| Relay Coil − | → PC817 pin 2 (Cathode) | — | Completes LED circuit |
| PC817 pin 3 (Collector) | → ESP D2 | Input with `INPUT_PULLUP` | Reads logic state |
| PC817 pin 4 (Emitter) | → GND | Common ground with ESP | Required for correct logic |
| Optional Buzzer | → ESP D5 | Output | Triggers sound when pump state changes |

> 💡 **Tip:** For voltages higher than 5V, increase the series resistor value to keep LED current safe (~10–15 mA).

---

## 🧠 Logic Table

| Relay Coil | PC817 LED | ESP D2 Input (`INPUT_PULLUP`) | Pump Logic |
|------------|-----------|-------------------------------|------------|
| ON (Pump ON) | Lit | LOW | ON |
| OFF (Pump OFF) | Off | HIGH | OFF |

- Use `INPUT_PULLUP` on ESP pin to read a stable HIGH when relay is OFF and LOW when relay is ON.
- Only trigger notifications in software when **state changes**, to avoid repeated alerts on app startup.

---

## ⚠️ Safety Notes
- Never connect the relay coil directly to the ESP; always use an optocoupler.

- Ensure the series resistor is in place to prevent overcurrent through the optocoupler LED.

- Keep ESP ground separate from relay coil ground, except for the optocoupler emitter connection.

- Optional: add flyback diodes across the relay coil if necessary to protect your circuit.


