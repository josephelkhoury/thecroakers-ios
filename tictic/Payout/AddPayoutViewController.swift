//
//  AddPayoutViewController.swift
//  MusicTok
//
//  Created by Mac on 30/04/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class AddPayoutViewController: UIViewController {

    @IBOutlet weak var tfPaypal: CustomTextField!
    @IBOutlet weak var btnAddPayout: UIButton!
    var user = [userMVC]()
    var isUpdate =  false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if isUpdate == true{
            self.btnAddPayout.setTitle("UPDATE PAYOUT", for: .normal)
            self.tfPaypal.text! =  self.user[0].paypal
            self.btnAddPayout.isUserInteractionEnabled = false
            self.btnAddPayout.backgroundColor = #colorLiteral(red: 0.7233634591, green: 0.7233806252, blue: 0.7233713269, alpha: 1)


        }else{
            self.btnAddPayout.setTitle("ADD PAYOUT", for: .normal)
            self.btnAddPayout.isUserInteractionEnabled = true
            self.btnAddPayout.backgroundColor = #colorLiteral(red: 0.7233634591, green: 0.7233806252, blue: 0.7233713269, alpha: 1)
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tfValueChanged(_ sender: Any) {
        print(self.tfPaypal.text!)
        if AppUtility!.isEmpty(self.tfPaypal.text!){
            self.btnAddPayout.backgroundColor = #colorLiteral(red: 0.7233634591, green: 0.7233806252, blue: 0.7233713269, alpha: 1)
            self.btnAddPayout.isUserInteractionEnabled = false
        }else{
            if AppUtility?.isEmail(self.tfPaypal.text!) == false {
                self.btnAddPayout.backgroundColor = #colorLiteral(red: 0.7233634591, green: 0.7233806252, blue: 0.7233713269, alpha: 1)
                self.btnAddPayout.isUserInteractionEnabled = false

            }
            self.btnAddPayout.backgroundColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
            self.btnAddPayout.isUserInteractionEnabled = true

        }
    }
    
    @IBAction func btnAddPayout(_ sender: Any) {
        self.AddPayOut()
    }
    //MARK:-API Handler
    func AddPayOut(){
        let userID = UserDefaults.standard.string(forKey: "userID")
        
        //AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.addPayout(user_id:userID!,email:self.tfPaypal.text!){ (isSuccess, response) in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                print(response)
                let dic = response as! NSDictionary
                let code = dic["code"] as! NSNumber
                if(code == 200){
                    let res =  dic.value(forKey: "msg") as! [String:Any]
                    self.alertModule(title: "Successfully", msg: "your account successfully added")
                }else{
                    AppUtility?.stopLoader(view: self.view)
                    print("failed: ",response as Any)
                }
            }
        }
    }
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: newProfileViewController.self) {
                    _ =  self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
}
