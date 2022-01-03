//
//  EmailTokenVerificationViewController.swift
//  TheCroakers
//
//  Created by Joseph El Khoury on 1/3/22.
//  Copyright © 2022 Joseph El Khoury. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class EmailTokenVerificationViewController: UIViewController {
    
    @IBOutlet weak var txtToken: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRepeatPassword: UITextField!
    
    var email:String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        if txtToken.text == "" || txtPassword.text == "" || txtRepeatPassword.text == "" {
            self.showToast(message: "All fields are mandatory", font: .systemFont(ofSize: 12))
            return
        }
        
        if txtPassword.text != txtRepeatPassword.text {
            self.showToast(message: "Passwords do not match", font: .systemFont(ofSize: 12))
            return
        }
        
        let deviceID = UserDefaults.standard.string(forKey: "deviceID")
        AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.changeForgotPassword(email: email, code: txtToken.text!, password: txtPassword.text!, device_id: deviceID!) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                }
            } else {
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
