
import UIKit

// MARK: Public interface of the API

/// Interface exposing a few helpers to show an overlay quickly
public final class RecordingOverlay {

    var overlay: RecordingOverlayWindow

    /// Initialize an overlay for the provided screen
    /// - Parameter screen: The screen for the overlay. Defaults to .main
    public init(screen: UIScreen = .main) {
        self.overlay = RecordingOverlayWindow(screen: screen)
        overlay.screen = screen
    }

    /// Will show the overlay if not already shown
    /// - Parameter animated: Should the overlay appear with an animation?
    public func show(animated: Bool = true) {
        overlay.update()
        guard animated, overlay.isHidden else {
            overlay.isHidden = false
            return
        }
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.timingFunction = .init(name: .easeOut)
        animation.fromValue = 0
        animation.toValue = length * 2
        overlay.layer.add(animation, forKey: "apparition")
        overlay.isHidden = false
    }

    /// Will hide the overlay if already shown.
    /// - Parameter animated: Should the overlay disappear with an animation?
    public func hide(animated: Bool = true) {
        guard animated, !overlay.isHidden else {
            overlay.isHidden = true
            return
        }
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.timingFunction = .init(name: .easeIn)
        animation.fromValue = length * 2
        animation.toValue = 0
        overlay.layer.add(animation, forKey: "disparition")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.overlay.isHidden = true
        }
    }

    /// The current color of the overlay
    public var color: UIColor {
        get {
            return overlay.color
        }
        set {
            overlay.color = newValue
        }
    }

    /// The length of the border for the overlay
    public var length: CGFloat {
        get {
            return overlay.length
        }
        set {
            overlay.length = newValue
        }
    }

    /// The animated state of the overlay
    public var isAnimated: Bool {
        get {
            return overlay.isAnimated
        }
        set {
            overlay.isAnimated = newValue
        }
    }

    /// Are the all interactions underneaf the layer enabled?
    /// If returning true, some views may still have interactions enabled depending on the whitelist.
    public var areInteractionsEnabled: Bool {
        return overlay.areInteractionsEnabled
    }

    /// Forbid any interaction to go threw the recording layer.
    /// Please note that the whitelisted views list will be overriden
    /// - Parameter view: a whitelisted view that will receive events
    public func disableInteractions(exceptFor view: UIView? = nil) {
        disableInteractions(exceptFor: [view].compactMap { $0 })
    }

    /// Forbid any interaction to go threw the recording layer.
    /// Please note that the whitelisted views list will be overriden
    /// - Parameter views: whitelisted views that will receive events
    public func disableInteractions(exceptFor views: [UIView] = []) {
        overlay.interactableViews = views
        overlay.areInteractionsEnabled = false
    }

    /// Will re-allow the interactions to go threw the recording layer.
    /// This will not erase the whitelisted views list
    public func enableInteractions() {
        overlay.areInteractionsEnabled = true
    }
}

// MARK: Private subclass of UIWindow

final class RecordingOverlayWindow: UIWindow {

    var length: CGFloat = 6 {
        didSet {
            update()
        }
    }

    var color: UIColor = .red {
        didSet {
            update()
        }
    }

    var isAnimated: Bool = true {
        didSet {
            update()
        }
    }

    var areInteractionsEnabled: Bool = true
    var interactableViews: [UIView] = []

    convenience init(screen: UIScreen) {
        self.init(frame: screen.bounds)
        self.screen = screen
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    // TODO: add session init override for iOS 13 support

    func initialize() {
        self.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)

        createAnimation()
        #if os(iOS) // ONLY do that on iOS, to prevent round corners on TVs
        if #available(iOS 11.0, *) {
            adaptCorners()
        }
        #endif
        update()
    }

    @available (iOS 11.0, *)
    @available (tvOS 11.0, *)
    func adaptCorners() {
        if safeAreaInsets.bottom > 0 {
            layer.cornerRadius = safeAreaInsets.top

            // EXCEPTION for iPhone XR that has weird corners comparing to the safeArea value
            if safeAreaInsets.top == 44 && safeAreaInsets.bottom == 34 && UIScreen.main.scale == 2 {
                layer.cornerRadius += 4
            }
        }
    }

    func createAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1, 0.7, 0.5, 1]
        animation.duration = 2
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "breathe")
    }

    @objc func update() {
        // Change the length
        frame = CGRect(x: -length, y: -length, width: screen.bounds.width + length*2, height: screen.bounds.height + length*2)
        layer.borderWidth = length * 2

        // Border color
        layer.borderColor = color.cgColor

        // And animations
        if isAnimated {
            layer.speed = 1
        } else {
            layer.speed = 0
            layer.timeOffset = 0
        }
    }

    override var isOpaque: Bool {
        get {
            return false
        }
        set {}
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if areInteractionsEnabled {
            return nil
        }

        for view in interactableViews {
            if let test = view.hitTest(view.convert(point, from: screen.fixedCoordinateSpace), with: event) {
                return test
            }
        }

        return super.hitTest(point, with: event)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if areInteractionsEnabled {
            return false
        }

        for view in interactableViews {
            if view.point(inside: view.convert(point, from: screen.fixedCoordinateSpace), with: event) {
                return true
            }
        }

        return super.point(inside: point, with: event)
    }
}
