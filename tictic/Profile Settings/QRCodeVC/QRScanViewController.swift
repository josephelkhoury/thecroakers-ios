//
//  QRScanViewController.swift
//  MusicTok
//
//  Created by Mac on 16/07/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import AVFoundation
class QRScanViewController: UIViewController ,AVCaptureMetadataOutputObjectsDelegate {
  

    //MARK: Outlets
    
    
    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }

    //MARK: Variables
    
    var myUser: [User]? {didSet {}}
    var barcodeAreaView: UIView?
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var qrData: QRData? = nil {
        didSet {
            if qrData != nil {
               print("QR Code String:\(qrData?.codeString!)")
                let UserLink =  self.qrData?.codeString?.components(separatedBy: "profile/")
                let userBaselURL = UserLink?[0]
                let userID = UserLink?[1]
                print(userID)
                self.getUserDetails(userID: userID ?? "0")
              
            }
        }
    }
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK:- viewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        self.setupView()
    }
    //MARK:- Setup View
    func setupView() {
        self.cameraAccess()
      
    }
    
    //MARK:- Utility Methods
    func cameraAccess(){
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.scannerView.startScanning()
            print("User already authorized access  camera")
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    print("User access  camera")
                    self.scannerView.stopScanning()
                } else {
                    print("User access denied camera")
                    self.AccessCameraDenied()
                }
            })
        }
    }
    func AccessCameraDenied(){
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            print("Already Authorized Camera")
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                } else {
                    DispatchQueue.main.async {
                        //  initialise a pop up for using later
                        let alertController = UIAlertController(title: "Camera services are disabled", message: "Please go to Settings and turn on the camera permissions to scan QR code", preferredStyle: .alert)
                        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                            }
                        }
                        alertController.addAction(settingsAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    
    
    //MARK:- API
    func getUserDetails(userID:String){
            ApiHandler.sharedInstance.showOtherUserDetail(user_id: UserDefaults.standard.string(forKey: "userID")!, other_user_id: userID) { (isSuccess, response) in
                if isSuccess{
                    
                    print("response: ",response?.allValues)
                    if response?.value(forKey: "code") as! NSNumber == 200 {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
                        UserDefaults.standard.set(userID, forKey: "otherUserID")
                        vc.isOtherUserVisting = true
                        vc.otherUserID = userID
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }else{
                        self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))

                        print("showOtherUserDetail API:",response?.value(forKey: "msg") as Any)
                    }
                    
                }else{
                    self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                    print("showOtherUserDetail API:",response?.value(forKey: "msg") as Any)
                }
            }
        }
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension QRScanViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
        let buttonTitle = scannerView.isRunning ? "STOP" : "Scan"
    }
    func qrScanningDidFail() {
        
        self.showToast(message: "Scanning failed", font: .systemFont(ofSize: 16))
        
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        self.qrData = QRData(codeString: str)
    }
}




