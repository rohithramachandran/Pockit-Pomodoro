//
//  PomoDoroTimerView.swift
//  PockitPomodoro
//

import Cocoa
import SnapKit
import PockKit

public class PomoDoroTimerView: NSView {

    public var didTap: (() -> Void)?
    public var didLongPress: (() -> Void)?

    // Available durations to cycle through
    private let durations: [Int] = [10, 20, 30]
    private var durationIndex: Int = 0
    private var selectedMinutes: Int { durations[durationIndex] }

    public let imageView: NSImageView = {
        let imageView = NSImageView(frame: .zero)
        imageView.wantsLayer = true
        imageView.layer?.backgroundColor = .clear
        imageView.imageScaling = .scaleProportionallyDown
        return imageView
    }()

    public let titleView: PomoDoroTimerTextLabel = {
        let titleView = PomoDoroTimerTextLabel(frame: .zero)
        return titleView
    }()

    public var isRunning: Bool = false

    public var isHighlighted = false {
        didSet {
            if isHighlighted {
                self.layer?.backgroundColor = NSColor.touchBarBackgroundColor.highlight(withLevel: 0.25)?.cgColor
            } else {
                self.layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor
            }
        }
    }

    public required init() {
        super.init(frame: .zero)

        self.wantsLayer = true
        self.layer?.cornerRadius = 5
        self.layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor

        addSubview(imageView)
        addSubview(titleView)

        imageView.snp.makeConstraints { maker in
            maker.width.equalTo(18)
            maker.top.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(2)
        }
        titleView.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(2)
            maker.top.bottom.right.equalToSuperview()
            maker.height.equalTo(30)
        }
        snp.makeConstraints { maker in
            maker.width.equalTo(72)
        }

        titleView.onFinish = { [weak self] in
            self?.handleFinished()
        }

        // Start by showing idle with selected duration
        setIdleState()

        let tapGesture = NSClickGestureRecognizer()
        tapGesture.target = self
        tapGesture.action = #selector(tap)
        tapGesture.allowedTouchTypes = .direct
        self.addGestureRecognizer(tapGesture)

        let longPressGesture = NSPressGestureRecognizer()
        longPressGesture.target = self
        longPressGesture.action = #selector(longPress)
        longPressGesture.allowedTouchTypes = .direct
        self.addGestureRecognizer(longPressGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - State

    private func setIdleState() {
        imageView.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
        // Show selected duration while idle so user knows what will start
        titleView.showIdleDuration(minutes: selectedMinutes)
        isRunning = false
    }

    func start() {
        titleView.start(minutes: selectedMinutes)
        imageView.image = NSImage(systemSymbolName: "stop.circle.fill", accessibilityDescription: nil)
        isRunning = true
    }

    func stop() {
        titleView.stop()
        setIdleState()
    }

    private func handleFinished() {
        setIdleState()
        // Play 3 beeps spaced 0.5s apart
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                NSSound.beep()
            }
        }
    }

    // MARK: - Gestures

    @objc
    func tap(_ sender: NSGestureRecognizer?) {
        if isRunning {
            stop()
        } else {
            start()
        }
        self.layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor
        didTap?()
    }

    @objc
    func longPress(_ sender: NSGestureRecognizer?) {
        guard let gesture = sender, gesture.state == .began else { return }
        if !isRunning {
            // Cycle to next duration
            durationIndex = (durationIndex + 1) % durations.count
            setIdleState()
        } else {
            // Long press while running = stop & reset
            stop()
        }
        self.layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor
        didLongPress?()
    }

    override public func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)
        self.isHighlighted = true
    }

    override public func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)
        self.isHighlighted = false
    }
}
