//
//  actionMediaViewController.swift
//  TIK TIK
//
//  Created by Mac on 19/08/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CoreAnimator
import NextLevel
import AVFoundation
import CoreAnimator
import SnapKit
import Photos
//import Player
import GTProgressBar
import MarqueeLabel
import EFInternetIndicator
import KYShutterButton
import YPImagePicker

class actionMediaViewController: UIViewController,InternetStatusIndicable,UIActionSheetDelegate {

    var internetConnectionIndicator: InternetViewIndicator?

//    MARK:- OUTLETS
    
    @IBOutlet weak var btnRecordAni: KYShutterButton!
    
    @IBOutlet weak var HorizontalStackView: NSLayoutConstraint!
    @IBOutlet weak var progressViewOutlet: UIView!
    @IBOutlet weak var masterViewOutlet: UIView!
    
    @IBOutlet weak var previewDoneBtnsViewOutlet: UIView!
    @IBOutlet weak var uploadViewOutlet: UIView!
    
    @IBOutlet weak var videoViewOutlet: UIView!
    
    @IBOutlet weak var soundsViewOutlet: UIView!
    @IBOutlet weak var soundsLabel: MarqueeLabel!
    
    @IBOutlet weak var flipViewOutlet: UIView!
    @IBOutlet weak var speedViewOutlet: UIView!
    @IBOutlet weak var filterViewOutlet: UIView!
    @IBOutlet weak var beautyViewOutlet: UIView!
    @IBOutlet weak var timerViewOutlet: UIView!
    @IBOutlet weak var flashViewOutlet: UIView!
    
    @IBOutlet weak var btnViewAni: UIView!
    
    @IBOutlet weak var recordViewOutlet: UIView!
    
    @IBOutlet weak var flipIconImgView: UIImageView!
    @IBOutlet weak var speedIconImgView: UIImageView!
    @IBOutlet weak var filterIconImgView: UIImageView!
    @IBOutlet weak var beautyIconImgView: UIImageView!
    @IBOutlet weak var timerIconImgView: UIImageView!
    @IBOutlet weak var flashIconImgView: UIImageView!
    
    @IBOutlet weak var recordIconImgView: UIImageView!
    
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var btnDoneOutlet: UIButton!
    
    internal var closeButton: UIButton?
    
    @IBOutlet weak var masterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var masterCenterYconstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeLineView: UIView!
    internal var longPressGestureRecognizer: UILongPressGestureRecognizer?
    internal var photoTapGestureRecognizer: UITapGestureRecognizer?
    internal var focusTapGestureRecognizer: UITapGestureRecognizer?
    internal var flipDoubleTapGestureRecognizer: UITapGestureRecognizer?
    internal var singleTapRecord: UITapGestureRecognizer?
    
    internal var metadataObjectViews: [UIView]?
    
    internal var _panStartPoint: CGPoint = .zero
    internal var _panStartZoom: CGFloat = 0.0
    
    internal var focusView: FocusIndicatorView?
    
    internal var previewView: UIView?
    
    var audioPlayer : AVAudioPlayer?
    
    var speedToggleState = 1
    var flashToggleState = 1
    
    var camType = "back"
//    fileprivate var player = Player()
    
    @IBOutlet weak var progressBar: GTProgressBar!
    
    var videoLengthSec = 24.0
    var duetURL:URL!
    
    var arrVideo: videoMainMVC?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progressBar.progress = 0
//        loadAudio()
        btnDoneOutlet.isHidden = true
        self.startMonitoringInternet()
        
//        UserDefaults.standard.set("nil", forKey: "url")
        
        previewDoneBtnsViewOutlet.isHidden = true
        uploadViewOutlet.isHidden = false
        
        previewDoneBtnsViewOutlet.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        //devicesChecks()
        tapGesturesToViews()
        configCapSession()
//        previewPlayerSetup()
        
//        MARK:- AFTER JK ZOOM
        
//        NextLevel.shared.videoZoomFactor = .infinity
        NextLevel.shared.focusMode = .continuousAutoFocus
        self.focusView = FocusIndicatorView(frame: .zero)
    }

    
//    MARK:- GESTURES ON VIEWS
    private func tapGesturesToViews() {
        let flipViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.flipViewAction))
        self.flipViewOutlet.addGestureRecognizer(flipViewgesture)
        
        let speedViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.speedViewAction))
        self.speedViewOutlet.addGestureRecognizer(speedViewgesture)
        
        let filterViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.filterViewAction))
        self.filterViewOutlet.addGestureRecognizer(filterViewgesture)
        
        let beautyViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.beautyViewAction))
        self.beautyViewOutlet.addGestureRecognizer(beautyViewgesture)
        
        let timerViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.timerViewAction))
        self.timerViewOutlet.addGestureRecognizer(timerViewgesture)
        
        let flashViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.flashViewAction))
        self.flashViewOutlet.addGestureRecognizer(flashViewgesture)

        let recordViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.recordViewAction))
        self.recordViewOutlet.addGestureRecognizer(recordViewgesture)
        
        soundsViewOutlet.isUserInteractionEnabled = true
        let soundsViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.soundsViewAction))
        self.soundsViewOutlet.addGestureRecognizer(soundsViewgesture)
  
        uploadViewOutlet.isUserInteractionEnabled = true
        let uploadViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.uploadViewAction))
        self.uploadViewOutlet.addGestureRecognizer(uploadViewgesture)
        
