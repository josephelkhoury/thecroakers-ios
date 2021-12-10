//
//  shareViewController.swift
//  TIK TIK
//
//  Created by Mac on 07/09/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import FBSDKShareKit
//import TwitterKit 
import MessageUI
import Photos
import SDWebImage
import Firebase

class shareViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var share1CV: UICollectionView!
    @IBOutlet weak var share2CV: UICollectionView!
    @IBOutlet weak var collectionViewfollowingUser: UICollectionView!
    @IBOutlet weak var viewFollowingUser: UIView!
    @IBOutlet weak var heightViewFollowingUser: NSLayoutConstraint!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    
    var myUser:[User]? {didSet{}}
    
    let share1Arr = ["copy","wa","sms","twitter","waStatus","insta","fb","other"]
    let share2Arr = ["saveVideo","report","addFav"]
    
    var objToShare = [String]()
    var currentVideoUrl = ""
    var videoID = ""
    var currentVideoID = ""
    var followingList = [[String:Any]]()
    var shareUrl = ""
    var userID = ""
    var arrVideo: videoMainMVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myUser = User.readUserFromArchive()
        
        userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        
        if userID != "" {
            self.showFollowingUser()
        } else {
            self.viewFollowingUser.isHidden =  true
            self.heightViewFollowingUser.constant = 0
            self.heightView.constant = 300
        }
        
        print("objToShare: ",objToShare[0])
        print("var currentVideoUrl = ",currentVideoUrl)
        print("video id = ",videoID)
        objToShare.removeAll()
        shareUrl = BASE_URL+"?"+randomString(length: 3)+videoID+randomString(length: 3)
        objToShare.append(shareUrl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(shareViewController.dismissVCnoti(notification:)), name: Notification.Name("dismissVCnoti"), object: nil)
    }
    
    @objc func dismissVCnoti(notification: Notification) {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == share1CV {
            return share1Arr.count
        } else if collectionView == collectionViewfollowingUser {
            return self.followingList.count
        } else {
            return share2Arr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == share1CV {
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "share1CVC", for: indexPath) as! share1CollectionViewCell
            cell1.imgView.image = UIImage(named: share1Arr[indexPath.row])
            return cell1
            
        } else if collectionView == collectionViewfollowingUser {
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "share1CVC", for: indexPath) as! share1CollectionViewCell
            cell1.imgView.layer.cornerRadius = 25
            let obj  =  self.followingList[indexPath.row]["FollowingList"] as! [String:Any]
            let profilePic = AppUtility?.detectURL(ipString: obj["profile_pic"] as? String ?? "")
            //cell1.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell1.imgView.sd_setImage(with: URL(string:profilePic!), placeholderImage: UIImage(named: "noUserImg"))
            cell1.lblTitle.text! = obj ["username"] as? String ?? "unknown"
            return cell1
        } else {
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "share2CVC", for: indexPath) as! share2CollectionViewCell
            cell2.imgView.image = UIImage(named: share2Arr[indexPath.row])
            return cell2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == share1CV {
            
            switch share1Arr[indexPath.row] {
            
            case "copy":
                print("Copy Tapped")
                copyLink()
            
            case "wa":
                print("Whatsapp Tapped")
                shareOnWhatsapp()
            
            case "sms":
                print("sms Tapped")
                shareOnSMS()
            
            case "twitter":
                print("twitter Tapped")
                shareOnTwitter()
            
            case "waStatus":
                print("waStatus Tapped")
                shareOnWhatsapp()
            
            case "insta":
                print("insta Tapped")
                shareOnInsta()
                
            case "fb":
                print("fb Tapped")
                shareTextOnFaceBook()
            
            case "other":
                print("other Tapped")
                otherFunc()
            
            default:
                print("DEFAULT")
            }
        } else if collectionView == collectionViewfollowingUser {
            let obj  =  self.followingList[indexPath.row]["FollowingList"] as! [String:Any]
            if let senderName = myUser![0].username, let receiverID = obj["id"] as? String {
                let senderID = userID
                let receiverProfile = (AppUtility?.detectURL(ipString:obj["profile_pic"] as! String))!
                let receiverName = obj["username"] as! String
                let time = Date().millisecondsSince1970
                ChatDBhandler.shared.sendMessage(senderID: senderID, receiverID: receiverID, senderName: senderName, message: self.shareUrl, seen: false, time: time, type: "text") { (isSuccess) in
                    if isSuccess == true {
                        self.showToast(message: "Message sent", font: .systemFont(ofSize: 12))
                    }
                }
                ChatDBhandler.shared.userChatInbox(senderID: senderID, receiverID: receiverID, image: receiverProfile, name: receiverName, message: self.shareUrl, type: "text", seen: false, timestamp: time, date: "\(time)", status: "1") { (result) in
                    if result == true {
                        ApiHandler.sharedInstance.sendMessageNotification(senderID: senderID, receiverID: receiverID, msg: self.shareUrl, title: senderName) { (isSuccess, response) in
                        }
                    }
                }
            }
        } else {
            switch share2Arr[indexPath.row] {
        
            case "saveVideo":
                print("saveVideo Tap")
                let fileUrl = URL.init(fileURLWithPath: (AppUtility?.detectURL(ipString: currentVideoUrl))!)
                AppUtility?.startLoader(view: self.view)
                getVideoDownloadURL()
            
            case "report":
                /*
                 //                alertModule(title: "Report", msg: "Report is under review")
                 if(UserDefaults.standard.string(forKey: "userID") == "" || UserDefaults.standard.string(forKey: "userID") == nil){
                 
                 //                    self.alertModule(title:"MusicTok", msg: "Please login from Profile to Report")
                 let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
                 navController.navigationBar.isHidden = true
                 navController.modalPresentationStyle = .overFullScreen
                 
                 self.present(navController, animated: true, completion: nil)
                 
                 }
                 else
                 {
                 let alertController = UIAlertController(title: "REPORT", message: "Enter the details of Report", preferredStyle: .alert)
                 
                 alertController.addTextField { (textField : UITextField!) -> Void in
                 textField.placeholder = "Report Title"
                 }
                 
                 let reportAction = UIAlertAction(title: "Report", style: .default, handler: { alert -> Void in
                 let firstTextField = alertController.textFields![0] as UITextField
                 let secondTextField = alertController.textFields![1] as UITextField
                 
                 print("fst txt: ",firstTextField)
                 print("scnd txt: ",secondTextField.text)
                 
                 guard let text = secondTextField.text, !text.isEmpty else {
                 self.alertModule(title: "Invalid Information", msg: "Please fill the reason section")
                 return
                 }
                 self.reportVideo(reportReason: text)
                 })
                 
                 let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
                 
                 alertController.addTextField { (textField : UITextField!) -> Void in
                 textField.placeholder = "Reason"
                 }
                 
                 
                 alertController.addAction(cancelAction)
                 alertController.addAction(reportAction)
                 
                 self.present(alertController, animated: true, completion: nil)
                 
                 }
                 */
                
                if (UserDefaults.standard.string(forKey: "userID") == "" || UserDefaults.standard.string(forKey: "userID") == nil) {
                    
                    let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
                    navController.navigationBar.isHidden = true
                    navController.modalPresentationStyle = .overFullScreen
                    self.present(navController, animated: true, completion: nil)
                    
                } else {
                    let vc = storyboard?.instantiateViewController(withIdentifier: "reportVC") as! reportViewController
                    vc.modalPresentationStyle = .overFullScreen
                    vc.videoID = self.videoID
                    present(vc, animated: true, completion: nil)
                }
            
            case "addFav":
                if (UserDefaults.standard.string(forKey: "userID") == "" || UserDefaults.standard.string(forKey: "userID") == nil) {
                    
                    let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
                    navController.navigationBar.isHidden = true
                    navController.modalPresentationStyle = .overFullScreen
                    self.present(navController, animated: true, completion: nil)
                    
                } else {
                    self.addFavAPI()
                }
            
            /*case "duet":
                if (UserDefaults.standard.string(forKey: "userID") == "" || UserDefaults.standard.string(forKey: "userID") == nil) {
                    
                    let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
                    navController.navigationBar.isHidden = true
                    navController.modalPresentationStyle = .overFullScreen
                    self.present(navController, animated: true, completion: nil)
                } else {
                    let vc = storyboard?.instantiateViewController(withIdentifier: "actionMediaVC") as! actionMediaViewController
                    vc.main_video_id = self.videoID
                    vc.modalPresentationStyle = .overFullScreen
                    present(vc, animated: true, completion: nil)
                }*/
           
            default:
                print("default")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionViewfollowingUser {
            return CGSize(width: 80, height: 80)
        } else {
            return CGSize(width: 50, height: 80)
        }
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == collectionViewfollowingUser {
            return 0
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionViewfollowingUser {
            return 0
        } else {
            return 18
        }
    }
    
    /*  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
     let noOfCellsInRow = 6
     
     let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
     
     let totalSpace = flowLayout.sectionInset.left
     + flowLayout.sectionInset.right
     + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
     
     let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
     
     return CGSize(width: size, height: size)
     }*/
    
    //    MARK:- FB SETUPS
    func shareTextOnFaceBook() {
        let shareContent = ShareLinkContent()
        shareContent.contentURL = URL.init(string: self.shareUrl)!
        shareContent.quote = "The Croakers App"
        ShareDialog(fromViewController: self, content: shareContent, delegate: self as? SharingDelegate).show()
    }
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        if sharer.shareContent.pageID != nil {
            print("FBShare: Success")
        }
    }
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("FBShare: Fail")
    }
    func sharerDidCancel(_ sharer: Sharing) {
        print("FBShare: Cancel")
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Dismiss click on anywhere on view
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:- TWITTER SETUPS
    func shareOnTwitter() {
        let tweetText = "The Croakers App\n"
        let tweetUrl = self.shareUrl
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)"
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: escapedShareString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    //  MARK:- WHATSAPP SETUPS
    
    func shareOnWhatsapp() {
        
        let msg = self.shareUrl
        
        let urlWhats = "whatsapp://send?text=\(msg)"
        
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = NSURL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
                } else {
                    print("Please install Whatsapp")
                    alertModule(title: "Whatsapp", msg: "Please install Whatsapp")
                }
            }
        }
    }
    
    //    MARK:- INSTA SETUP
    func shareOnInsta(){
        AppUtility?.startLoader(view: self.view)
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: self.currentVideoUrl),
               let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                            print("filePath",filePath)
                            
                            let fetchOptions = PHFetchOptions()
                            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                            let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                            if let lastAsset = fetchResult.firstObject {
                                let localIdentifier = lastAsset.localIdentifier
                                print("local",localIdentifier)
                                let u = "instagram://library?LocalIdentifier=" + localIdentifier
                                let url = NSURL(string: u)!
                                if UIApplication.shared.canOpenURL(url as URL) {
                                    UIApplication.shared.open(URL(string: u)!, options: [:], completionHandler: nil)
                                    AppUtility?.stopLoader(view: self.view)
                                } else {
                                    let urlStr = "https://itunes.apple.com/in/app/instagram/id389801252?mt=8"
                                    if #available(iOS 10.0, *) {
                                        UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                                        AppUtility?.stopLoader(view: self.view)
                                    } else {
                                        UIApplication.shared.openURL(URL(string: urlStr)!)
                                        AppUtility?.stopLoader(view: self.view)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    //MARK:- SMS SETUP
    func shareOnSMS(){
        let msg = self.shareUrl
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = msg
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
        print("SMS SENT")
    }
    
    //MARK:- COPY
    func copyLink() {
        UIPasteboard.general.string = self.shareUrl
        if UIPasteboard.general.string != nil {
            showToast(message: "URL Copied", font: .systemFont(ofSize: 12))
        }
    }
    
    //MARK:- OTHER
    func otherFunc() {
        let activityViewController = UIActivityViewController(activityItems: objToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.saveToCameraRoll]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK:- SAVE VIDEO SETUP
    func downloadVideo() {
        print("current url: ",currentVideoUrl)
        self.saveVideoToAlbum((AppUtility?.detectURL(ipString: currentVideoUrl))!) { (error) in
            print("err: ",error)
            if error == nil {
            }
        }
    }
    
    //MARK:- DOWNLOAD API
    func downloadAPI() {
        ApiHandler.sharedInstance.deleteWaterMarkVideo(video_url: currentVideoUrl) { (isSuccess, response) in
            if isSuccess {
                print("respone: ",response?.value(forKey: "msg"))
                
            } else {
                print("!200: ",response as Any)
            }
        }
    }
    /*
     //    MARK:- Report video func
     func reportVideo(reportReason: String){
     AppUtility?.startLoader(view: self.view)
     ApiHandler.sharedInstance.reportVideo(user_id: UserDefaults.standard.string(forKey: "userID")!, video_id: videoID, report_reason_id: "1", description: reportReason) { (isSuccess, response) in
     if isSuccess{
     AppUtility?.stopLoader(view: self.view)
     if response?.value(forKey: "code") as! NSNumber == 200 {
     self.showToast(message: "Report Under Review", font: .systemFont(ofSize: 12))
     }else{
     self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
     }
     }else{
     AppUtility?.stopLoader(view: self.view)
     }
     }
     }
     */
    func alertModule(title:String,msg:String) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func requestAuthorization(completion: @escaping ()->Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            completion()
        }
    }
    
    func saveVideoToAlbum(_ vidUrlString: String, _ completion: ((Error?) -> Void)?) {
        requestAuthorization {
            DispatchQueue.global(qos: .background).async {
                if let url = URL(string: vidUrlString),
                   let urlData = NSData(contentsOf: url) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                
                                self.downloadAPI()
                                DispatchQueue.main.async { // Correct
                                    AppUtility?.stopLoader(view: self.view)
                                    self.dismiss(animated: true)
                                }
                                
                                print("Video is saved!")
                            } else {
                                
                                self.showToast(message: error as! String, font: .systemFont(ofSize: 12))
                                AppUtility?.stopLoader(view: self.view)
                                self.dismiss(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //    MARK:- Generate a random string
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func getVideoDownloadURL(){
        ApiHandler.sharedInstance.downloadVideo(video_id: videoID) { (isSuccess, response) in
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let currentUrl =  response?.value(forKey: "msg") as! String
                    self.currentVideoUrl = (AppUtility?.detectURL(ipString: currentUrl))!
                    self.downloadVideo()
                    
                    print(response?.value(forKey: "msg"))
                    
                } else {
                    print("!2200: ",response as Any)
                }
            }
        }
    }
 
    //MARK:- API Handler
    func addFavAPI() {
        AppUtility?.startLoader(view: self.view)
        ApiHandler.sharedInstance.addVideoFavourite(video_id: videoID, user_id: UserDefaults.standard.string(forKey: "userID")!) { (isSuccess, response) in
            
            AppUtility?.stopLoader(view: self.view)
            
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    print(response?.value(forKey: "msg"))
                    
                    let msg = response?.value(forKey: "msg") as? String
                    guard msg != "unfavourite" else {
                        self.showToast(message: "UnFavourite", font: .systemFont(ofSize: 12))
                        return
                    }
                    self.showToast(message: "Added to FAVOURITE", font: .systemFont(ofSize: 12))
                } else {
                    print(response?.value(forKey: "msg"))
                }
            }
        }
    }
    func showFollowingUser() {
        AppUtility?.startLoader(view: self.view)
        self.followingList.removeAll()
        var otherUserID = UserDefaults.standard.string(forKey: "otherUserID")
        
        if otherUserID == "" {
            otherUserID = UserDefaults.standard.string(forKey: "userID")
        }
        
        ApiHandler.sharedInstance.showFollowing(user_id: UserDefaults.standard.string(forKey: "userID")!, other_user_id: otherUserID!) { (isSuccess, response) in
            
            AppUtility?.stopLoader(view: self.view)
            
            if isSuccess {
                let code = response?.value(forKey: "code") as! NSNumber
                if code == 200{
                    let msgArr = response?.value(forKey: "msg") as! [[String:Any]]
                    self.followingList = msgArr
                    self.viewFollowingUser.isHidden =  false
                    self.heightViewFollowingUser.constant = 119
                    self.heightView.constant = 420
                    
                    print("followingList count,",self.followingList.count)
                    self.collectionViewfollowingUser.reloadData()
                } else {
                    print("!200: ",response as Any)
                }
            }
        }
    }
}
