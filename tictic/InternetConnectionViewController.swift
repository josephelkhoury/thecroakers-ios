//
//  InternetConnectionViewController.swift
//  GoDelivery
//
//  Created by Mac on 23/11/2020.
//

import UIKit

class InternetConnectionViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTryAgain: UIButton!
    
      
    override func viewDidLoad() {
        super.viewDidLoad()
          
        self.setupView()
    }
      
    //MARK:- SetupView
      
    func setupView() {
        self.lblTitle.text = "No internet Connection"
        self.lblDescription.text = "Make sure your wifi or mobile data is turned on."
    }
    
    @IBAction func btnRetryAction(_ sender: Any) {
    }
}
