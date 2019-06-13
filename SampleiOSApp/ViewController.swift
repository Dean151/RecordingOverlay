//
//  ViewController.swift
//  SampleiOSApp
//
//  Created by Thomas DURAND on 11/06/2019.
//

import RecordingOverlay
import UIKit

class ViewController: UIViewController {

    let overlay = RecordingOverlay()

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var changeColorButton: UIButton!
    @IBOutlet weak var changeSizeButton: UIButton!
    @IBOutlet weak var toggleAnimationButton: UIButton!
    @IBOutlet weak var toggleInterationsButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!

    var overlayRelatedButtons: [UIButton] {
        return [changeColorButton, changeSizeButton, toggleAnimationButton, toggleInterationsButton, removeButton]
    }

    let colors: [UIColor] = [.red, .green, .blue, .orange, .magenta, .purple]
    var currentColorIndex = 0

    let sizes: [CGFloat] = [3, 6, 9]
    var currentSizeIndex = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overlayRelatedButtons.forEach { $0.isEnabled = false }
    }

    @IBAction func addOverlay() {
        overlay.show()

        addButton.isEnabled = false
        overlayRelatedButtons.forEach { $0.isEnabled = true }
        setNeedsFocusUpdate()
    }

    @IBAction func toggleAnimations() {
        overlay.isAnimated.toggle()
        toggleAnimationButton.setTitle(overlay.isAnimated ? "Disable animation" : "Enable animation", for: .normal)
    }

    @IBAction func toggleInteractions() {
        if overlay.areInteractionsEnabled {
            overlay.disableInteractions(exceptFor: toggleInterationsButton)
        } else {
            overlay.enableInteractions()
        }
        toggleInterationsButton.setTitle(overlay.areInteractionsEnabled ? "Disable interactions" : "Enable interactions", for: .normal)
    }

    @IBAction func changeColor() {
        currentColorIndex += 1
        currentColorIndex %= colors.count
        overlay.color = colors[currentColorIndex]
    }

    @IBAction func changeSize() {
        currentSizeIndex += 1
        currentSizeIndex %= sizes.count
        overlay.length = sizes[currentSizeIndex]
    }

    @IBAction func removeOverlay() {
        overlay.hide()

        addButton.isEnabled = true
        overlayRelatedButtons.forEach { $0.isEnabled = false }
        setNeedsFocusUpdate()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
