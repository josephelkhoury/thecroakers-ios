//
//  ShareProfileViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import SDWebImage
import MessageUI
import Photos
import FBSDKShareKit

class ShareProfileViewController: UIViewController,MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var cvSharePlatforms: UICollectionView!
    @IBOutlet var userImage: UIImageView!
    
    var arrPlatform = [["name":"WhatsApp","img":"whatsApp1"],
                       ["name":"Message","img":"message1"],
                       ["name":"Facebook","img":"facebook1"],
                       ["name":"Messenger","img":"messenger1"],
                       ["name":"Telegram","img":"telegram1"],
                       ["name":"SMS","img":"SMS1"]]
    
    var userData = [userMVC]()
    var shareUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       print(userData[0])
        cvSharePlatforms.delegate = self
        cvSharePlatforms.dataSource = self
        
        let user = userData[0]
        let profilePic = AppUtility?.detectURL(ipString: user.userProfile_pic)
    
        userImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        userImage.sd_setImage(with: URL(string:profilePic!), placeholderImage: UIImage(named: "noUserImg"))
        
        
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension ShareProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPlatform.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "SharePlatformCVC", for: indexPath) as! SharePlatformCVC
        
        cell.imgIcon.image = UIImage(named: "\(arrPlatform[indexPath.row]["img"] ?? "SMS")")
        cell.lblName.text = arrPlatform[indexPath.row]["name"]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch arrPlatform[indexPath.row]["name"] {
       
        case "WhatsApp":
            print("Whatsapp Tapped")
            shareOnWhatsapp()
        case "SMS":
            shareOnSMS()
            print("sms Tapped")
      
        case "waStatus":
            print("waStatus Tapped")
            shareOnWhatsapp()
        case "insta":
            print("insta Tapped")
            shareOnInsta()
        case "Facebook":
            print("fb Tapped")
            shareTextOnFaceBook()
        case "Telegram":
            print("Telegram")
        default:
            print("DEFAULT")
        }
    }
    //    MARK:- FB SETUPS
    func shareTextOnFaceBook() {
        let shareContent = ShareLinkContent()
        shareContent.contentURL = URL.init(string: self.shareUrl)!//your link
        shareContent.quote = "The Croakers APP"
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    //    MARK:- TWITTER SETUPS
    func shareOnTwitter() {
        let tweetText = "The Croakers APP\n"
        let tweetUrl = self.shareUrl
        
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)"
        
        // encode a space to %20 for example
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        // cast to an url
        let url = URL(string: escapedShareString)
        
        // open in safari
        //        UIApplication.shared.openURL(url!)
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
    func shareOnInsta() {
        //let videoImageUrl = "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4"
        
        //        let  sv = HomeViewController.displaySpinner(onView: self.view)
        //AppUtility?.startLoader(view: self.view)
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: self.shareUrl),
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
                                    
                                    //                                    HomeViewController.removeSpinner(spinner: sv)
                                    AppUtility?.stopLoader(view: self.view)
                                } else {
                                    
                                    let urlStr = "https://itunes.apple.com/in/app/instagram/id389801252?mt=8"
                                    if #available(iOS 10.0, *) {
                                        UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                                        //                                        HomeViewController.removeSpinner(spinner: sv)
                                        AppUtility?.stopLoader(view: self.view)
                                    } else {
                                        UIApplication.shared.openURL(URL(string: urlStr)!)
                                        //                                        HomeViewController.removeSpinner(spinner: sv)
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
    //    MARK:- SMS SETUP
    
    func shareOnSMS() {
        let msg = self.shareUrl
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = msg
            //                controller.recipients = [phoneNumberTextField.text!]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
        print("SMS SENT")
    }
    
    func alertModule(title:String,msg:String) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
