//
//  postViewController.swift
//  TIK TIK
//
//  Created by Mac on 28/08/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import Photos

class postViewController: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var privacyIconImg: UIImageView!
    @IBOutlet weak var vidThumbnail: UIImageView!
    @IBOutlet weak var describeTextView: AttrTextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
 
    var videoUrl:URL?
    var privacyType = "Public"
    var desc = ""
    var allowDuet = "1"
    var allowComments = "true"
    var duet = "1"
    var soundId = "null"
    var saveV = "1"
    
    var boxView = UIView()
    var blurView = UIView()
    
    var hashTagsArr = [String]()
    var userTagsArr = [String]()
    
    var arrVideo: videoMainMVC?
    var topic_id:String?
    var country_id:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("videoURL", videoUrl)
        describeTextView.text = "Describe your video"
        describeTextView.textColor = UIColor.lightGray
        
        let privayOpt = UITapGestureRecognizer(target: self, action:  #selector(self.privacyOptionsList))
        self.privacyView.addGestureRecognizer(privayOpt)
        self.getThumbnailImageFromVideoUrl(url: videoUrl!) { (thumb) in
            self.vidThumbnail.image = thumb
        }
        
        UserDefaults.standard.set("", forKey: "hashtag_id")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.countryDataNotification(_:)), name: NSNotification.Name(rawValue: "countryDataNotification"), object: nil)
        
        if (self.arrVideo != nil) {
            self.topic_id = self.arrVideo?.topicID
            self.topicLabel.text = self.arrVideo?.topicName
            self.country_id = self.arrVideo?.countryID
            self.countryLabel.text = self.arrVideo?.countryName
        }
        else {
            let topicOpt = UITapGestureRecognizer(target: self, action:  #selector(self.topicOptionsList))
            self.topicView.addGestureRecognizer(topicOpt)
            
            let countryOpt = UITapGestureRecognizer(target: self, action:  #selector(self.countryOptionsList))
            self.countryView.addGestureRecognizer(countryOpt)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            textView.text = .none
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Describe your video"
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        describeTextView.setText(text: describeTextView.text,textColor: .black, withHashtagColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), andMentionColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), andCallBack: { (strng, type) in
            print("type: ",type)
            print("strng: ",strng)
        }, normalFont: .systemFont(ofSize: 14, weight: UIFont.Weight.light), hashTagFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold), mentionFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold))
    }
    
    func uploadData() {
        let hashtags = describeTextView.text.hashtags()
        let mentions = describeTextView.text.mentions()

        var newHashtags = [[String:String]]()
        var newMentions = [[String:String]]()
        
        for hash in hashtags {
            newHashtags.append(["name":hash])
        }
        for mention in mentions {
            newMentions.append(["name":mention])
        }
        
        let encoder = JSONEncoder()
        var hashtags_json:String?
        var mentions_json:String?
        
        if let jsonData = try? encoder.encode(newHashtags) {
            hashtags_json = String(data: jsonData, encoding: .utf8)
        }
        if let jsonData = try? encoder.encode(newMentions) {
            mentions_json = String(data: jsonData, encoding: .utf8)
        }
        
        AppUtility?.startLoader(view: self.view)
        //        let  sv = HomeViewController.displaySpinner(onView: self.view)
        if (UserDefaults.standard.string(forKey: "sid") == nil || UserDefaults.standard.string(forKey: "sid") == "") {
            UserDefaults.standard.set("null", forKey: "sid")
        }
        
        //        let url : String = self.appDelegate.baseUrl!+self.appDelegate.uploadMultipartVideo!
        let url : String = ApiHandler.sharedInstance.baseApiPath+"postVideo"
        
        let cmnt = self.allowComments
        let allwDuet = self.allowDuet
        let prv = self.privacyType
        var des = self.desc
        if describeTextView.text != "Describe your video" {
            des = describeTextView.text
        } else {
            des = ""
        }
        
        print("cmnt",cmnt)
        print("allwDuet",allwDuet)
        print("prv",prv)
        print("des",des)
        print("hashtags",hashtags)
        print("mentions",mentions)
        
        let parameter :[String:Any]? = ["user_id"       : UserDefaults.standard.string(forKey: "userID")!,
                                        "sound_id"      : 0,
                                        "description"   : des,
                                        "privacy_type"  : prv,
                                        "allow_comments": cmnt,
                                        "allow_duet"    : allwDuet,
                                        "users_json"    : mentions_json,
                                        "hashtags_json" : hashtags_json,
                                        "topic_id"      : self.topic_id,
                                        "main_video_id" : self.arrVideo?.videoID,
                                        "country_id"    : self.country_id
        ]
        
        let uidString = UserDefaults.standard.string(forKey: "userID")!
        let soundIDString = "null"
        
        print(url)
        print(parameter!)
        let headers: HTTPHeaders = [
            "Api-Key":API_KEY
        ]
        let serializer = DataResponseSerializer(emptyResponseCodes: Set([200, 204, 205]))
        AF.upload(multipartFormData: { MultipartFormData in
            
            if (!JSONSerialization.isValidJSONObject(parameter)) {
                print("is not a valid json object")
                return
            }
            for key in parameter!.keys{
                let name = String(key)
                print("key",name)
                if let val = parameter![name] as? String{
                    MultipartFormData.append(val.data(using: .utf8)!, withName: name)
                }
            }
            print(self.videoUrl!)
            MultipartFormData.append(self.videoUrl!, withName: "video")
        }, to: url, method: .post, headers: headers)
            .responseJSON { (response) in
                switch response.result{
                    
                case .success(let value):
                    print("progress: ", Progress.current())
                    let json = value
                    let dic = json as! NSDictionary
                    
                    print("response:- ", response)
                    if (dic["code"] as! NSNumber == 200){
                        print("200")
                        debugPrint("SUCCESS RESPONSE: \(response)")
                        
                        if self.saveV == "1" {
                            self.saveVideoToAlbum(self.videoUrl!) { (err) in
                                if err != nil {
                                    print("Unable to save video to album dur to: ",err!)
                                    self.showToast(message: "Unable to save video to album dur to:", font: .systemFont(ofSize: 12))
                                } else{
                                    print("video saved to gallery")
                                    self.showToast(message: "video saved to gallery", font: .systemFont(ofSize: 12))
                                }
                                
                            }
                        }
                        AppUtility?.stopLoader(view: self.view)
                        print("Dict: ",dic)
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        
                        
                    } else {
                        AppUtility?.stopLoader(view: self.view)
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        print(dic)
                        
                    }
                case .failure(let error):
                    AppUtility?.stopLoader(view: self.view)
                    print("\n\n===========Error===========")
                    print("Error Code: \(error._code)")
                    print("Error Messsage: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: String.Encoding.utf8){
                        print("Server Error: " + str)
                    }
                    debugPrint(error as Any)
                    print("===========================\n\n")
            
                }
        }
    }
        
    @IBAction func btnPost(_ sender: Any) {
        if self.topic_id == "" {
            showToast(message: "Please choose a topic for your video", font: .systemFont(ofSize: 12))
            return;
        }
        uploadData()
    }
    @IBAction func commentSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.allowComments = "true"
        } else{
            self.allowComments = "false"
        }
    }
    
    @IBAction func duetSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.allowDuet = "1"
        } else{
            self.allowDuet = "0"
        }
    }
    
    @IBAction func saveSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.saveV = "1"
        } else{
            self.saveV = "0"
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        print("pressed")
    }
    
    //    MARK:- ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("privTypeNC"), object: nil)
        
    }
    
    //    MARK:- UIVIEWS ACTIONS
    @objc func privacyOptionsList(sender : UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "privacyVC") as! privacyViewController
        //vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func topicOptionsList(sender : UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "topicVC") as! topicViewController
        //vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func countryOptionsList(sender : UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "countryCodeVC") as! countryCodeViewController
        present(vc, animated: true, completion: nil)
    }
    
    //    MARK:- CHANGE PRIVACY INFO
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        if let type = notification.userInfo?["privType"] as? String {
            print("type: ",type)
            self.publicLabel.text = type
            self.privacyType = type
            
            switch type {
            case "Public":
                self.privacyIconImg.image = #imageLiteral(resourceName: "openLockIcon")
                UserDefaults.standard.set(0, forKey: "selectRow")
            case "Friends":
                self.privacyIconImg.image = #imageLiteral(resourceName: "30")
            case "Private":
                self.privacyIconImg.image = #imageLiteral(resourceName: "lockedLockIcon")
                UserDefaults.standard.set(1, forKey: "selectRow")
            default:
                self.privacyIconImg.image = #imageLiteral(resourceName: "openLockIcon")
                self.publicLabel.text = "Public"
                self.privacyType = "Public"
                UserDefaults.standard.set(0, forKey: "selectRow")
            }
        }
        if let hashtag = notification.userInfo?["hashtag"] as? hashTagMVC {
            print("hashtag:", hashtag.name)
            self.topicLabel.text = hashtag.name
            self.topic_id = hashtag.id
        }
    }
    
    @objc func countryDataNotification(_ notification: NSNotification) {
        print("countryDataNotification")
        
        if let country = notification.userInfo?["country"] as? countryMVC {
            print("notification.userInfo: ", country.name )
            let name = country.name
            let flag = country.emoji
            countryLabel.text = "\(name) \(flag)"
            self.country_id = country.id
        }
    }
    
    //    MARK:- SET VIDEO THUMBNAIL FUNC
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbNailImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    //    MARK:- SAVE VIDEO DATA
    
    func requestAuthorization(completion: @escaping ()->Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized{
            completion()
        }
    }
    
    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
        requestAuthorization {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: outputURL, options: nil)
            }) { (result, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Saved VIDEO TO photos successfully")
                    }
                    completion?(error)
                }
            }
        }
    }
    
    func showShimmer(progress: String) {
        //        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 70, width: 180, height: 50))
        boxView.backgroundColor = UIColor.white
        boxView.alpha = 0.8
        boxView.layer.cornerRadius = 10
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.gray
        textLabel.text = progress
        
        blurView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        let blurView = UIView(frame: UIScreen.main.bounds)
        
        boxView.addSubview(blurView)
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
    }
    
    func HideShimmer() {
        boxView.removeFromSuperview()
    }
    
    
//    MARK:- BTN HASHTAG AND MENTIONS SETUPS
    @IBAction func btnHashtag(_ sender: UISwitch) {
        
        guard self.describeTextView.text != "Describe your video" else {return}
        
        self.describeTextView.setText(text: describeTextView.text+" #",textColor: .black, withHashtagColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), andMentionColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), andCallBack: { (strng, type) in
            print("type: ",type)
            print("strng: ",strng)
        }, normalFont: .systemFont(ofSize: 14, weight: UIFont.Weight.light), hashTagFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold), mentionFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold))
    }
    
    @IBAction func btnMention(_ sender: UISwitch) {
        
        guard self.describeTextView.text != "Describe your video" else {return}
        
        self.describeTextView.setText(text: describeTextView.text+" @",textColor: .black, withHashtagColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), andMentionColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), andCallBack: { (strng, type) in
            print("type: ",type)
            print("strng: ",strng)
        }, normalFont: .systemFont(ofSize: 14, weight: UIFont.Weight.light), hashTagFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold), mentionFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold))
        
    }
    
    func dictToJSON(dict:[String: AnyObject]) -> AnyObject {
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        return jsonData as AnyObject
    }
}

extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }

        return String(data: theJSONData, encoding: .ascii)
    }
}


