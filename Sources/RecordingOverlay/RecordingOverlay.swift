
import UIKit

/// Interface exposing a few helpers to show an overlay quickly
public final class RecordingOverlay {

    static var overlay: RecordingOverlayWindow?

    public static func enable(color: UIColor = .red, animated: Bool = true) {
        guard let window = mainWindow else {
            return
        }

        let overlay = RecordingOverlayWindow(frame: window.frame)
        overlay.isAnimated = animated
        overlay.color = color
        overlay.isHidden = false
        self.overlay = overlay
    }

    public static func disable() {
        self.overlay?.isHidden = true
    }
}

// MARK: Private helpers

extension RecordingOverlay {
    static var mainWindow: UIWindow? {
        return UIApplication.shared.delegate?.window ?? nil
    }
}

/// Subclass of UIWindow that create a "recording overlay" effect.
/// Set isHidden to false to show ; and isHidden to true to hide.
/// Animations can be disabled, and color can be customized
/// Also, the all interactions can be disabled for the end-user by setting isInteractionsUnderneafDisabled at true
public final class RecordingOverlayWindow: UIWindow {

    var animation: CAKeyframeAnimation?
    public var isAnimated: Bool = true {
        didSet {
            update()
        }
    }
    public var color: UIColor = .red {
        didSet {
            update()
        }
    }
    public var isInteractionsUnderneafDisabled: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    @available(iOS 13.0, *)
    @available(tvOS 13.0, *)
    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        initialize()
    }

    func initialize() {
        layer.borderWidth = 6

        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1, 0.7, 0.5, 1]
        animation.duration = 2
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "breathe")
        self.animation = animation

        update()
    }

    func update() {
        layer.borderColor = color.cgColor
        if isAnimated {
            layer.speed = 1
        } else {
            layer.speed = 0
            layer.timeOffset = 0
        }
    }

    public override var isOpaque: Bool {
        get {
            return false
        }
        set {}
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isInteractionsUnderneafDisabled {
            return nil
        }
        return super.hitTest(point, with: event)
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !isInteractionsUnderneafDisabled {
            return false
        }
        return super.point(inside: point, with: event)
    }
}
