//
//  DeleteAccountViewController.swift
//  MusicTok
//
//  Created by Mac on 15/07/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class DeleteAccountViewController: UIViewController {
    
    //MARK:- Outlets

    @IBOutlet weak var lblTitleText:UILabel!
    @IBOutlet weak var lblText:UILabel!
    var myUser:[User]? {didSet{}}
    let textDescription = ["If you delete your account:","Your will no longer be able to log in to The Croakers with that account.","Your will lose to access to any videos you have posted."," Your will no able to get refund on any item you have purchased."," Information that is not stored in your account, such as chat message, may still be visible to others.","Your account will be deactivated for 30 days. During deactivation, your account wont\'t be visible to public. After 30 days, your account will be then deleted permanently.","Do you want to continue? "]
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myUser = User.readUserFromArchive()
        self.lblTitleText.text! = "Delete Account\n\((self.myUser?[0].username)!)"
        lblText.attributedText = add(stringList: textDescription, font: lblText.font, bullet: "")
    
    }
    
    //MARK:- Button Action
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnContinue(_ sender: Any) {
        self.DeleteAccount()
    }
    
    //MARK:- API Handler
    
    func DeleteAccount(){
        self.myUser = User.readUserFromArchive()
        //AppUtility?.startLoader(view: self.view)
        ApiHandler.sharedInstance.DeleteAccount(user_id: (self.myUser?[0].id)!) { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    AppUtility?.stopLoader(view: self.view)
                    print("respone: ",response?.value(forKey: "msg") as! String)
                
                    UserDefaults.standard.set("", forKey: "userID")
                    
                } else {
                    AppUtility?.stopLoader(view: self.view)
                    self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12.0))
                }
            } else {
                AppUtility?.stopLoader(view: self.view)
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12.0))
            }
        }
    }
    
    //MARK:- NSAttributed Strings
    
    func add(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 12,
             textColor: UIColor = .gray,
             bulletColor: UIColor = .red) -> NSAttributedString {
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]
        
        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation
        
        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)
            
            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))
            
            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))
            
            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }
        
        return bulletList
    }

}