//        MARK:- LONG PRESS GESTURE SETUP 12SEP Backup
        
        self.focusTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFocusTapGestureRecognizer(_:)))
        if let focusTapGestureRecognizer = self.focusTapGestureRecognizer {
            focusTapGestureRecognizer.delegate = self
            focusTapGestureRecognizer.numberOfTapsRequired = 1
            masterViewOutlet.addGestureRecognizer(focusTapGestureRecognizer)
        }
    }
 
//    MARK:- UIVIEWS ACTIONS
    @objc func flipViewAction(sender : UITapGestureRecognizer) {
        print("flipView tapped")
        generalBtnAni(viewName: flipIconImgView)
        let animator = CoreAnimator(view: flipIconImgView)
        animator.rotate(angle: 180).animate(t: 0.5)
    
//        self.metadataObjectViews = nil
        if let metadataObjectViews = metadataObjectViews {
            for view in metadataObjectViews {
                view.removeFromSuperview()
            }
            self.metadataObjectViews = nil
        }

        NextLevel.shared.flipCaptureDevicePosition()
    }
    
    @objc func speedViewAction(sender : UITapGestureRecognizer) {
        print("speedView tapped")
        generalBtnAni(viewName: speedIconImgView)
        if speedToggleState == 1 {
            speedToggleState = 2
            speedIconImgView.image = #imageLiteral(resourceName: "speedOffIcon")
        } else {
            speedToggleState = 1
            speedIconImgView.image = #imageLiteral(resourceName: "speedOnIcon")
        }
//        self.endCapture()
    }
    
    @objc func filterViewAction(sender : UITapGestureRecognizer) {
        print("filterView tapped")
        generalBtnAni(viewName: filterIconImgView)
    }
    
    @objc func beautyViewAction(sender : UITapGestureRecognizer) {
        print("beautyView tapped")
        generalBtnAni(viewName: beautyIconImgView)
    }
    
    @objc func timerViewAction(sender : UITapGestureRecognizer) {
        print("timerView tapped")
        generalBtnAni(viewName: timerIconImgView)
    }
    
    @objc func flashViewAction(sender : UITapGestureRecognizer) {
        print("flashView tapped")

        generalBtnAni(viewName: flashIconImgView)
        
        if flashToggleState == 1 {
            flashToggleState = 2
            flashIconImgView.image = #imageLiteral(resourceName: "flashOnIcon")
            
//            NextLevel.shared.flashMode = .on
            NextLevel.shared.flashMode = .on
            // Set torchMode
            NextLevel.shared.torchMode = .on
            
        } else {
            flashToggleState = 1
            flashIconImgView.image = #imageLiteral(resourceName: "flashOffIcon")
            NextLevel.shared.flashMode = .off
            NextLevel.shared.torchMode = .off
        }
    }
    
    @objc func recordViewAction(sender : UITapGestureRecognizer) {
        print("recordView tapped")
        
        UIView.animate(withDuration: 0.6,
        animations: {
            self.recordIconImgView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.recordIconImgView.layer.cornerRadius = 6
        },
        completion: { _ in
            print("done")
        })
    }
    
