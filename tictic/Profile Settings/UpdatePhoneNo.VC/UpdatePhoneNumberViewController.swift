//
//  UpdatePhoneNumberViewController.swift
//  MusicTok
//
//  Created by Mac on 14/07/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class UpdatePhoneNumberViewController: UIViewController {
    
    //MARK:- Outlets
    
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet var phoneNoTxtField: UITextField!
    @IBOutlet weak var btnSendCode: UIButton!
    var myUser: [User]? {didSet {}}
    var dialCode = "+961"
    
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    //MARK:- SetupView
    func setupView(){
    phoneNoTxtField.addTarget(self, action: #selector(phoneNoViewController.textFieldDidChange(_:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(self.countryDataNotification(_:)), name: NSNotification.Name(rawValue: "countryDataNotification"), object: nil)
        
        btnSendCode.backgroundColor = #colorLiteral(red: 0.9528577924, green: 0.9529947639, blue: 0.9528278708, alpha: 1)
        btnSendCode.setTitleColor(#colorLiteral(red: 0.6437677741, green: 0.6631219387, blue: 0.6758852601, alpha: 1), for: .normal)
        btnSendCode.isUserInteractionEnabled = false
    }
    
    @objc func countryDataNotification(_ notification: NSNotification) {
        print("countryDataNotification")
        
        if let country = notification.userInfo?["country"] as? countryMVC {
            print("notification.userInfo: ", country.name )
            let newDialCode = country.phonecode
            let shortName = country.short_name
            self.dialCode = newDialCode
            btnCountryCode.setTitle("\(shortName) \(newDialCode)", for: .normal)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let textCount = textField.text?.count
        print("change textCount: ",textCount)
        if textCount! > 6{
            btnSendCode.backgroundColor = UIColor(named: "theme")
            btnSendCode.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            btnSendCode.isUserInteractionEnabled = true
        }else{
            btnSendCode.backgroundColor = #colorLiteral(red: 0.9528577924, green: 0.9529947639, blue: 0.9528278708, alpha: 1)
            btnSendCode.setTitleColor(#colorLiteral(red: 0.6437677741, green: 0.6631219387, blue: 0.6758852601, alpha: 1), for: .normal)
            btnSendCode.isUserInteractionEnabled = false
        }
    }
    
    //MARK:- Button Action
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnCountryCode(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "countryCodeVC") as! countryCodeViewController
        present(vc, animated: true, completion: nil)
    }
    @IBAction func btnPhoneAction(_ sender: Any) {
        if phoneNoTxtField.text?.isEmpty == true{
            showToast(message: "please enter your phone number", font: .systemFont(ofSize: 12))
            return
        }
        self.changePhoneNumber()
    }
       
    
    //MARK:- API Handler
    
    func changePhoneNumber(){
        self.myUser = User.readUserFromArchive()
        let phoneNoNew = dialCode + phoneNoTxtField.text!
        //AppUtility?.startLoader(view: self.view)
        ApiHandler.sharedInstance.changePhoneNumber(user_id: (self.myUser?[0].id)!, phone: phoneNoNew) { (isSuccess, response) in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    if #available(iOS 12.0, *) {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "otpVC") as! otpViewController
                        vc.phoneNo = self.dialCode+self.phoneNoTxtField.text!
                        vc.isupdate =  true
                        
                        self.navigationController?.pushViewController(vc, animated: true)
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
    //MARK: TextField
    
    //MARK: Location
    
    //MARK: Google Maps
}
