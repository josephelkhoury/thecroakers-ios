//
//  SwitchAccountViewController.swift
//  MusicTok
//
//  Created by Mac on 16/07/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class SwitchAccountViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
   
    

    //MARK:- Outlets
    @IBOutlet weak var viewCustom: UIView!
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    var myswitchAccount: [switchAccount]? {didSet {}}

    //MARK:- View Will Appear
    
     override func viewWillAppear(_ animated: Bool) {
         self.changeBackgroundAni()
        self.tbl.tableFooterView = UIView()
        self.viewCustom.layer.cornerRadius =  10
     }
    
    override func viewWillDisappear(_ animated: Bool) {
         self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
     }
     
     func changeBackgroundAni() {
         UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
             self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
         }, completion:nil)
     }
    
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heightView.constant = (2 * 75) + 60
        
        if (myswitchAccount != nil && myswitchAccount?.count != 0){
            
        }
        
        
    }
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.myswitchAccount = switchAccount.readswitchAccountFromArchive()
        return self.myswitchAccount!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.myswitchAccount = switchAccount.readswitchAccountFromArchive()
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "switchAccountTableViewCell") as! switchAccountTableViewCell
        cell.lblUserName.text! = self.myswitchAccount![indexPath.row].username
        cell.lblUserName.text! = "\(self.myswitchAccount![indexPath.row].first_name) \(self.myswitchAccount![indexPath.row].last_name)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
