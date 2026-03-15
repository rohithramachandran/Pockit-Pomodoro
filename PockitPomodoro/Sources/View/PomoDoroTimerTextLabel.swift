//
//  PomoDoroTimerTextLabel.swift
//  PockitPomodoro
//

import Cocoa

public class PomoDoroTimerTextLabel: NSView {

    public enum TextState {
        case on, off
    }

    private var timer: Timer?
    public var interval: TimeInterval = 1.0

    public var textState: TextState = .on
    public var state: PomoDoroTimerState = .stopping

    var timeRemaining: TimeInterval = 0.0
    var onFinish: (() -> Void)? = nil

    public var displayText: String = "25:00" {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    public var textColor: NSColor = .headerTextColor
    public var font: NSFont = NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
    public var padding: CGFloat = 2

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.displayText = "25:00"
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    public func start(minutes: Int) {
        self.timeRemaining = TimeInterval(minutes * 60)
        clearTimer()
        self.displayText = PomoDoroTimerTextLabel.formatString(time: timeRemaining)
        self.textState = .on
        timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(update(_:)),
            userInfo: nil,
            repeats: true
        )
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
        self.state = .running
    }

    public func stop() {
        clearTimer()
        self.displayText = PomoDoroTimerTextLabel.formatString(time: timeRemaining)
        self.state = .stopping
    }

    public func reset() {
        self.timeRemaining = 0.0
        clearTimer()
        self.displayText = "25:00"
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
            DispatchQueue.main.async {
                self.displayText = PomoDoroTimerTextLabel.formatString(time: 0)
            }
            stop()
            onFinish?()
            return
        }

        let string = PomoDoroTimerTextLabel.formatString(time: timeRemaining)
        DispatchQueue.main.async {
            self.displayText = string
        }
    }
}
