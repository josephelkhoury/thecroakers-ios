//
//  previewPlayerViewController.swift
//  TIK TIK
//
//  Created by Mac on 22/08/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import Player
import Alamofire
import GSPlayer
import DSGradientProgressView
import AVFoundation
import CoreImage
import NextLevel

class previewPlayerViewController: UIViewController,PlayerDelegate{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var progressView: DSGradientProgressView!
    @IBOutlet weak var btnPlayImg: UIImageView!
    @IBOutlet weak var filterView: UIView!
    fileprivate var avVideoComposition: AVVideoComposition!
    fileprivate var playerItem: AVPlayerItem!
    fileprivate var video: AVURLAsset?
    fileprivate var originalImage: UIImage?
    var url:URL?
    var arrVideo: videoMainMVC?
    
    internal let filterNameList = [
        "CIColorControls",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CILinearToSRGBToneCurve",
       
        "CIColorClamp",
        "CIColorMatrix",
        "CIColorPolynomial",
        "CIExposureAdjust",
        "CIGammaAdjust",
        "CIHueAdjust",
        "CILinearToSRGBToneCurve",
        "CISRGBToneCurveToLinear",
        "CITemperatureAndTint",
        "CIToneCurve",
        "CIVibrance",
        "CIWhitePointAdjust"
    ]
    
    internal let filterDisplayNameList = [
        "Normal",
        "Chrome",
        "Fade",
        "Instant",
        "Mono",
        "Noir",
        "Process",
        "Tonal",
        "Transfer",
        "Tone",
        "Linear",
        
        "Clamp",
        "Matrix",
        "Polynomial",
        "Exposure",
        "Gamma",
        "Hue",
        "SRGBTone",
        "Curve",
        "Temperature",
        "Vibrance",
        "WhitePoint"
    ]
    
    //Filters
    internal var filterIndex = 0
    internal let context = CIContext(options: nil)
    
    @IBOutlet var collectionView: UICollectionView!
    internal var image: UIImage?
    internal var smallImage: UIImage?
    var filterImages = [UIImage]()
    
    
    //MARK:-ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        self.collectionView.register(UINib.init(nibName: "FilterCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
        
        playerSetup()
        
        for var i in 0..<self.filterNameList.count {
            self.filterImages.append(self.createFilteredImage(filterName: self.filterNameList[i],image: UIImage(named: "v3")!))
        }
        self.collectionView.reloadData()
        print(self.filterImages.count)
}
    
    //MARK:- PlayerSetup
    
    func playerSetup() {
        
        btnPlayImg.isHidden = true
        
        playerView.contentMode = .scaleAspectFill
        playerView.play(for: url!,filterName:"",filterIndex:0)
        
        self.video = AVURLAsset(url: self.url!)
        self.image = video!.videoToUIImage()
        self.originalImage = self.image
        
        playerView.stateDidChanged = { [self] state in
            switch state {
            case .none:
                print("none")
            case .error(let error):
                
                print("error - \(error.localizedDescription)")
                self.progressView.wait()
                self.progressView.isHidden = false

            case .loading:
                print("loading")
                self.progressView.wait()
                self.progressView.isHidden = false
            case .paused(let playing, let buffering):
                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
                self.progressView.signal()
                self.progressView.isHidden = true
            case .playing:
                self.btnPlayImg.isHidden = true
                self.progressView.isHidden = true
                print("playing")
            }
        }
        print("video Pause Reason: ",playerView.pausedReason )
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        print("pressed")
    }
    @IBAction func btnNext(_ sender: Any) {
        print("next pressed")
        playerView.pause(reason: .hidden)
        //        saveVideo(withURL: url!)
        let vc = storyboard?.instantiateViewController(withIdentifier: "postVC") as! postViewController
        vc.videoUrl = self.playerView.playerURL
        vc.arrVideo = self.arrVideo
        vc.modalPresentationStyle = .fullScreen
        UserDefaults.standard.set("Public", forKey: "privOpt")
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK:- ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.playerView.resume()
    }
    
    //MARK:- ViewDidDisappear
    
    override func viewDidDisappear(_ animated: Bool) {
        playerView.pause(reason: .hidden)
    }
    
    
    //MARK:- Functions
    func playerReady(_ player: Player) {
        print("playerReady")
        
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        
    }
    
    
    //MARK:- API Handler
    
    internal func saveVideo(withURL url: URL) {
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let imageData:NSData = NSData.init(contentsOf: url)!
        
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        if(UserDefaults.standard.string(forKey: "sid") == nil || UserDefaults.standard.string(forKey: "sid") == ""){
            
            UserDefaults.standard.set("null", forKey: "sid")
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.uploadVideo!
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"videobase64":["file_data":strBase64],"sound_id":"null","description":"xyz","privacy_type":"Public","allow_comments":"true","allow_duet":"1","video_id":"009988"]
        
        print(url)
        print(parameter!)
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                HomeViewController.removeSpinner(spinner: sv)
                print("json: ",json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    print("Dict: ",dic)
                    self.dismiss(animated:true, completion: nil)
                }
            case .failure(let error):
                HomeViewController.removeSpinner(spinner: sv)
                print(error)
            }
        })
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {

        playerView.pause(reason: .hidden)
        
    }
}


//MARK:- CollectionView
extension previewPlayerViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
  
    func applyFilter(filtername:String,filterIndex:Int) {
        /*  let filterName =
        
        if let image = self.image {
            self.originalImage = createFilteredImage(filterName: filterName, image: image)
        }*/
      //  if let video = self.video {
            playerView.play(for: url!,filterName:filtername,filterIndex:filterIndex)
      //  }
        
    }
    
  
    
     func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        if(filterName == filterNameList[0]){
            return self.image!
        }
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!, scale: image.scale, orientation: image.imageOrientation)
        
        return filteredImage
    }
    
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return filterNameList.count
   }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        cell.filterNameLabel.text = self.filterDisplayNameList[indexPath.row]
        cell.imageView.image =  self.filterImages[indexPath.row]
        return cell
    }
    
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterIndex = indexPath.row
        applyFilter(filtername:  filterNameList[indexPath.row], filterIndex: indexPath.row)
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:120, height: 140)
    }
}

