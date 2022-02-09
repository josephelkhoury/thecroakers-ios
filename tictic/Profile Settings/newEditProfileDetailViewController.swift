//
//  newEditProfileDetailViewController.swift
//  MusicTok
//
//  Created by Mac on 16/06/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class newEditProfileDetailViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var btnSave : UIButton!
    @IBOutlet weak var txtField : UITextField!
    @IBOutlet weak var lblCounts : UILabel!
    @IBOutlet weak var lblTitle : UILabel!

    var userData = [userMVC]()
    var type : Int!
    var myUser:[User]?{didSet{}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtField.delegate = self
        self.txtField.becomeFirstResponder()
        
        self.setBottomBorder()
        self.setup()
    }
    
    func setup() {
        let userObj = userData[0]
        switch type {
        case 0:
            print("Firstname")
            self.lblTitle.text = "Firstname"
            self.txtField.text = userObj.first_name
        case 1:
            print("Lastname")
            self.lblTitle.text = "Lastname"
            self.txtField.text = userObj.last_name
        case 2:
            print("Username")
            self.lblTitle.text = "Username"
            self.txtField.text = userObj.username
        case 3:
            print("Bio")
            self.lblTitle.text = "Bio"
            self.txtField.text = userObj.bio
        case 4:
            print("Web")
            self.lblTitle.text = "Website"
            self.txtField.text = userObj.website
        default:
            print("default")
        }
    }
    
    func setBottomBorder() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: txtField.frame.height - 1, width: txtField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        txtField.borderStyle = UITextField.BorderStyle.none
        txtField.layer.addSublayer(bottomLine)
    }
    
    @IBAction func btnCancelPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSavePressed(_ sender: UIButton) {
        addProfileDataAPI()
    }
    
    func addProfileDataAPI() {
        let userObj = userData[0]
        
        var username = userObj.username
        var firstName = userObj.first_name
        var lastName = userObj.last_name
        let userPhone = userObj.userPhone
        let userID = UserDefaults.standard.string(forKey: "userID")!
        var web = userObj.website
        var bio = userObj.bio
        let gender = userObj.gender
        
        switch type {
        case 0:
            print("Firstname")
            firstName = txtField.text!
        case 1:
            print("Lastname")
            lastName = txtField.text!
        case 2:
            print("Username")
            guard (AppUtility?.validateUsername(str: txtField.text!)) == true else {
                self.showToast(message: "Username must be between 4 and 20 characters.", font: .systemFont(ofSize: 12))
                return
            }
            username = txtField.text!
        case 3:
            print("Bio")
            bio = txtField.text!
        case 4:
            print("web")
            web = txtField.text!
        default:
            print("default")
        }
        
        AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.editProfile(username: username, user_id: userID, first_name: firstName, last_name: lastName, gender: gender, website: web, bio: bio, phone: userPhone) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    self.showToast(message: "Profile Updated", font: .systemFont(ofSize: 12))
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: newProfileViewController.self) {
                            _ =  self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                } else {
                    self.showToast(message: "Unable To Update", font: .systemFont(ofSize: 12))
                    print("!200: ",response as Any)
                }
            }
        }
    }
}
