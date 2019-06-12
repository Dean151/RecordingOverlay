
import UIKit

// MARK: Public interface of the API

/// Interface exposing a few helpers to show an overlay quickly
public final class RecordingOverlay {

    static var overlay: RecordingOverlayWindow?

    /// Will add, or replace the overlay with the specified parameters
    /// - Parameter color: The color of the overlay's border. Defaults to .red
    /// - Parameter length: The length of the visible border in points. Defaults to 6.0
    /// - Parameter animated: Should the overlay have the "breathe" animation enabled. Defaults to true
    public static func add(color: UIColor = .red, length: CGFloat = 6, animated: Bool = true) {
        guard let window = mainWindow else {
            return
        }

        let overlay = RecordingOverlayWindow(frame: window.frame)
        overlay.color = color
        overlay.length = length
        overlay.isAnimated = animated

        overlay.isHidden = false
        self.overlay = overlay
    }

    /// Will remove any existing overlay, if any
    public static func remove() {
        self.overlay?.isHidden = true
        self.overlay = nil
    }

    /// The current color of the overlay
    public static var color: UIColor {
        get {
            return overlay?.color ?? .clear
        }
        set {
            overlay?.color = newValue
        }
    }

    public static var length: CGFloat {
        get {
            return overlay?.length ?? 0
        }
        set {
            overlay?.length = newValue
        }
    }

    /// The animated state of the overlay
    public static var isAnimated: Bool {
        get {
            return overlay?.isAnimated ?? false
        }
        set {
            overlay?.isAnimated = newValue
        }
    }

    /// Forbid any interaction to go threw the recording layer.
    /// - Parameter views: views that are whitelisted and will receive events
    public static func disableInteractionsUnderneaf(exceptFor views: [UIView] = []) {
        overlay?.interactableViews = views
        overlay?.isInteractableUnderneaf = false
    }

    public static func enableInteractionsUnderneaf() {
        overlay?.interactableViews = []
        overlay?.isInteractableUnderneaf = true
    }
}

// MARK: Private helpers

extension RecordingOverlay {
    static var mainWindow: UIWindow? {
        // TODO: handle window sessions for iOS 13 support

        return UIApplication.shared.delegate?.window ?? nil
    }

    static func getWindow(for view: UIView?) -> UIWindow? {
        if view == nil { return nil }
        return (view?.superview as? UIWindow?) ?? getWindow(for: view?.superview)
    }
}

// MARK: Private subclass of UIWindow

final class RecordingOverlayWindow: UIWindow {

    var borderView: UIView!
    var borderLayer: CALayer {
        return borderView.layer
    }

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

    var isInteractableUnderneaf: Bool = true
    var interactableViews: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: -6, y: -6, width: frame.width + 12, height: frame.height + 12))
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    // TODO: add session init override for iOS 13 support

    var screenBounds: CGRect {
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft, .landscapeRight:
            return CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width))
        default:
            return UIScreen.main.bounds
        }
    }

    func initialize() {
        self.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]

        self.borderView = UIView(frame: screenBounds)
        borderView.isUserInteractionEnabled = false
        borderView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        addSubview(borderView)

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
            borderLayer.cornerRadius = safeAreaInsets.top

            // EXCEPTION for iPhone XR that has weird corners comparing to the safeArea value
            if safeAreaInsets.top == 44 && safeAreaInsets.bottom == 34 && UIScreen.main.scale == 2 {
                self.borderLayer.cornerRadius += 4
            }
        }
    }

    func createAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1, 0.7, 0.5, 1]
        animation.duration = 2
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        borderLayer.add(animation, forKey: "breathe")
    }

    func update() {
        // Change the length
        frame = CGRect(x: -length, y: -length, width: screenBounds.width + length*2, height: screenBounds.height + length*2)
        borderView.frame = bounds
        borderLayer.borderWidth = length * 2

        // Border color
        borderLayer.borderColor = color.cgColor

        // And animations
        if isAnimated {
            borderLayer.speed = 1
        } else {
            borderLayer.speed = 0
            borderLayer.timeOffset = 0
        }
    }

    override var isOpaque: Bool {
        get {
            return false
        }
        set {}
    }

    func rotate(_ point: CGPoint) -> CGPoint {
        switch UIApplication.shared.statusBarOrientation {
        case .portraitUpsideDown:
            return CGPoint(
                x: screenBounds.width - point.x,
                y: screenBounds.height - point.y
            )
        case .landscapeLeft:
            return CGPoint(
                x: screenBounds.height - point.y,
                y: point.x
            )
        case .landscapeRight:
            return CGPoint(
                x: point.y,
                y: screenBounds.width - point.x
            )
        default:
            return point
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isInteractableUnderneaf {
            return nil
        }

        for view in interactableViews {
            if let test = view.hitTest(convert(rotate(point), to: view), with: event) {
                return test
            }
        }

        return super.hitTest(point, with: event)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isInteractableUnderneaf {
            return false
        }

        for view in interactableViews {
            if view.point(inside: convert(convert(rotate(point), to: view), to: view), with: event) {
                return true
            }
        }

        return super.point(inside: point, with: event)
    }
}
