//
//  PomoDoroTimerWidget.swift
//  PockitPomodoro
//

import AppKit
import PockKit

class PomoDoroTimerWidget: PKWidget {
    static var identifier: String = "\(PomoDoroTimerWidget.self)"
    var customizationLabel: String = "Timer"
    var view: NSView!

    private var timerView = PomoDoroTimerView()

    required init() {
        view = timerView
    }

}

extension PomoDoroTimerWidget: PKScreenEdgeMouseDelegate {
    private func shouldHighlight(for location: NSPoint, in view: NSView) -> Bool {
        timerView.convert(timerView.bounds, to: view).contains(location)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseEnteredAtLocation location: NSPoint, in view: NSView) {
        timerView.isHighlighted = shouldHighlight(for: location, in: view)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseMovedAtLocation location: NSPoint, in view: NSView) {
        timerView.isHighlighted = shouldHighlight(for: location, in: view)
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseClickAtLocation location: NSPoint, in view: NSView) {
        timerView.isHighlighted = shouldHighlight(for: location, in: view)
        if timerView.isHighlighted {
            timerView.tap(nil)
        }
    }

    func screenEdgeController(_ controller: PKScreenEdgeController, mouseExitedAtLocation location: NSPoint, in view: NSView) {
        timerView.isHighlighted = false
    }
}
