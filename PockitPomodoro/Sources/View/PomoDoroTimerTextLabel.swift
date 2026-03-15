//
//  PomoDoroTimerTextLabel.swift
//  PockitPomodoro
//

import Cocoa

// UserDefaults keys for persisting timer state
private let kEndDateKey = "pockitpomodoro.endDate"

public class PomoDoroTimerTextLabel: NSView {

    public enum TextState {
        case on, off
    }

    private var timer: Timer?
    public var interval: TimeInterval = 1.0
    public var textState: TextState = .on
    public var state: PomoDoroTimerState = .stopping

    var onFinish: (() -> Void)? = nil

    public var displayText: String = "" {
        didSet { setNeedsDisplay(bounds) }
    }
    public var textColor: NSColor = .headerTextColor
    public var font: NSFont = NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)

    // Persist the absolute end time so screen-sleep / view-recreate don't reset the timer
    private var endDate: Date? {
        get { UserDefaults.standard.object(forKey: kEndDateKey) as? Date }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date, forKey: kEndDateKey)
            } else {
                UserDefaults.standard.removeObject(forKey: kEndDateKey)
            }
        }
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    public func start(minutes: Int) {
        let end = Date().addingTimeInterval(TimeInterval(minutes * 60))
        endDate = end
        startCounting()
    }

    /// Restore from persisted state — returns true if there was an active timer
    @discardableResult
    public func restoreIfNeeded() -> Bool {
        guard let end = endDate else { return false }
        let remaining = end.timeIntervalSinceNow
        if remaining <= 0 {
            // Timer already done while screen was off
            endDate = nil
            displayText = "00:00"
            state = .stopping
            return false
        }
        startCounting()
        return true
    }

    public func stop() {
        endDate = nil
        clearTimer()
        state = .stopping
        // Keep last displayed value
    }

    public func reset() {
        endDate = nil
        clearTimer()
        displayText = ""
        state = .stopping
    }

    public func showIdleDuration(minutes: Int) {
        let t = TimeInterval(minutes * 60)
        displayText = PomoDoroTimerTextLabel.formatString(time: t)
        state = .stopping
    }

    public var isRunning: Bool { state == .running }

    // MARK: - Private

    private func startCounting() {
        clearTimer()
        state = .running
        // Immediately update display
        tick()
        timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true
        )
        if let t = timer {
            RunLoop.main.add(t, forMode: .common)
        }
    }

    private func tick() {
        guard let end = endDate else { return }
        let remaining = max(0, end.timeIntervalSinceNow)
        displayText = PomoDoroTimerTextLabel.formatString(time: remaining)
    }

    public func clearTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func timerFired(_ sender: Timer) {
        guard let end = endDate else { stop(); return }
        let remaining = end.timeIntervalSinceNow

        if remaining <= 0 {
            displayText = "00:00"
            stop()
            DispatchQueue.main.async { self.onFinish?() }
            return
        }

        let string = PomoDoroTimerTextLabel.formatString(time: remaining)
        DispatchQueue.main.async { self.displayText = string }
    }

    // MARK: - Drawing

    private static func formatString(time: TimeInterval) -> String {
        let t = max(0, time)
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }

    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let string = displayText as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        let size = string.size(withAttributes: attrs)
        let x = (bounds.width - size.width) / 2
        let y = (bounds.height - size.height) / 2
        string.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
    }
}