//    MARK:- SELECT AUDIO ACTION
    @objc func soundsViewAction(sender : UITapGestureRecognizer) {
        print("sounds view tapped")
        let vc = storyboard?.instantiateViewController(withIdentifier: "soundsVC") as! soundsViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
//    MARK:- ANIMATION
    func generalBtnAni(viewName:UIImageView) {
        UIView.animate(withDuration: 0.2,
        animations: {
            viewName.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            viewName.layer.cornerRadius = 6
        },
        completion: { _ in
            UIView.animate(withDuration: 0.2) {
                viewName.transform = CGAffineTransform.identity
            }
        })
    }
    
    func soundsMarqueeFunc(){
        
    }
    
//    MARK:- DEVICE CHECKS
    func devicesChecks() {
        if DeviceType.iPhoneWithHomeButton {
            print("view height ",view.frame.height)
            masterViewHeightConstraint.constant = self.view.frame.height/6.5
            masterCenterYconstraint.constant = self.view.frame.height/30
            masterViewOutlet.layoutIfNeeded()
            masterViewOutlet.layer.cornerRadius = 500

            UIApplication.shared.isStatusBarHidden = true
        }
    }
    
//    MARK:- CONFIGURE CAPture SESSION NEXTLEVEL
    
    func configCapSession() {
        self.previewView = UIView(frame: UIScreen.main.bounds)
//        let screenBounds = masterViewOutlet.bounds
//        self.previewView = UIView(frame: screenBounds)
        
        print("masterViewOutlet view height", masterViewOutlet.frame.height)
        if let previewView = self.previewView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.backgroundColor = UIColor.black
            previewView.layer.cornerRadius = 10
            NextLevel.shared.previewLayer.frame = previewView.bounds
            NextLevel.shared.focusMode = .continuousAutoFocus
            previewView.layer.addSublayer(NextLevel.shared.previewLayer)
            view.insertSubview(previewView, belowSubview: masterViewOutlet)
//            view.addSubview(previewView)
            self.previewView?.snp.makeConstraints({ (make) in
                make.center.equalTo(self.masterViewOutlet)
                make.width.height.equalTo(self.masterViewOutlet)
            })
            
            print("preview view height", previewView.frame.height)
        }

        let nextLevel = NextLevel.shared
        nextLevel.delegate = self
        nextLevel.deviceDelegate = self
        nextLevel.flashDelegate = self
        nextLevel.videoDelegate = self
        nextLevel.photoDelegate = self
        nextLevel.metadataObjectsDelegate = self
               
       // video configuration
       nextLevel.videoConfiguration.preset = AVCaptureSession.Preset.hd1280x720
       nextLevel.videoConfiguration.bitRate = 5500000
       nextLevel.videoConfiguration.maxKeyFrameInterval = 30
       nextLevel.videoConfiguration.profileLevel = AVVideoProfileLevelH264HighAutoLevel
       
    NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTimeMakeWithSeconds(videoLengthSec, preferredTimescale: 600)
       
       // audio configuration
       nextLevel.audioConfiguration.bitRate = 96000
        
       // metadata objects configuration
       nextLevel.metadataObjectTypes = [AVMetadataObject.ObjectType.face, AVMetadataObject.ObjectType.qr]
    }
//    MARK:- VIEWWILL APPEAR
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        player.asset = nil

//        self.btnDoneOutlet.isHidden = true
//        soundsViewOutlet.isUserInteractionEnabled = true
        NextLevel.shared.enableAudioInputDevice()
        configCapSession()
//        cameraAudioPermission()
//        self.loadAudio()
        //devicesChecks()
        cameraAudioPermission()
        self.audioPlayer?.stop()
        self.audioPlayer?.pause()
        self.startMonitoringInternet()
        self.crossBtn.isHidden = false
        self.btnDoneOutlet.isHidden = false
        
        switch btnRecordAni.buttonState {
        case .recording:
            btnRecordAni.buttonState = .normal
            progressBar.animateTo(progress: 0.0)
            self.crossBtn.isHidden = false
            self.btnDoneOutlet.isHidden = false
        default:
            break
        }
        
        loadAudio()
    }
    
//    MARK:- LOAD AUDIO
    func loadAudio(){
        if let url = UserDefaults.standard.string(forKey: "url"), let audioUrl = URL(string: url) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            print("destinationUrl: ",destinationUrl)
            self.duetURL = destinationUrl
            audioPlayer?.rate = 1.0;

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                print("loaded audio file")
                
                let soundName = UserDefaults.standard.string(forKey: "selectedSongName")
                
                soundsLabel.text = soundName
                soundsLabel.type = .continuous
                
            } catch {
                print("CouldNot load audio file")
            }
 
            print("audioPlayer?.duration:- ",audioPlayer?.duration)
        }
    }
    
//MARK:- VIEW DISAPPEAR
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.pause()
        NextLevel.shared.stop()
    }
    
    func cameraAudioPermission() {
        
        if NextLevel.authorizationStatus(forMediaType: AVMediaType.video) == .authorized &&
            NextLevel.authorizationStatus(forMediaType: AVMediaType.audio) == .authorized {
            do {
                try NextLevel.shared.start()
            } catch {
                print("NextLevel, failed to start camera session")
            }
        } else {
            NextLevel.requestAuthorization(forMediaType: AVMediaType.video) { (mediaType, status) in
                print("NextLevel, authorization updated for media \(mediaType) status \(status)")
                if NextLevel.authorizationStatus(forMediaType: AVMediaType.video) == .authorized &&
                    NextLevel.authorizationStatus(forMediaType: AVMediaType.audio) == .authorized {
                    do {
                        let nextLevel = NextLevel.shared
                        try nextLevel.start()
                    } catch {
                        print("NextLevel, failed to start camera session")
                    }
                } else if status == .notAuthorized {
                    // gracefully handle when audio/video is not authorized
                    print("NextLevel doesn't have authorization for audio or video")
                }
            }
            NextLevel.requestAuthorization(forMediaType: AVMediaType.audio) { (mediaType, status) in
                print("NextLevel, authorization updated for media \(mediaType) status \(status)")
                if NextLevel.authorizationStatus(forMediaType: AVMediaType.video) == .authorized &&
                    NextLevel.authorizationStatus(forMediaType: AVMediaType.audio) == .authorized {
                    do {
                        let nextLevel = NextLevel.shared
                        try nextLevel.start()
                    } catch {
                        print("NextLevel, failed to start camera session")
                    }
                } else if status == .notAuthorized {
                    // gracefully handle when audio/video is not authorized
                    print("NextLevel doesn't have authorization for audio or video")
                }
            }
        }
    }
    @IBAction func btnDone(_ sender: Any) {
        sessionDoneFunc()
    }
    
    @IBAction func btnStackViewMove(_ sender: AnyObject) {
        /*if sender.tag == 0 {
            UIView.animate(withDuration: 0.5) {
                self.HorizontalStackView.constant = 22
                self.videoLengthSec = 5.0   //sec
                self.configCapSession()
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.HorizontalStackView.constant = -26
                self.videoLengthSec = 24.0  //sec
                self.configCapSession()
                self.view.layoutIfNeeded()
            }
        }*/
    }
    
