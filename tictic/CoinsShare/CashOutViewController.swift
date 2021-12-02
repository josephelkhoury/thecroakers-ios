//
//  CashOutViewController.swift
//  Vibez
//
//  Created by Mac on 27/10/2020.
//  Copyright © 2020 Dinosoftlabs. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class CashOutViewController: UIViewController {
    
    
    //MARK:- Outlets
    @IBOutlet weak var btnCashOut: UIButton!
    @IBOutlet weak var lblTotalWalletCoins: UILabel!
    @IBOutlet weak var lblTotalCoins: UILabel!
    @IBOutlet weak var lblTotalCash: UILabel!

    var userData = [userMVC]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var Wallet:CGFloat = 0.0
    var strprice = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getCoinValues()
        self.btnCashOut.layer.cornerRadius  = 15
       
        
        let tab = UITapGestureRecognizer(target: self, action: #selector(self.hideView(tab:)))
       
        
        self.lblTotalWalletCoins.text! =  self.userData[0].wallet
        self.lblTotalCoins.text! =  self.userData[0].wallet
    }
    
    //MARK:- Button Action
    
    @objc func hideView(tab:UITapGestureRecognizer){
    }
    
    
    @IBAction func btnCashOutAction(_ sender: Any) {
        if userData[0].wallet == "0"{
            return
        }
        self.Cash_Out_request()
    }
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    
    //MARK:-API Handler
    func getCoinValues(){
        
        AppUtility?.startLoader(view: self.view)
     
        ApiHandler.sharedInstance.showCoinWorth{ (isSuccess, response) in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                print(response)
                let dic = response as! NSDictionary
                let code = dic["code"] as! NSNumber
                if(code == 200){
                    let res =  dic.value(forKey: "msg") as! [String:Any]
                        let obj = res["CoinWorth"] as! [String:Any]
                        let price = Int((obj["price"] as! String)) as! Int
                        let Coinprice = Int(self.lblTotalWalletCoins.text!) as! Int
                       
                        self.lblTotalCash.text = "$\(price * Coinprice)"
                        self.strprice = price * Coinprice
                        
                        if self.lblTotalCash.text! == "0"{
                            self.btnCashOut.isEnabled =  false
                            self.btnCashOut.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                        }else{
                            self.btnCashOut.isEnabled =  true
                            self.btnCashOut.backgroundColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
                        }
                    
            }else{
                AppUtility?.stopLoader(view: self.view)
                print("failed: ",response as Any)
            }
        }
    }
}
    //MARK:- Get Wallet

    func Cash_Out_request(){
        AppUtility?.startLoader(view: self.view)
     
        ApiHandler.sharedInstance.coinWithDrawRequest(user_id:self.userData[0].userID,amount:self.strprice){ (isSuccess, response) in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                print(response)
                if response?.value(forKey: "code") as! NSNumber ==  201 {
                    self.alertModule(title:"Error" , msg: response?.value(forKey: "msg") as! String)
                }
            
            }else{
                AppUtility?.stopLoader(view: self.view)
                print("failed: ",response as Any)
            }
        }
    }
    
    //MARK:- Alert Controller
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func alertModuleOK(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            self.getCoinValues()
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK:- Validation Empty
    func isEmpty(_ thing : String? )->Bool {
        
        if (thing?.count == 0) {
            return true
        }
        return false;
    }
}
