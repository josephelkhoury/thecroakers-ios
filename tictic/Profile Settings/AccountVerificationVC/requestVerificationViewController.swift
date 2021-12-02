//
//  requestVerificationViewController.swift
//  TIK TIK
//
//  Created by Mac on 15/07/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class requestVerificationViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var detailText: UILabel!
    var imgData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailText.text = "A verification badge is check that appears next to an account name to indicate that the account is the authentic presence of notable public figure, celebrity, global brand or entity it represents. \n\nSubmitting a requeset for verification does not guarantee that your account will be verified"
    }
    
    @IBAction func btnSelectImageAction(_ sender: Any) {
        ImagePickerManager().pickImage(self){ image in
            self.imgData = (image.jpegData(compressionQuality: 0.1)?.base64EncodedString())!
            print("profilePicData: ",self.imgData)
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        print("pressed")
    }
    @IBAction func btnSend(_ sender: Any) {
        if imgData != ""{
            verificationAPI()
        }else{
            self.showToast(message: "Photo is Missing", font: .systemFont(ofSize: 12))
        }
    }
    
    func verificationAPI(){
        AppUtility?.startLoader(view: self.view)

        ApiHandler.sharedInstance.userVerificationRequest(user_id: UserDefaults.standard.string(forKey: "userID")!, attachment: ["file_data":self.imgData]) { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200{
                    AppUtility?.stopLoader(view: self.view)
                    self.showToast(message: "Request Submitted", font: .systemFont(ofSize: 12))
                    sleep(1)
                    self.navigationController?.popViewController(animated: true)
                    print("response: ",response)
                }else{
                    AppUtility?.stopLoader(view: self.view)
                    self.showToast(message: "Something Went Wrong", font: .systemFont(ofSize: 12))

                    print("response: ",response)
                }

            }
        }
    }
}
