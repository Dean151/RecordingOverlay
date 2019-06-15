// MIT License
//
// Copyright (c) 2019 Thomas Durand
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

// MARK: Public interface of the API

/// Interface exposing a few helpers to show an overlay quickly
public final class RecordingOverlay {

    var autoRetainer: RecordingOverlay?
    var overlay: RecordingOverlayWindow
    weak var keyWindow: UIWindow?

    /// Initialize an overlay for the provided screen
    /// - Parameter screen: The screen for the overlay. Defaults to .main
    public init(screen: UIScreen = .main) {
        self.overlay = RecordingOverlayWindow(screen: screen)
    }

    /// Will initialiaze and show the overlay
    /// - Parameter screen: The screen for the overlay. Defaults to .main
    /// - Parameter animated: Should the overlay appear with an animation?
    @discardableResult
    public static func show(on screen: UIScreen = .main, animated: Bool = true) -> RecordingOverlay {
        return RecordingOverlay().show()
    }

    /// Will show the overlay if not already shown
    /// - Parameter animated: Should the overlay appear with an animation?
    @discardableResult
    public func show(animated: Bool = true) -> RecordingOverlay {
        overlay.update()
        autoRetainer = self
        guard animated, overlay.isHidden else {
            overlay.isHidden = false
            return self
        }
        CATransaction.begin()
        overlay.isHidden = false
        overlay.layer.add(animation(showing: true), forKey: "apparition")
        CATransaction.commit()
        return self
    }

    /// Will hide the overlay if already shown.
    /// - Parameter animated: Should the overlay disappear with an animation?
    public func hide(animated: Bool = true) {
        guard animated, !overlay.isHidden else {
            overlay.isHidden = true
            return
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock({[weak self] in
            self?.overlay.isHidden = true
            self?.autoRetainer = nil
        })
        overlay.layer.borderWidth = 0 // Make it 0 border for it stays hidden at the end
        overlay.layer.add(animation(showing: false), forKey: "disparition")
        CATransaction.commit()
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

        keyWindow = UIApplication.shared.keyWindow
        if keyWindow != nil {
            overlay.makeKey()
        }
    }

    /// Will re-allow the interactions to go threw the recording layer.
    /// This will not erase the whitelisted views list
    public func enableInteractions() {
        overlay.areInteractionsEnabled = true
        keyWindow?.makeKey()
    }
}

// MARK: Private helpers

extension RecordingOverlay {
    func animation(showing: Bool) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.timingFunction = .init(name: showing ? .easeOut : .easeIn)
        animation.fromValue = showing ? 0 : length * 2
        animation.toValue = showing ? length * 2 : 0
        return animation
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
        self.init(frame: RecordingOverlay.frame(for: screen))
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
        if RecordingOverlay.willAutorotate {
            transform = .init(rotationAngle: RecordingOverlay.rotationAngle(for: UIApplication.shared.statusBarOrientation))
        }

        // Change the length
        frame = RecordingOverlay.frame(for: screen, with: length)
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

// MARK: - Static helpers

extension RecordingOverlay {

    static var willAutorotate: Bool {
        // When it's an iPad with Storyboard, all orientations enabled, and not requiring fullscreen
        // The UIWindow will rotate on it's own.
        // We need to detect that to make sure it will have a correct window
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return false
        }

        let window = UIApplication.shared.delegate?.window ?? nil
        guard UIApplication.shared.supportedInterfaceOrientations(for: window) == .all else {
            return false
        }

        let info = Bundle.main.infoDictionary ?? [:]
        guard info["UIRequiresFullScreen"] as? Bool != true else {
            return false
        }
        guard info["UILaunchStoryboardName"] != nil else {
            return false
        }
        return true
    }

    static func frame(for screen: UIScreen, with length: CGFloat = 6) -> CGRect {
        let size = CGSize(
            width: willAutorotate ? screen.bounds.width : screen.nativeBounds.width / screen.scale,
            height: willAutorotate ? screen.bounds.height : screen.nativeBounds.height / screen.scale
        )

        return CGRect(
            x: -length,
            y: -length,
            // NativeBounds is not orientation dependant, so it's a great start
            width: size.width + length * 2,
            height: size.height + length * 2
        )
    }

    static func rotationAngle(for orientation: UIInterfaceOrientation) -> CGFloat {
        switch orientation {
        case .portraitUpsideDown:
            return .pi
        case .landscapeLeft:
            return .pi / 2
        case .landscapeRight:
            return -.pi / 2
        default:
            return 0
        }
    }
}
