//
//  cameraViewController.swift
//  TIK TIK
//
//  Created by Mac on 20/08/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import SwiftyCam

class cameraViewController: SwiftyCamViewController,SwiftyCamViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraDelegate = self
        
        // Do any additional setup after loading the view.
    }


}