//    func sessionDoneFunc(){
//        //        let nlS =
//            if let session = NextLevel.shared.session {
//
//                //..
//
//                let ncClips = session.clips
//
////                print("session.clips",ncClips[0].url)
//                // undo
//    //            session.removeLastClip()
//
//                // various editing operations can be done using the NextLevelSession methods
//
//                // export
//                session.mergeClips(usingPreset: AVAssetExportPresetHighestQuality, completionHandler: { (url: URL?, error: Error?) in
//                    if let _ = url {
//                        print("urlseesion",url!)
////                            NextLevel.shared.previewLayer.isHidden = true
////                            self.player.url = url
////                             self.player.playFromBeginning()
////                            self.player.playbackLoops = true
//
//                        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "previewPlayerVC") as! previewPlayerViewController
//                        vc.url = url
//                        vc.modalPresentationStyle = .fullScreen
//                        self.present(vc, animated: true, completion: nil)
//                        //
//                    } else if let _ = error {
//                        //
//                        print("err",error)
//                    }
//                 })
//
//            }
//
////        self.endCapture()
//    }

    func sessionDoneFunc() {
      guard let session = NextLevel.shared.session else {
        return
      }

      session.mergeClips(usingPreset: AVAssetExportPresetMediumQuality) { [weak self] (url, error) in
        guard let _ = self, let url = url, error == nil else {
            print("error: ",error?.localizedDescription)
            self?.showToast(message: error!.localizedDescription, font: .systemFont(ofSize: 12))
          return
        }
        if self?.duetURL == nil {
            let vc =  self?.storyboard?.instantiateViewController(withIdentifier: "previewPlayerVC") as! previewPlayerViewController
            vc.url = url
            vc.arrVideo = self?.arrVideo
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        } else {
            self?.mergeVideoWithAudio(videoUrl: url, audioUrl: (self?.duetURL)!, success: { (url) in
                DispatchQueue.main.async {
                    let vc =  self?.storyboard?.instantiateViewController(withIdentifier: "previewPlayerVC") as! previewPlayerViewController
                    vc.url = url
                    vc.arrVideo = self?.arrVideo
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true, completion: nil)
                }
            }, failure: { (error) in
                self?.showToast(message: "Error with duet sound and video,pleae try again", font: .systemFont(ofSize: 12))
                print("Error to merge audio and video")
            })
        }
      
        /*let vc =  self?.storyboard?.instantiateViewController(withIdentifier: "previewPlayerVC") as! previewPlayerViewController
        vc.url = url
        vc.modalPresentationStyle = .fullScreen
        self?.present(vc, animated: true, completion: nil)*/
      }
    }
}

// MARK: - library

extension actionMediaViewController {
    
    internal func albumAssetCollection(withTitle title: String) -> PHAssetCollection? {
        let predicate = NSPredicate(format: "localizedTitle = %@", title)
        let options = PHFetchOptions()
        options.predicate = predicate
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        if result.count > 0 {
            return result.firstObject
        }
        return nil
    }
    
}

// MARK: - capture

extension actionMediaViewController {
    
