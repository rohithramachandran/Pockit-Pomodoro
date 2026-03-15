# 🍅 PockitPomodoro

An open-source Pomodoro Timer widget for [Pock](https://github.com/pock/pock) — a powerful widgets manager for the Mac Touch Bar.

[![Github issues](https://img.shields.io/github/issues/rohithramachandran/Pockit-Pomodoro)](https://github.com/rohithramachandran/Pockit-Pomodoro/issues)
[![Github stars](https://img.shields.io/github/stars/rohithramachandran/Pockit-Pomodoro)](https://github.com/rohithramachandran/Pockit-Pomodoro/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/rohithramachandran/Pockit-Pomodoro)](https://github.com/rohithramachandran/Pockit-Pomodoro/)

---

## ✨ Features

- 🕐 **Customizable Durations** — Choose between 10, 20, or 30 minute sessions directly from the Touch Bar
- ⏱ **Live Countdown** — Real-time countdown display right on your Touch Bar
- 🔔 **Completion Alert** — 3 beep sounds when the timer finishes so you never miss it
- 🍅 **Multiple Timers** — Add multiple Pomodoro widgets side by side for tracking parallel tasks
- 🎨 **Native macOS Design** — Built with PockKit for a seamless Touch Bar experience

---

## 🎮 How to Use

### Basic Controls

| Touch | State | Action |
|-------|-------|--------|
| **Tap** | Idle | Start the timer with the currently selected duration |
| **Tap** | Running | Stop the timer |
| **Long Press** | Idle | Cycle to next duration: `10 min → 20 min → 30 min → 10 min...` |
| **Long Press** | Running | Stop and reset the timer |

### Reading the Widget

- **Idle** — Shows a ⏱ timer icon + the selected duration (e.g. `10:00`). This tells you what will start when you tap.
- **Running** — Shows a ⏹ stop icon + live countdown (e.g. `09:42`)
- **Finished** — 3 beeps play and the widget resets to idle automatically

---

## 🔀 Using Multiple Timers

Pock supports adding the same widget **multiple times**, making it easy to track parallel tasks or separate work/break timers side by side.

### Steps to Add Multiple Pomodoro Timers

1. Open Pock and click **Customize Pock…** from the menu bar
2. In the customization panel, locate the **Pomodoro** widget
3. Drag a **Pomodoro** widget into your Touch Bar
4. Drag **another Pomodoro** widget next to the first one — Pock allows this!
5. Each widget instance is **fully independent** — different durations, different countdowns

### Example Setup

```
| 🍅 10:00 | 🍅 20:00 | ... other widgets ... |
```

You could use one timer for a focused work sprint and another as a break reminder, all running independently in your Touch Bar.

---

## 📦 Installation

### Download (Recommended)
1. Download the latest `PockitPomodoro.pock` from [Releases](https://github.com/rohithramachandran/Pockit-Pomodoro/releases)
2. Double-click the `.pock` file to install it into Pock
3. Open Pock → **Customize Pock…** and drag the **Pomodoro** widget into your Touch Bar

### Build from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/rohithramachandran/Pockit-Pomodoro.git
   cd Pockit-Pomodoro
   ```
2. Build with Xcode:
   ```bash
   xcodebuild build -scheme PockitPomodoro -project PockitPomodoro.xcodeproj
   ```
3. The compiled `.pock` bundle will appear in your project directory. Double-click to install.

---

## 🔧 Changing Behavior

The widget is written in Swift using PockKit. Key source files:

| File | Purpose |
|------|---------|
| `PomoDoroTimerWidget.swift` | Widget entry point — registers with Pock, handles screen edge interactions |
| `PomoDoroTimerView.swift` | Main view — controls state machine (idle/running) and gesture handling. **Edit `durations` array here to change available intervals.** |
| `PomoDoroTimerTextLabel.swift` | Countdown display — handles timer logic and text rendering |

### Change Available Durations

Open `PomoDoroTimerView.swift` and edit the `durations` array:

```swift
// Default: 10, 20, 30 minutes
private let durations: [Int] = [10, 20, 30]

// Example: Add a 45-minute option
private let durations: [Int] = [10, 20, 30, 45]

// Example: Classic Pomodoro (25 min work + 5 min break)
private let durations: [Int] = [25, 5]
```

After editing, rebuild and reinstall the `.pock` bundle.

---

## 🛠 Requirements

- macOS 11.0+
- [Pock](https://pock.app) installed
- A MacBook with a Touch Bar

---

## 📄 License

MIT — see [LICENSE](LICENSE)
