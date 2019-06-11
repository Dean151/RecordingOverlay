
import UIKit

// MARK: Public interface of the API

/// Interface exposing a few helpers to show an overlay quickly
public final class RecordingOverlay {

    static var overlay: RecordingOverlayWindow?

    /// Will add, or replace the overlay with the specified parameters
    /// - Parameter color: The color of the overlay's border. Defaults to .red
    /// - Parameter length: The length of the visible border in points. Defaults to 6.0
    /// - Parameter animated: Should the overlay have the "breathe" animation enabled. Defaults to true
    /// - Parameter interactableUnderneaf: Should the interactions be enabled under the overlay? Defaults to true
    public static func add(color: UIColor = .red, length: CGFloat = 6, animated: Bool = true, interactableUnderneaf: Bool = true) {
        guard let window = mainWindow else {
            return
        }

        let overlay = RecordingOverlayWindow(frame: window.frame)
        overlay.color = color
        overlay.length = length
        overlay.isAnimated = animated
        overlay.isInteractableUnderneaf = interactableUnderneaf

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

    /// The interaction state beneath the overlay
    public static var isInteractableUnderneaf: Bool {
        get {
            return overlay?.isInteractableUnderneaf ?? true
        }
        set {
            overlay?.isInteractableUnderneaf = newValue
        }
    }
}

// MARK: Private helpers

extension RecordingOverlay {
    static var mainWindow: UIWindow? {
        // TODO: handle window sessions

        return UIApplication.shared.delegate?.window ?? nil
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

    var isInteractableUnderneaf: Bool = true

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: -6, y: -6, width: frame.width + 12, height: frame.height + 12))
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    func initialize() {
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

            // EXCEPTION for iPhone XR that is weird
            if safeAreaInsets.top == 44 && UIScreen.main.scale == 2 && UIScreen.main.nativeBounds.size == CGSize(width: 828, height: 1792) {
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

    func update() {
        // Change the length
        self.frame = CGRect(x: -length, y: -length, width: UIScreen.main.bounds.width + length*2, height: UIScreen.main.bounds.height + length*2)
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
        if isInteractableUnderneaf {
            return nil
        }
        return super.hitTest(point, with: event)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isInteractableUnderneaf {
            return false
        }
        return super.point(inside: point, with: event)
    }
}