    internal func startCapture() {
        
        audioPlayer?.play()
        print("audioPlayer?.currentTime:- ",audioPlayer?.currentTime)
        
//        NextLevel.shared.automaticallyConfiguresApplicationAudioSession = true
        self.photoTapGestureRecognizer?.isEnabled = false
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.recordIconImgView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (completed: Bool) in
        }
        NextLevel.shared.record()
        self.uploadViewOutlet.isHidden = true
        self.previewDoneBtnsViewOutlet.isHidden = false
    }
    
    internal func pauseCapture() {
        self.audioPlayer?.pause()
        NextLevel.shared.pause()
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.recordIconImgView?.transform = .identity

            
        }) { (completed: Bool) in
            
        }
    }
    
    internal func endCapture() {
        self.photoTapGestureRecognizer?.isEnabled = true
        self.audioPlayer?.stop()
        
        if let session = NextLevel.shared.session {

            if session.clips.count > 1 {
                session.mergeClips(usingPreset: AVAssetExportPresetHighestQuality, completionHandler: { (url: URL?, error: Error?) in
                    if let url = url {
                        
                        self.saveVideo(withURL: url)
                    } else if let _ = error {
                        print("failed to merge clips at the end of capture \(String(describing: error))")
                    }
                })
            } else if let lastClipUrl = session.lastClipUrl {
                self.saveVideo(withURL: lastClipUrl)
            } else if session.currentClipHasStarted {
                session.endClip(completionHandler: { (clip, error) in
                    if error == nil {
                        self.saveVideo(withURL: (clip?.url)!)
                    } else {
                        print("Error saving video: \(error?.localizedDescription ?? "")")
                    }
                })
            } else {
                let alertController = UIAlertController(title: "Video Capture", message: "Not enough video captured!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    internal func authorizePhotoLibaryIfNecessary() {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .restricted:
            fallthrough
        case .denied:
            let alertController = UIAlertController(title: "Oh no!", message: "Access denied.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    
                } else {
                    
                }
            })
            break
        case .authorized:
            break
        @unknown default:
            fatalError("unknown authorization type")
        }
    }
}


// MARK: - media utilities

extension actionMediaViewController {
    
    internal func saveVideo(withURL url: URL) {
        PHPhotoLibrary.shared().performChanges({
            let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle)
            if albumAssetCollection == nil {
                let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: NextLevelAlbumTitle)
                let _ = changeRequest.placeholderForCreatedAssetCollection
            }}, completionHandler: { (success1: Bool, error1: Error?) in
                if let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle) {
                    PHPhotoLibrary.shared().performChanges({
                        if let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) {
                            let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
                            let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                            assetCollectionChangeRequest?.addAssets(enumeration)
                        }
                    }, completionHandler: { (success2: Bool, error2: Error?) in
                    if success2 == true {
                        // prompt that the video has been saved
                        let alertController = UIAlertController(title: "Video Saved!", message: "Saved to the camera roll.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        // prompt that the video has been saved
                        let alertController = UIAlertController(title: "Oops!", message: "Something failed!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        })
    }
    
    internal func savePhoto(photoImage: UIImage) {
        let NextLevelAlbumTitle = "NextLevel"
        
        PHPhotoLibrary.shared().performChanges({
            
            let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle)
            if albumAssetCollection == nil {
                let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: NextLevelAlbumTitle)
                let _ = changeRequest.placeholderForCreatedAssetCollection
            }
            
        }, completionHandler: { (success1: Bool, error1: Error?) in
            
            if success1 == true {
                if let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle) {
                    PHPhotoLibrary.shared().performChanges({
                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photoImage)
                        let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
                        let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                        assetCollectionChangeRequest?.addAssets(enumeration)
                    }, completionHandler: { (success2: Bool, error2: Error?) in
                        if success2 == true {
                            let alertController = UIAlertController(title: "Photo Saved!", message: "Saved to the camera roll.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                }
            } else if let _ = error1 {
                print("failure capturing photo from video frame \(String(describing: error1))")
            }
        })
    }
}

// MARK: - UIGestureRecognizerDelegate

extension actionMediaViewController: UIGestureRecognizerDelegate {
    
    @objc internal func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.startCapture()
            self._panStartPoint = gestureRecognizer.location(in: self.view)
            self._panStartZoom = CGFloat(NextLevel.shared.videoZoomFactor)
            break
        case .changed:
            let newPoint = gestureRecognizer.location(in: self.view)
            let scale = (self._panStartPoint.y / newPoint.y)
            let newZoom = (scale * self._panStartZoom)
            NextLevel.shared.videoZoomFactor = Float(newZoom)
            break
        case .ended:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
            self.pauseCapture()
            fallthrough
        default:
            break
        }
    }
}

extension actionMediaViewController {
    
    internal func handlePhotoTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // play system camera shutter sound
        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
        NextLevel.shared.capturePhotoFromVideo()
    }
    
    @objc internal func handleFocusTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        let tapPoint = gestureRecognizer.location(in: self.previewView)
        
        if let focusView = self.focusView {
            var focusFrame = focusView.frame
            focusFrame.origin.x = CGFloat((tapPoint.x - (focusFrame.size.width * 0.5)).rounded())
            focusFrame.origin.y = CGFloat((tapPoint.y - (focusFrame.size.height * 0.5)).rounded())
            focusView.frame = focusFrame
            
            self.previewView?.addSubview(focusView)

        }
        
        let adjustedPoint = NextLevel.shared.previewLayer.captureDevicePointConverted(fromLayerPoint: tapPoint)
        NextLevel.shared.focusExposeAndAdjustWhiteBalance(atAdjustedPoint: adjustedPoint)
    }
    
    @IBAction func didTapButton(_ sender: KYShutterButton) {
        
        print("btn tapped")
        switch sender.buttonState {
        case .normal:
            sender.buttonState = .recording
            crossBtn.isHidden = true
            btnDoneOutlet.isHidden = true
            startCapture()
        case .recording:
            sender.buttonState = .normal
            crossBtn.isHidden = false
            btnDoneOutlet.isHidden = false
            pauseCapture()
        }
    }

// MARK:- ACTION SHEET FOR CROSS BUTTON
    func actionSheetFunc() {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let startOver: UIAlertAction = UIAlertAction(title: "Start over", style: .default) { action -> Void in
            switch self.btnRecordAni.buttonState {
            case .recording:
                self.btnRecordAni.buttonState = .normal
                self.crossBtn.isHidden = false
                self.btnDoneOutlet.isHidden = false
                
            default:
                break
            }
//            self.endCapture()
            self.progressBar.animateTo(progress: CGFloat(0.0))
            let session = NextLevel.shared.session
            session?.reset()
            session?.removeAllClips()
            self.loadAudio()
            
            self.soundsViewOutlet.isUserInteractionEnabled = true
            print("startOver pressed")
        }

        let discard: UIAlertAction = UIAlertAction(title: "Discard", style: .default) { action -> Void in

            switch self.btnRecordAni.buttonState {
            case .recording:
                self.btnRecordAni.buttonState = .normal
                self.crossBtn.isHidden = false
                self.btnDoneOutlet.isHidden = false
                
            default:
                break
            }
            //            self.endCapture()
            self.progressBar.animateTo(progress: CGFloat(0.0))
            let session = NextLevel.shared.session
            session?.reset()
            session?.removeAllClips()
//            self.loadAudio()
            
            self.soundsViewOutlet.isUserInteractionEnabled = true
            print("Discard Action pressed")
            self.dismiss(animated: true, completion: nil)
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        startOver.setValue(UIColor.red, forKey: "titleTextColor")      // add actions
        actionSheetController.addAction(startOver)
        actionSheetController.addAction(discard)
        actionSheetController.addAction(cancelAction)

        // present an actionSheet...
        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
    @IBAction func cross(_ sender: Any) {
        
        if progressBar.progress <= 0.0 {
            self.dismiss(animated: true, completion: nil)
        } else {
            actionSheetFunc()
        }
    }
}

// MARK: - NextLevelDelegate

extension actionMediaViewController: NextLevelDelegate {
    
    // permission
    func nextLevel(_ nextLevel: NextLevel, didUpdateAuthorizationStatus status: NextLevelAuthorizationStatus, forMediaType mediaType: AVMediaType) {
    }
    
    // configuration
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoConfiguration videoConfiguration: NextLevelVideoConfiguration) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didUpdateAudioConfiguration audioConfiguration: NextLevelAudioConfiguration) {
    }
    
    // session
    func nextLevelSessionWillStart(_ nextLevel: NextLevel) {
        print("nextLevelSessionWillStart")
    }
    
    func nextLevelSessionDidStart(_ nextLevel: NextLevel) {
        print("nextLevelSessionDidStart")
    }
    
    func nextLevelSessionDidStop(_ nextLevel: NextLevel) {
        print("nextLevelSessionDidStop")
    }
    
    // interruption
    func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel) {
    }
    
