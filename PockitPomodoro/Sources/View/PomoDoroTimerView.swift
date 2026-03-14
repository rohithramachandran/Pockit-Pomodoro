//
//  PomoDoroTimerView.swift
//  PockitPomodoro
//

import Cocoa
import SnapKit
import PockKit

public enum PomodoroState {
    case idle
    case selection
    case running
}

public class PomoDoroTimerView: NSView {

    public var didTap: (() -> Void)?
    public var didLongPress: (() -> Void)?

    public var pockState: PomodoroState = .idle {
        didSet {
            updateViewState()
        }
    }

    private let stackView: NSStackView = {
        let sv = NSStackView()
        sv.orientation = .horizontal
        sv.alignment = .centerY
        sv.spacing = 8
        sv.distribution = .fillProportionally
        return sv
    }()

    public let imageView: NSImageView = {
        let imageView = NSImageView(frame: .zero)
        imageView.wantsLayer = true
        imageView.layer?.backgroundColor = .clear
        imageView.imageScaling = .scaleProportionallyDown
        imageView.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
        return imageView
    }()
    
    public let titleView: PomoDoroTimerTextLabel = {
        let titleView = PomoDoroTimerTextLabel(frame: .zero)
        return titleView
    }()

    // Selection buttons
    private let btn25 = NSButton(title: "25", target: nil, action: nil)
    private let btn15 = NSButton(title: "15", target: nil, action: nil)
    private let btn5 = NSButton(title: "5", target: nil, action: nil)
    private let btnCancel = NSButton(title: "✕", target: nil, action: nil)

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

        addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
        }

        imageView.snp.makeConstraints { maker in
            maker.width.equalTo(20)
            maker.height.equalTo(30)
        }
        
        btn25.target = self; btn25.action = #selector(start25)
        btn15.target = self; btn15.action = #selector(start15)
        btn5.target = self; btn5.action = #selector(start5)
        btnCancel.target = self; btnCancel.action = #selector(cancelSelection)
        btnCancel.isBordered = false

        let tapGesture = NSClickGestureRecognizer()
        tapGesture.target = self
        tapGesture.action = #selector(tap)
        tapGesture.allowedTouchTypes = .direct
        imageView.addGestureRecognizer(tapGesture)
        imageView.target = self
        imageView.action = #selector(tap)

        let longPressGesture = NSPressGestureRecognizer()
        longPressGesture.target = self
        longPressGesture.action = #selector(longPress)
        longPressGesture.allowedTouchTypes = .direct
        imageView.addGestureRecognizer(longPressGesture)
        
        self.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(tap)))

        titleView.onFinish = { [weak self] in
            self?.pockState = .idle
        }

        updateViewState()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateViewState() {
        stackView.views.forEach { $0.removeFromSuperview() }
        
        switch pockState {
        case .idle:
            imageView.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
            stackView.addArrangedSubview(imageView)
            titleView.reset()
        case .selection:
            imageView.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
            stackView.addArrangedSubview(imageView)
            btn25.bezelStyle = .rounded
            btn15.bezelStyle = .rounded
            btn5.bezelStyle = .rounded
            stackView.addArrangedSubview(btn25)
            stackView.addArrangedSubview(btn15)
            stackView.addArrangedSubview(btn5)
            stackView.addArrangedSubview(btnCancel)
        case .running:
            imageView.image = NSImage(systemSymbolName: "stop.circle.fill", accessibilityDescription: nil)
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(titleView)
        }
        
        // This causes the touchbar layout to recalculate the size of this view.
        self.invalidateIntrinsicContentSize()
    }

    override public var intrinsicContentSize: NSSize {
        return stackView.fittingSize
    }

    override public func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)
        self.isHighlighted = true
    }
    
    override public func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)
        self.isHighlighted = false
    }

    @objc func start25() { startTimer(minutes: 25) }
    @objc func start15() { startTimer(minutes: 15) }
    @objc func start5() { startTimer(minutes: 5) }
    @objc func cancelSelection() { pockState = .idle }

    func startTimer(minutes: Int) {
        titleView.start(minutes: minutes)
        pockState = .running
    }

    func stop() {
        titleView.stop()
        pockState = .idle
    }

    @objc
    func tap(_ sender: NSGestureRecognizer?) {
        if pockState == .running {
            stop()
        } else if pockState == .idle {
            pockState = .selection
        } else if pockState == .selection {
            pockState = .idle
        }
        self.layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor

        didTap?()
    }

    @objc
    func longPress(_ sender: NSGestureRecognizer?) {
        if pockState == .running {
            stop()
        }
        self.layer?.backgroundColor = NSColor.touchBarBackgroundColor.cgColor
        didLongPress?()
    }
}
