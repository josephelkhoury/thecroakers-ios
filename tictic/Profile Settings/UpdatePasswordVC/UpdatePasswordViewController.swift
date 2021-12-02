//
//  UpdatePasswordViewController.swift
//  MusicTok
//
//  Created by Mac on 14/07/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UIViewController ,UITextFieldDelegate {
    
    @IBOutlet weak var OldpassTxtField: UITextField!
    @IBOutlet weak var NewpassTxtField: UITextField!
    @IBOutlet weak var ConfirmpassTxtField: UITextField!
    @IBOutlet weak var btnChangePassword: UIButton!
    var myUser:[User]? {didSet{}}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        btnChangePassword.backgroundColor = #colorLiteral(red: 0.9528577924, green: 0.9529947639, blue: 0.9528278708, alpha: 1)
        btnChangePassword.setTitleColor(#colorLiteral(red: 0.6437677741, green: 0.6631219387, blue: 0.6758852601, alpha: 1), for: .normal)
        btnChangePassword.isUserInteractionEnabled = false
        
        OldpassTxtField.addTarget(self, action: #selector(nameViewController.textFieldDidChange(_:)), for: .editingChanged)
        NewpassTxtField.addTarget(self, action: #selector(nameViewController.textFieldDidChange(_:)), for: .editingChanged)
        ConfirmpassTxtField.addTarget(self, action: #selector(nameViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        
        if OldpassTxtField.text!.count > 3  &&  NewpassTxtField.text!.count  > 3 && ConfirmpassTxtField.text!.count > 3{
            btnChangePassword.backgroundColor = UIColor(named: "theme")
            btnChangePassword.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            btnChangePassword.isUserInteractionEnabled = true
        }else{
            btnChangePassword.backgroundColor = #colorLiteral(red: 0.9528577924, green: 0.9529947639, blue: 0.9528278708, alpha: 1)
            btnChangePassword.setTitleColor(#colorLiteral(red: 0.6437677741, green: 0.6631219387, blue: 0.6758852601, alpha: 1), for: .normal)
            btnChangePassword.isUserInteractionEnabled = false
        }
       
    }
    
    
    @IBAction func btnNextFunc(_ sender: Any) {
        if self.OldpassTxtField.text!.isEmpty{
            self.showToast(message: "Please enter old password", font: .systemFont(ofSize: 12))
            return
        }
        if self.NewpassTxtField.text!.isEmpty{
            self.showToast(message: "Please enter new password", font: .systemFont(ofSize: 12))
            return
        }
        if self.ConfirmpassTxtField.text!.isEmpty{
            self.showToast(message: "Please enter confirm password", font: .systemFont(ofSize: 12))
            return
        }
     
        if validatePassword(NewpassTxtField.text!) == true{
            return
        }
        
        if validatePassword(ConfirmpassTxtField.text!) == true{
            return
        }
        if self.NewpassTxtField.text! != self.ConfirmpassTxtField.text!{
            self.showToast(message: "Both passwords are not same", font: .systemFont(ofSize: 12))
            return
        }
        self.UpdatePassword()
        
    }
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- API Handler
    
    func UpdatePassword(){
        self.myUser = User.readUserFromArchive()
        AppUtility?.startLoader(view: self.view)
        ApiHandler.sharedInstance.changePassword(user_id: (self.myUser?[0].id)!, old_password: self.OldpassTxtField.text!,new_password:self.NewpassTxtField.text!) { (isSuccess, response) in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: ManageAccountViewController.self) {
                            _ =  self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }

                }else{
                    AppUtility?.stopLoader(view: self.view)
                    self.alertModule(title: NSLocalizedString("alert_app_name", comment: ""), msg: response?.value(forKey: "msg") as! String)
                    
                }
            }else{
                AppUtility?.stopLoader(view: self.view)
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12.0))
            }
        }
    }
    
    
    //MARK: Alert View

    func alertModule(title:String,msg:String){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
        
    }
    //    MARK:- password regex
    func validatePassword(_ password: String) -> Bool {
        //At least 8 characters
        if password.count < 8 {
            self.showToast(message: "Password Minimum 8 Character", font: .systemFont(ofSize: 12))
            return false
        }
        
        //At least one digit
        if password.range(of: #"\d+"#, options: .regularExpression) == nil {
            self.showToast(message: "Password atleast One Digit", font: .systemFont(ofSize: 12))
            return false
        }
        
        //At least one letter
        if password.range(of: #"\p{Alphabetic}+"#, options: .regularExpression) == nil {
            
            self.showToast(message: "Password atleast one Letter", font: .systemFont(ofSize: 12))
            return false
        }
        
        //No whitespace charcters
        if password.range(of: #"\s+"#, options: .regularExpression) != nil {
            self.showToast(message: "Remove Space in password", font: .systemFont(ofSize: 12))
            
            return false
        }
        
        return true
    }
}