    func nextLevelSessionInterruptionEnded(_ nextLevel: NextLevel) {
    }
    
    // mode
    func nextLevelCaptureModeWillChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevelCaptureModeDidChange(_ nextLevel: NextLevel) {
    }
}

extension actionMediaViewController: NextLevelPreviewDelegate {
    
    // preview
    func nextLevelWillStartPreview(_ nextLevel: NextLevel) {
        print("nextLevelWillStartPreview")
    }
    
    func nextLevelDidStopPreview(_ nextLevel: NextLevel) {
        print("nextLevelDidStopPreview")
    }
}

extension actionMediaViewController: NextLevelDeviceDelegate {
    
    // position, orientation
    func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {
    }
    
    // format
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {
    }
    
    // aperture
    func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {
    }
    
    // lens
    func nextLevel(_ nextLevel: NextLevel, didChangeLensPosition lensPosition: Float) {
    }
    
    // focus, exposure, white balance
    func nextLevelWillStartFocus(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidStopFocus(_  nextLevel: NextLevel) {
        if let focusView = self.focusView {
            if focusView.superview != nil {
            }
        }
    }
    
    func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {
        if let focusView = self.focusView {
            if focusView.superview != nil {
            }
        }
    }
    
    func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {
    }
}

// MARK: - NextLevelFlashDelegate

extension actionMediaViewController: NextLevelFlashAndTorchDelegate {
    
