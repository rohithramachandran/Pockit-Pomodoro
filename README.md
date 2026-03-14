# PockitPomodoro

PockitPomodoro is an open-source Pomodoro Timer widget plugin for [Pock](https://github.com/pock/pock). It adds a fully functional Pomodoro timer directly to your Mac's Touch Bar!

## Features
- **Selection Mode:** Easily choose between 25-minute, 15-minute, and 5-minute intervals.
- **Countdown Display:** Live countdown directly on your Touch Bar.
- **Quick Actions:** Tap to pause/resume or long-press to reset the timer.

## How to Build
To build the project from source, you'll need Xcode installed on your Mac.

1. Clone the repository and navigate to the root directory:
   ```bash
   cd PockitPomodoro
   ```
2. Build the project using `xcodebuild`:
   ```bash
   xcodebuild build -scheme PockitPomodoro -project PockitPomodoro.xcodeproj
   ```
3. Once the build succeeds, the output `.pock` widget plugin will be located in the derived data or local Products directory. Double-click the `.pock` bundle to install it into Pock.

## Changing Behavior
The logic for the widget is written in Swift and is structured using the PockKit framework.

To change the behavior of the widget, you can modify the source files located in `PockitPomodoro/Sources/`:

- `PomoDoroTimerWidget.swift`: The main entry point for the widget plugin. This file registers the widget with Pock and handles Touch Bar interactions (e.g. tracking taps and long presses).
- `PomoDoroTimerView.swift`: Handles the visual stack on the Touch Bar. To change the intervals or the layout of the selection buttons, you can edit the initialization and `updateViewState()` method here.
- `PomoDoroTimerTextLabel.swift`: Contains the countdown logic and formatting for the timer string. If you want to modify how the time is calculated or formatted, this is the file to change.
