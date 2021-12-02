//
//  ManageAccountViewController.swift
//  MusicTok
//
//  Created by Mac on 14/07/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class ManageAccountViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
   
    
//MARK:- Outlets
    
    @IBOutlet weak var tbl: UITableView!
    var accountInformation = [["name":"Phone Number"],["name":"Password"]]
    var accountDelete = [["name":"Delete Account"]]
    var userData = [userMVC]()
    
    var myUser: [User]? {didSet {}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(userData[0].first_name)
        print(userData[0].userPhone)

    }
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "privacyAndSettingTableViewCell", for: indexPath) as! privacyAndSettingTableViewCell
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.myUser = User.readUserFromArchive()
                cell.lblName.text = accountInformation[indexPath.row]["name"]
                cell.title.text = self.myUser?[0].phone
                cell.title.isHidden = false
            }else{
                cell.lblName.text = accountInformation[indexPath.row]["name"]
                cell.title.isHidden = true
            }
           
        }else{
            cell.lblName.text = accountDelete[indexPath.row]["name"]
            cell.title.isHidden = true
        }
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0 :
                let vc =  storyboard?.instantiateViewController(withIdentifier: "UpdatePhoneNumberViewController") as! UpdatePhoneNumberViewController
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                let vc =  storyboard?.instantiateViewController(withIdentifier: "UpdatePasswordViewController") as! UpdatePasswordViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            print("Remove Account")
            let vc =  storyboard?.instantiateViewController(withIdentifier: "DeleteAccountViewController") as! DeleteAccountViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0 {
            return 35
        }else {
            return 35
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width  , height: 35))
        if #available(iOS 13.0, *) {
            headerView.backgroundColor = .systemBackground
        } else {
            headerView.backgroundColor = .white
        }
        let label = UILabel()
        label.frame = CGRect.init(x: 20, y: 0, width: headerView.frame.width-10, height: headerView.frame.height)
        
        label.font =  UIFont.systemFont(ofSize: 13)
        if #available(iOS 13.0, *) {
            label.textColor = .darkGray
        } else {
            label.textColor = .black
        }
        
        headerView.addSubview(label)
        
        
        if section == 0 {
            label.text = "Account information"
            return headerView
        
        }else{
            label.text = "Account control"
            return headerView
        }
        
    }
}