    func nextLevelDidChangeFlashMode(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidChangeTorchMode(_ nextLevel: NextLevel) {
    }
    
    func nextLevelFlashActiveChanged(_ nextLevel: NextLevel) {
    
    }
    
    func nextLevelTorchActiveChanged(_ nextLevel: NextLevel) {
    }
    
    func nextLevelFlashAndTorchAvailabilityChanged(_ nextLevel: NextLevel) {
    }
}

// MARK: - NextLevelVideoDelegate

extension actionMediaViewController: NextLevelVideoDelegate {
    func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, timestamp: TimeInterval, onQueue queue: DispatchQueue) {
        "print"
    }
    
    // video zoom
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float) {
    }
    
    // video frame processing
    func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer, onQueue queue: DispatchQueue) {
    }
    
    @available(iOS 11.0, *)
    func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, onQueue queue: DispatchQueue) {
    }
    
    // enabled by isCustomContextVideoRenderingEnabled
    func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue) {
    }
    
    // video recording session
    func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession) {
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession){
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
        
        let currentProgress = (session.totalDuration.seconds / videoLengthSec).clamped(to: 0...1)
        self.progressBar.animateTo(progress: CGFloat(currentProgress)) {
            print("progress done at:- ",currentProgress)
        }
        
        if currentProgress == 0.9 {
            pauseCapture()
            btnRecordAni.buttonState = .normal
            btnDoneOutlet.isHidden = false
        }
        
        if currentProgress > 0.0 {
            soundsViewOutlet.isUserInteractionEnabled = false
        }
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteSession session: NextLevelSession) {
        pauseCapture()
        btnRecordAni.buttonState = .normal
        btnDoneOutlet.isHidden = false
    }
    
    // video frame photo
    
    func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String : Any]?) {
        
        if let dictionary = photoDict,
            let photoData = dictionary[NextLevelPhotoJPEGKey] {
            
            PHPhotoLibrary.shared().performChanges({
                let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle)
                if albumAssetCollection == nil {
                    let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: NextLevelAlbumTitle)
                    let _ = changeRequest.placeholderForCreatedAssetCollection
                }
                
            }, completionHandler: { (success1: Bool, error1: Error?) in
                
                if success1 == true {
                    if let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle) {
                        PHPhotoLibrary.shared().performChanges({
                            if let data = photoData as? Data,
                                let photoImage = UIImage(data: data) {
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photoImage)
                                let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
                                let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                                assetCollectionChangeRequest?.addAssets(enumeration)
                            }
                        }, completionHandler: { (success2: Bool, error2: Error?) in
                            if success2 == true {
                                let alertController = UIAlertController(title: "Photo Saved!", message: "Saved to the camera roll.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                } else if let _ = error1 {
                    print("failure capturing photo from video frame \(String(describing: error1))")
                }
            })
        }
    }
}

// MARK: - NextLevelPhotoDelegate

extension actionMediaViewController: NextLevelPhotoDelegate {
    
    // photo
    func nextLevel(_ nextLevel: NextLevel, willCapturePhotoWithConfiguration photoConfiguration: NextLevelPhotoConfiguration) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCapturePhotoWithConfiguration photoConfiguration: NextLevelPhotoConfiguration) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didProcessPhotoCaptureWith photoDict: [String : Any]?, photoConfiguration: NextLevelPhotoConfiguration) {
        
        if let dictionary = photoDict,
            let photoData = dictionary[NextLevelPhotoJPEGKey] {
            
            PHPhotoLibrary.shared().performChanges({
                
                let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle)
                if albumAssetCollection == nil {
                    let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: NextLevelAlbumTitle)
                    let _ = changeRequest.placeholderForCreatedAssetCollection
                }
                
            }, completionHandler: { (success1: Bool, error1: Error?) in
                
                if success1 == true {
                    if let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle) {
                        PHPhotoLibrary.shared().performChanges({
                            if let data = photoData as? Data,
                                let photoImage = UIImage(data: data) {
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photoImage)
                                let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
                                let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                                assetCollectionChangeRequest?.addAssets(enumeration)
                            }
                        }, completionHandler: { (success2: Bool, error2: Error?) in
                            if success2 == true {
                                let alertController = UIAlertController(title: "Photo Saved!", message: "Saved to the camera roll.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                } else if let _ = error1 {
                    print("failure capturing photo from video frame \(String(describing: error1))")
                }
            })
        }
    }
    
    func nextLevel(_ nextLevel: NextLevel, didProcessRawPhotoCaptureWith photoDict: [String : Any]?, photoConfiguration: NextLevelPhotoConfiguration) {
    }
    
    func nextLevelDidCompletePhotoCapture(_ nextLevel: NextLevel) {
    }
    
    @available(iOS 11.0, *)
    func nextLevel(_ nextLevel: NextLevel, didFinishProcessingPhoto photo: AVCapturePhoto) {
    }
    
}

// MARK: - KVO

private var CameraViewControllerNextLevelCurrentDeviceObserverContext = "CameraViewControllerNextLevelCurrentDeviceObserverContext"

extension actionMediaViewController {
    
    internal func addKeyValueObservers() {
        self.addObserver(self, forKeyPath: "currentDevice", options: [.new], context: &CameraViewControllerNextLevelCurrentDeviceObserverContext)
    }
    
