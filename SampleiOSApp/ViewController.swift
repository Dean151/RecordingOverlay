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

import RecordingOverlay
import UIKit

class ViewController: UIViewController {

    let overlay = RecordingOverlay()

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var changeColorButton: UIButton!
    @IBOutlet weak var changeSizeButton: UIButton!
    @IBOutlet weak var toggleAnimationButton: UIButton!
    @IBOutlet weak var toggleInterationsButton: UIButton?
    @IBOutlet weak var removeButton: UIButton!

    var overlayRelatedButtons: [UIButton?] {
        return [changeColorButton, changeSizeButton, toggleAnimationButton, toggleInterationsButton, removeButton]
    }

    let colors: [UIColor] = [.red, .green, .blue, .orange, .magenta, .purple]
    var currentColorIndex = 0

    let sizes: [CGFloat] = [3, 6, 9]
    var currentSizeIndex = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overlayRelatedButtons.forEach { $0?.isEnabled = false }
    }

    @IBAction func addOverlay() {
        overlay.show()

        addButton.isEnabled = false
        overlayRelatedButtons.forEach { $0?.isEnabled = true }
        setNeedsFocusUpdate()
    }

    @IBAction func toggleAnimations() {
        overlay.isAnimated.toggle()
        toggleAnimationButton.setTitle(overlay.isAnimated ? "Disable animation" : "Enable animation", for: .normal)
    }

    @available (iOS 9.0, *)
    @IBAction func toggleInteractions() {
        if overlay.areInteractionsEnabled {
            overlay.disableInteractions(exceptFor: toggleInterationsButton)
        } else {
            overlay.enableInteractions()
        }
        toggleInterationsButton?.setTitle(overlay.areInteractionsEnabled ? "Disable interactions" : "Enable interactions", for: .normal)
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
        overlayRelatedButtons.forEach { $0?.isEnabled = false }
        setNeedsFocusUpdate()
    }

    #if !os(tvOS)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    #endif
}
