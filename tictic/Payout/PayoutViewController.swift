//
//  PayoutViewController.swift
//  MusicTok
//
//  Created by Mac on 30/04/2021.
//  Copyright © 2021 Mac. All rights reserved.


import UIKit

class PayoutViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var tfPayout: CustomTextField!
    var user = [userMVC]()
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfPayout.text =  user[0].paypal
    }
    
    
    
    //MARK:- Button Actions

    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnUpdatePayOutEmail(_ sender: Any) {
        let vc =  storyboard?.instantiateViewController(withIdentifier: "AddPayoutViewController") as! AddPayoutViewController
        vc.user =  self.user
        vc.isUpdate =  true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnAdd(_ sender: Any) {
        
        let vc =  storyboard?.instantiateViewController(withIdentifier: "AddPayoutViewController") as! AddPayoutViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
