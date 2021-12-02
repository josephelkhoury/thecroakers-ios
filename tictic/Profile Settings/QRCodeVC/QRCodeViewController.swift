//
//  QRCodeViewController.swift
//  MusicTok
//
//  Created by Mac on 15/07/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import SDWebImage
import Photos
import AVKit
import AVFoundation

class QRCodeViewController: UIViewController {

    //MARK:-Outlets
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var viewCustom: UIView!
    @IBOutlet weak var imfSave: UIImageView!
    @IBOutlet weak var imgScan: UIImageView!
    
    
    var myUser:[User]? {didSet{}}
    
    //MARK:-ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        self.imgScan.tintColor  =  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.imfSave.tintColor  =  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.myUser = User.readUserFromArchive()
        self.userName.text! = self.myUser?[0].username ?? ""
        self.userImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.userImage.sd_setImage(with: URL(string:(AppUtility!.detectURL(ipString: (self.myUser?[0].id)                  ?? ""))), placeholderImage: UIImage(named:"noUserImg"))
        
        self.myUser = User.readUserFromArchive()
        self.userImage.layer.cornerRadius = 40
        self.userImage.clipsToBounds =  true
        self.imgQRCode.layer.cornerRadius = 5
        self.viewCustom.layer.cornerRadius = 5
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapView(tap:)))
        
        scrollView.isUserInteractionEnabled  = true
        scrollView.addGestureRecognizer(tap)
        
        print("User QRCode link:\(profileQRLink +  (self.myUser?[0].id)!)")
        
        self.imgQRCode.image = generateQRCode(from: profileQRLink +  (self.myUser?[0].id)!)
        
        
        
    }
    
    //MARK:- Tap Gersture Reconizer
    
   @objc func tapView(tap:UITapGestureRecognizer){
        self.mainView.backgroundColor  = .random
    }
    @IBAction func btnShareAction(_ sender: Any) {
//        let activityController = UIActivityViewController(activityItems: [NSLocalizedString("alert_app_name", comment: "") + "\n" + self.myUser?[0]., applicationActivities:nil)
//        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil);
//        //activityViewController.excludedActivityTypes = [.message, .airDrop,.];
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK:- Button Actions
    @IBAction func btnQRScanAction(_ sender: Any) {
        let vc =  storyboard?.instantiateViewController(withIdentifier: "QRScanViewController") as! QRScanViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        photoLibraryAvailabilityCheck()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
//MARK:- QR Code
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
}
//MARK:- Extenisons

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),green: .random(in: 0...1),blue: .random(in: 0...1),alpha: 1.0)
    }
}

extension UIImage{
    convenience init(view: UIView) {

    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: (image?.cgImage)!)

  }
}

extension QRCodeViewController{
    func photoLibraryAvailabilityCheck()
    {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            let img =  UIImage.init(view: self.viewCustom)
            CustomPhotoAlbum.sharedInstance.saveImage(image:img )
            
        }else{
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    func requestAuthorizationHandler(status: PHAuthorizationStatus)
    {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.denied || PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined
        {
            alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
            
        }
    }
    
    //Photo Library not available - Alert
    func alertToEncouragePhotoLibraryAccessWhenApplicationStarts(){
        let PhotoUnavailableAlertController = UIAlertController (title: "Photo Library Unavailable", message: "Please check  device settings doesn't allow to save photo into Gallery ", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.openURL(url as URL)
            }
        }
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        PhotoUnavailableAlertController .addAction(settingsAction)
        PhotoUnavailableAlertController .addAction(cancelAction)
        self.present(PhotoUnavailableAlertController , animated: true, completion: nil)
    }
}
  
