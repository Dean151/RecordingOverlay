//
//  ViewController.swift
//  SampleApp
//
//  Created by Thomas DURAND on 09/06/2019.
//  Copyright © 2019 Thomas DURAND. All rights reserved.
//

import RecordingOverlay
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func addOverlay() {
        RecordingOverlay.enable()
    }

    @IBAction func removeOverlay() {
        RecordingOverlay.disable()
    }
}

