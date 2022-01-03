//
//  ForgotPasswordViewController.swift
//  TheCroakers
//
//  Created by Joseph El Khoury on 1/3/22.
//  Copyright © 2022 Joseph El Khoury. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        if txtEmail.text == "" {
            self.showToast(message: "Please fill your email address", font: .systemFont(ofSize: 12))
            return
        }
        
        let deviceID = UserDefaults.standard.string(forKey: "deviceID")
        AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.forgotPassword(email: txtEmail.text!, device_id: deviceID!) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let vc = self.storyboard?.instantiateViewController(identifier: "EmailTokenVerificationVC") as! EmailTokenVerificationViewController
                    vc.email = self.txtEmail.text
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                }
            } else {
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
            }
        }
    }
    
    @IBAction func btnCross(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
