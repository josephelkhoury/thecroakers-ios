//
//  NewEditProfileViewController.swift
//  MusicTok
//
//  Created by Mac on 29/05/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class NewEditProfileViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnUsername: UIButton!
    @IBOutlet weak var btnCopyLink: UIButton!
    @IBOutlet weak var btnBio: UIButton!
    @IBOutlet weak var btnWeb: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    var myUser:[User]? {didSet{}}
    var userData = [userMVC]()
    var profilePicData = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    func setup() {
        let userObj = userData[0]
        let name = (userObj.first_name) + " " + (userObj.last_name)
        self.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.profileImage.sd_setImage(with: URL(string:(AppUtility?.detectURL(ipString: userObj.userProfile_pic))!), placeholderImage: UIImage(named:"noUserImg"))
        self.btnName.setTitle(name, for: .normal)
        self.btnUsername.setTitle(userObj.username, for: .normal)
        self.btnCopyLink.setTitle(BASE_URL+userObj.username, for: .normal)
        self.btnBio.setTitle(userObj.bio, for: .normal)
        self.btnWeb.setTitle(userObj.website, for: .normal)
    }

    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNameAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "newEditProfileDetailViewController") as! newEditProfileDetailViewController
        vc.type = 0
        vc.userData = self.userData
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnUsernameAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "newEditProfileDetailViewController") as! newEditProfileDetailViewController
        vc.type = 1
        vc.userData = self.userData
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCopyLinkAction(_ sender: Any) {
    }
    
    @IBAction func btnBioAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "newEditProfileDetailViewController") as! newEditProfileDetailViewController
        vc.type = 2
        vc.userData = self.userData
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnWebAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "newEditProfileDetailViewController") as! newEditProfileDetailViewController
        vc.type = 3
        vc.userData = self.userData
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnImageAction(_ sender: Any) {
        // Your action
        ImagePickerManager().pickImage(self){ image in
            //here is the image

            self.profilePicData = (image.jpegData(compressionQuality: 0.1)?.base64EncodedString())!
            print("profilePicData: ", self.profilePicData)
            
            self.addUserImgAPI()
        }
    }
    
    @IBAction func btnVideoAction(_ sender: Any) {
    }
    
    func addUserImgAPI() {
        AppUtility?.startLoader(view: self.view)
        ApiHandler.sharedInstance.addUserImage(user_id: UserDefaults.standard.string(forKey: "userID")!, profile_pic: ["file_data":self.profilePicData]) { (isSuccess, response) in
            if response?.value(forKey: "code") as! NSNumber == 200 {
                AppUtility?.stopLoader(view: self.view)
                let msgDict = response?.value(forKey: "msg") as! NSDictionary
                let userDict = msgDict.value(forKey: "User") as! NSDictionary
                let profImgUrl = userDict.value(forKey: "profile_pic") as! String
                
                self.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.profileImage.sd_setImage(with: URL(string:(AppUtility?.detectURL(ipString: profImgUrl))!), placeholderImage: UIImage(named:"noUserImg"))
            } else {
                AppUtility?.stopLoader(view: self.view)
                self.showToast(message: "Error Occur", font: .systemFont(ofSize: 12))
            }
        }
    }
}
