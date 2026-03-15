//
//  PomoDoroTimerView.swift
//  PockitPomodoro
//

import Cocoa
import SnapKit
import PockKit

private let kDurationIndexKey = "pockitpomodoro.durationIndex"

public class PomoDoroTimerView: NSView {

    public var didTap: (() -> Void)?
    public var didLongPress: (() -> Void)?

    private let durations: [Int] = [10, 20, 30]

    // Persist selected duration across reloads
    private var durationIndex: Int {
        get { UserDefaults.standard.integer(forKey: kDurationIndexKey) }
        set { UserDefaults.standard.set(newValue, forKey: kDurationIndexKey) }
    }
    private var selectedMinutes: Int { durations[min(durationIndex, durations.count - 1)] }

    public let imageView: NSImageView = {
        let iv = NSImageView(frame: .zero)
        iv.wantsLayer = true
        iv.layer?.backgroundColor = .clear
        iv.imageScaling = .scaleProportionallyDown
        return iv
    }()

    public let titleView: PomoDoroTimerTextLabel = {
        PomoDoroTimerTextLabel(frame: .zero)
    }()

    public var isHighlighted = false {
        didSet {
            layer?.backgroundColor = isHighlighted
                ? NSColor.touchBarBackgroundColor.highlight(withLevel: 0.25)?.cgColor
                : NSColor.touchBarBackgroundColor.cgColor
        }
    }

    public required init() {
        super.init(frame: .zero)

        wantsLayer = true
        layer?.cornerRadius = 5
        layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor

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

        // Restore persisted timer state (survives screen-sleep / Touch Bar reinit)
        if titleView.restoreIfNeeded() {
            // Timer was running — restore running UI
            imageView.image = NSImage(systemSymbolName: "stop.circle.fill", accessibilityDescription: nil)
        } else {
            // No active timer — show idle
            setIdleState()
        }

        let tapGesture = NSClickGestureRecognizer()
        tapGesture.target = self
        tapGesture.action = #selector(tap)
        tapGesture.allowedTouchTypes = .direct
        addGestureRecognizer(tapGesture)

        let longPressGesture = NSPressGestureRecognizer()
        longPressGesture.target = self
        longPressGesture.action = #selector(longPress)
        longPressGesture.allowedTouchTypes = .direct
        addGestureRecognizer(longPressGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - State

    private func setIdleState() {
        imageView.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
        titleView.showIdleDuration(minutes: selectedMinutes)
    }

    func start() {
        titleView.start(minutes: selectedMinutes)
        imageView.image = NSImage(systemSymbolName: "stop.circle.fill", accessibilityDescription: nil)
    }

    func stop() {
        titleView.stop()
        setIdleState()
    }

    private func handleFinished() {
        setIdleState()
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                NSSound.beep()
            }
        }
    }

    // MARK: - Gestures

    @objc func tap(_ sender: NSGestureRecognizer?) {
        if titleView.isRunning {
            stop()
        } else {
            start()
        }
        layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor
        didTap?()
    }

    @objc func longPress(_ sender: NSGestureRecognizer?) {
        guard let gesture = sender, gesture.state == .began else { return }
        if titleView.isRunning {
            stop()
        } else {
            durationIndex = (durationIndex + 1) % durations.count
            setIdleState()
        }
        layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor
        didLongPress?()
    }

    override public func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)
        isHighlighted = true
    }

    override public func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)
        isHighlighted = false
    }
}