    internal func removeKeyValueObservers() {
        self.removeObserver(self, forKeyPath: "currentDevice")
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &CameraViewControllerNextLevelCurrentDeviceObserverContext {
            //self.captureDeviceDidChange()
        }
    }
}

extension actionMediaViewController: NextLevelMetadataOutputObjectsDelegate {
    
    func metadataOutputObjects(_ nextLevel: NextLevel, didOutput metadataObjects: [AVMetadataObject]) {
        guard let previewView = self.previewView else {
            return
        }
        
        if let metadataObjectViews = metadataObjectViews {
            for view in metadataObjectViews {
                view.removeFromSuperview()
            }
            self.metadataObjectViews = nil
        }
        
        self.metadataObjectViews = metadataObjects.map { metadataObject in
            let view = UIView(frame: metadataObject.bounds)
            view.backgroundColor = UIColor.clear
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = 1
            return view
        }
        
        if let metadataObjectViews = self.metadataObjectViews {
            for view in metadataObjectViews {
                previewView.addSubview(view)
            }
        }
    }
}

//MARK:- VIDEO PICKER FROM LIBRARY
extension actionMediaViewController {

    @objc func uploadViewAction(sender : UITapGestureRecognizer) {
        print("upload pressed")
        
        var config = YPImagePickerConfiguration()
        // [Edit configuration here ...]
        // Build a picker with your configuration
        config.video.compression = AVAssetExportPresetHighestQuality
        //config.video.fileType = .mov
        config.video.recordingTimeLimit = 24.0
        config.video.libraryTimeLimit = 24.0
        config.video.minimumTimeLimit = 3.0
        config.video.trimmerMaxDuration = 24.0
        config.video.trimmerMinDuration = 3.0
        config.showsPhotoFilters = true
        config.screens = [.library, .video]
        config.library.mediaType = .video
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let video = items.singleVideo {
                print("video.fromCamera: ",video.fromCamera)
                print("video.thumbnail: ",video.thumbnail)
                print("video.url: ",video.url)
            }
            picker.dismiss(animated: true) {
                let vc =  self.storyboard?.instantiateViewController(withIdentifier: "previewPlayerVC") as! previewPlayerViewController
                
                guard let vidURL = items.singleVideo?.url else {return}
                
                vc.url = vidURL
                vc.arrVideo = self.arrVideo
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        present(picker, animated: true, completion: nil)
    }
}

extension actionMediaViewController {
    
    func mergeVideoWithAudio(videoUrl: URL,audioUrl: URL,success: @escaping ((URL) -> Void),failure: @escaping ((Error?) -> Void)) {

           let mixComposition: AVMutableComposition = AVMutableComposition()
           var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
           var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
           let totalVideoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()

           let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
           let aAudioAsset: AVAsset = AVAsset(url: audioUrl)

           if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
               mutableCompositionVideoTrack.append( videoTrack )
               mutableCompositionAudioTrack.append( audioTrack )

               if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                   do {
                       try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)

                       let videoDuration = aVideoAsset.duration
                       if CMTimeCompare(videoDuration, aAudioAsset.duration) == -1 {
                           try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                       } else if CMTimeCompare(videoDuration, aAudioAsset.duration) == 1 {
                           var currentTime = CMTime.zero
                           while true {
                               var audioDuration = aAudioAsset.duration
                               let totalDuration = CMTimeAdd(currentTime, audioDuration)
                               if CMTimeCompare(totalDuration, videoDuration) == 1 {
                                   audioDuration = CMTimeSubtract(totalDuration, videoDuration)
                               }
                               try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: currentTime)

                               currentTime = CMTimeAdd(currentTime, audioDuration)
                               if CMTimeCompare(currentTime, videoDuration) == 1 || CMTimeCompare(currentTime, videoDuration) == 0 {
                                   break
                               }
                           }
                       }
                       videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform

                   } catch {
                       print(error)
                   }

                   totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration)
               }
           }

           let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
           mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
           mutableVideoComposition.renderSize = CGSize(width: 480, height: 640)

           if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
               let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\("duetVideo").mov")

               do {
                   if FileManager.default.fileExists(atPath: outputURL.path) {

                       try FileManager.default.removeItem(at: outputURL)
                   }
               } catch { }

               if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                   exportSession.outputURL = outputURL
                   exportSession.outputFileType = AVFileType.mov
                   exportSession.shouldOptimizeForNetworkUse = true

                   // try to export the file and handle the status cases
                   exportSession.exportAsynchronously(completionHandler: {
                       switch exportSession.status {
                       case .failed:
                           if let error = exportSession.error {
                               failure(error)
                           }

                       case .cancelled:
                           if let error = exportSession.error {
                               failure(error)
                           }

                       default:
                           print("finished")
                           success(outputURL)
                       }
                   })
               } else {
                   failure(nil)
               }
           }
       }
}
