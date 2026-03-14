//
//  PomoDoroTimerTextLabel.swift
//  PockitPomodoro
//

import Cocoa

public class PomoDoroTimerTextLabel: NSTextField {

    public enum TextState {
        case on, off
    }

    private var timer: Timer?
    public var interval: TimeInterval = 1.0

    public var textState: TextState = .on
    public var state: PomoDoroTimerState = .stopping

    var timeRemaining: TimeInterval = 0.0
    var onFinish: (() -> Void)? = nil

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
        self.alignment = .center
        self.textColor = .headerTextColor
        self.font = NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        self.stringValue = "25:00"
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func formatString(time: TimeInterval, state: TextState = .on) -> String {
        let t = max(0, time)
        let m = Int(t) / 60
        let s = Int(t) % 60
        switch state {
        case .on:
            return String(format: "%02d:%02d", m, s)
        case .off:
            return String(format: "%02d %02d", m, s)
        }
    }

    public func start(minutes: Int) {
        self.timeRemaining = TimeInterval(minutes * 60)
        clearTimer()
        self.stringValue = PomoDoroTimerTextLabel.formatString(time: timeRemaining, state: .on)
        self.textState = .on
        
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(update(_:)), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
        self.state = .running
    }

    public func stop() {
        clearTimer()
        self.stringValue = PomoDoroTimerTextLabel.formatString(time: timeRemaining, state: self.textState)
        self.state = .stopping
    }

    public func reset() {
        self.timeRemaining = 0.0
        clearTimer()
        self.stringValue = ""
        self.state = .stopping
    }

    public func clearTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    func update(_ sender: Timer) {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            timeRemaining = 0
            self.stringValue = PomoDoroTimerTextLabel.formatString(time: timeRemaining, state: .on)
            stop()
            onFinish?()
            return
        }

        let string = PomoDoroTimerTextLabel.formatString(time: timeRemaining, state: self.textState)
        DispatchQueue.main.async {
            self.stringValue = string
        }
        self.textState = self.textState == .on ? .off : .on
    }
}
