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

        imageView.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)

        imageView.snp.makeConstraints { maker in
            maker.width.equalTo(20)
            maker.top.bottom.equalToSuperview()
            maker.left.equalToSuperview()
        }
        titleView.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(2)
            maker.top.bottom.right.equalToSuperview()
            maker.height.equalTo(30)
        }
        snp.makeConstraints { maker in
            maker.width.equalTo(68)
        }

        titleView.onFinish = { [weak self] in
            self?.stop()
        }

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

    func start(minutes: Int = 25) {
        titleView.start(minutes: minutes)
        imageView.image = NSImage(systemSymbolName: "stop.circle.fill", accessibilityDescription: nil)
        isRunning = true
    }

    func stop() {
        titleView.stop()
        imageView.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
        isRunning = false
    }

    func reset() {
        stop()
        titleView.reset()
    }

    @objc
    func tap(_ sender: NSGestureRecognizer?) {
        if isRunning {
            stop()
        } else {
            start(minutes: 25)
        }
        self.layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor
        didTap?()
    }

    @objc
    func longPress(_ sender: NSGestureRecognizer?) {
        reset()
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
