//
//  NewSettingsPrivacyViewController.swift
//  MusicTok
//
//  Created by Mac on 29/05/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class NewSettingsPrivacyViewController: UIViewController {
    @IBOutlet weak var tblPrivacy: UITableView!
    
    var arrAccount = [["name":"Manage Account","image":"2-2"],
                      ["name":"Privacy","image":"ic_privacy"],
                      ["name":"Request Verification","image":"ic_verify_request-1"],
                      ["name":"QR Code","image":"10-10"]],
                      //["name":"Balance","image":"8-8"],
                      //["name":"Payout Setting","image":"ic_payout_setting"]
    
    var arrContentActivity = [["name":"Push Notification","image":"1-1"],
                    ["name":"App Lanuage","image":"3-3"]]
    
    
    var arrAbout = [["name":"Terms of Service","image":"iconTerms"],
                    ["name":"Privacy Policy","image":"iconPrivacy"]]
    
    var arrLogin = [["name":"Log Out","image":"iconLogout"]]
    
    
    var userData = [userMVC]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.userData[0].first_name)
        tblPrivacy.delegate = self
        tblPrivacy.dataSource = self

    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension NewSettingsPrivacyViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrAccount.count
        } else if section == 1 {
            return arrContentActivity.count
        } else if section == 2 {
            return arrAbout.count
        } else {
            return arrLogin.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "privacyAndSettingTableViewCell", for: indexPath) as! privacyAndSettingTableViewCell
        if indexPath.section == 0 {
            cell.imgIcon.image = UIImage(named: "\(arrAccount[indexPath.row]["image"] ?? "30")")
            cell.lblName.text = arrAccount[indexPath.row]["name"]
            cell.lblLanguageTitle.isHidden = true
            cell.nextArr0w.isHidden =  false
        } else if indexPath.section == 1 {
            cell.imgIcon.image = UIImage(named: "\(arrContentActivity[indexPath.row]["image"] ?? "30")")
            cell.lblName.text = arrContentActivity[indexPath.row]["name"]
            
            if indexPath.row == 1 {
                cell.lblLanguageTitle.isHidden = false
                cell.nextArr0w.isHidden =  true
            }
            if indexPath.row == 0 {
                cell.lblLanguageTitle.isHidden = true
                cell.nextArr0w.isHidden =  false
            }
        } else if indexPath.section == 2 {
            cell.imgIcon.image = UIImage(named: "\(arrAbout[indexPath.row]["image"] ?? "30")")
            cell.lblName.text = arrAbout[indexPath.row]["name"]
            cell.lblLanguageTitle.isHidden = true
            cell.nextArr0w.isHidden =  false

        } else {
            cell.imgIcon.image = UIImage(named: "\(arrLogin[indexPath.row]["image"] ?? "30")")
            cell.lblName.text = arrLogin[indexPath.row]["name"]
            cell.lblLanguageTitle.isHidden = true
            cell.nextArr0w.isHidden =  false
        }
        
        return cell
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
            label.text = "ACCOUNT"
            return headerView
        } else if section == 1 {
            label.text = "CONTENT & ACTIVITY"
            return headerView
        } else if section == 2 {
            label.text = "ABOUT"
            return headerView
        } else {
            label.text = "LOGIN"
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let FooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width  , height: 1))
        if #available(iOS 13.0, *) {
            FooterView.backgroundColor = .systemBackground
        } else {
            FooterView.backgroundColor = .white
        }
        return FooterView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                print("Manage Account")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ManageAccountViewController") as! ManageAccountViewController
                vc.hidesBottomBarWhenPushed = true
                vc.userData = self.userData
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                print("Privacy")
                let vc = storyboard?.instantiateViewController(withIdentifier: "privacySettingVC") as! privacySettingViewController
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                print("Request Verification")
                let vc = storyboard?.instantiateViewController(withIdentifier: "requestVerificationVC") as! requestVerificationViewController
                self.navigationController?.pushViewController(vc, animated: true)
            case 3:
                print("QR Code")
                let vc = storyboard?.instantiateViewController(withIdentifier: "QRCodeViewController") as! QRCodeViewController
                self.navigationController?.pushViewController(vc, animated: true)
            case 4:
                print("Balance")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyWalletVC") as! MyWalletViewController
                vc.hidesBottomBarWhenPushed = true
                vc.userData = self.userData
                self.navigationController?.pushViewController(vc, animated: true)
            case 5:
                print("Payout Setting")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PayoutViewController") as! PayoutViewController
                vc.hidesBottomBarWhenPushed = true
                vc.user = self.userData
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                print("Share profile")
                
            }
        case 1:
            switch indexPath.row {
            case 0:
                print("PushNotification Settings")
                let vc = storyboard?.instantiateViewController(withIdentifier: "pushNotiSettingsVC") as! pushNotiSettingsViewController
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                print("App Laguage")
            }
        case 2:
            switch indexPath.row {
            case 0:
                print("terms")
                let vc = storyboard?.instantiateViewController(withIdentifier: "termsCondVC") as! termsCondViewController
                vc.privacyDoc = false
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)

            default:
                print("Privay")
                let vc = storyboard?.instantiateViewController(withIdentifier: "termsCondVC") as! termsCondViewController
                vc.privacyDoc = true
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }
        default:
            switch indexPath.row {
            case 0:
                
                print("logout")
                 let alertController = UIAlertController(title: NSLocalizedString("alert_app_name", comment: ""), message: "Would you like to LOGOUT?", preferredStyle: .alert)
                 let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                     self.tabBarController?.selectedIndex = 0
                     self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                     self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.white
                     var myUser: [User]? {didSet {}}
                     myUser = User.readUserFromArchive()
                     myUser?.removeAll()
                     self.logoutUserApi()
                     self.navigationController?.popViewController(animated: true)
                 }
                 alertController.addAction(OKAction)
                 let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                     print("Cancel button tapped");
                 }
                 cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
                 alertController.addAction(cancelAction)
                 self.present(alertController, animated: true, completion:nil)
                
             default:
                  break
            }
        }
    }
    
    //MARK:- API Handler
    
    func logoutUserApi() {
        let userID = UserDefaults.standard.string(forKey: "userID")
        print("user id: ",userID as Any)
        AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.logout(user_id: userID! ) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    print(response?.value(forKey: "msg") as Any)
                    UserDefaults.standard.set("", forKey: "userID")
                } else {
                    print("logout API:",response?.value(forKey: "msg") as! String)
                }
            } else {
                print("logout API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
}
