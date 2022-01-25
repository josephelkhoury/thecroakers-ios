//
//  splashViewController.swift
//  MusicTok
//
//  Created by Mac on 04/03/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import AVFoundation

class splashViewController: UIViewController {

    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    var videosRelatedArr = [videoMainMVC]()
    var objRelatedVideo  = [String:Any]()
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var dataLoaded: Bool = false
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVideoAnimation()
        self.settingUDID()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setupVideoAnimation() {
        let theURL = Bundle.main.url(forResource:"logo_animation", withExtension: "mp4")

        avPlayer = AVPlayer(url: theURL!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = .resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none

        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        avPlayer.play()

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if dataLoaded == true {
            pushToHome()
        }
        else {
            let p: AVPlayerItem = notification.object as! AVPlayerItem
            p.seek(to: .zero) { (success) in
            }
        }
    }
    
    //MARK:- API CALLS
    
    func getAllVideos(relatedVideo:[videoMainMVC],isVideoEmpty:Bool) {
        var userID = UserDefaults.standard.string(forKey: "userID")
        
        if userID == "" || userID == nil {
            userID = ""
        }
        
        var deviceID = UserDefaults.standard.string(forKey: "deviceID")
        if deviceID == "" || deviceID == nil {
            deviceID = ""
        }
        print("deviceid: ", deviceID)
        
        ApiHandler.sharedInstance.showRelatedVideos(device_id: deviceID! , user_id: userID!, starting_point: "0") { (isSuccess, response) in
            print("res : ",response!)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    self.videosRelatedArr.removeAll()
                    let resMsg = response?.value(forKey: "msg") as! [[String:Any]]
                    
                    for dic in resMsg {
                        let videoDic = dic["Video"] as! NSDictionary
                        let userDic = dic["User"] as! NSDictionary
                        let soundDic = dic["Sound"] as! NSDictionary
                        let topicDic = dic["Topic"] as! NSDictionary
                        let countryDic = dic["Country"] as! NSDictionary
                        
                        print("videoDic: ",videoDic)
                        print("userDic: ",userDic)
                        print("soundDic: ",soundDic)
                        
                        let videoURL = videoDic.value(forKey: "video") as? String
                        let desc = videoDic.value(forKey: "description") as? String
                        let allowLikes = videoDic.value(forKey: "allow_likes")
                        let allowComments = videoDic.value(forKey: "allow_comments")
                        let allowReplies = videoDic.value(forKey: "allow_replies")
                        let videoUserID = videoDic.value(forKey: "user_id")
                        let videoID = videoDic.value(forKey: "id") as! String
                        let allowDuet = videoDic.value(forKey: "allow_duet")
                        let main_video_id = videoDic.value(forKey: "main_video_id")
                        let duetVidID = videoDic.value(forKey: "duet_video_id")
                        
                        //not strings
                        let like = videoDic.value(forKey: "like")
                        let commentCount = videoDic.value(forKey: "comment_count")
                        let likeCount = videoDic.value(forKey: "like_count")
                        
                        let userImgPath = userDic.value(forKey: "profile_pic") as? String
                        let userName = userDic.value(forKey: "username") as? String
                        let followBtn = userDic.value(forKey: "button") as? String
                        let uid = userDic.value(forKey: "id") as? String
                        let verified = userDic.value(forKey: "verified")
                        
                        let soundName = soundDic.value(forKey: "name")
                        let cdPlayer = soundDic.value(forKey: "thum") as? String ?? ""
                        
                        let topicID = topicDic.value(forKey: "id")
                        let topicName = topicDic.value(forKey: "name")
                        
                        let countryID = countryDic.value(forKey: "id")
                        let countryName = countryDic.value(forKey: "name")
                        
                        let videoObj = videoMainMVC(videoID: videoID, videoUserID: "\(videoUserID!)", fb_id: "", description: desc ?? "", videoURL: videoURL ?? "", videoTHUM: "", videoGIF: "", view: "", section: "", sound_id: "", privacy_type: "", allow_likes: "\(allowLikes!)", allow_comments: "\(allowComments!)", allow_replies: "\(allowReplies!)", allow_duet: "\(allowDuet!)", block: "", main_video_id: "\(main_video_id!)", duet_video_id: "", old_video_id: "", created: "", like: "\(like!)", favourite: "", comment_count: "\(commentCount!)", like_count: "\(likeCount!)", followBtn: followBtn ?? "", duetVideoID: "\(duetVidID!)", userID: uid ?? "", first_name: "", last_name: "", gender: "", bio: "", website: "", dob: "", social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImgPath  ?? "", role: "", username: userName  ?? "", social: "", device_token: "", videoCount: "", verified: "\(verified!)", soundName: "\(soundName!)", CDPlayer: cdPlayer, topicID: "\(topicID!)", topicName: "\(topicName!)", countryID: "\(countryID!)", countryName: "\(countryName!)")
                        self.videosRelatedArr.append(videoObj)
                        videoArr.append(videoObj)
                    }
                 
                    self.dataLoaded = true
                }
                else {
                    videoArr.append(contentsOf: self.videosRelatedArr)
                    
                    self.dataLoaded = true
                }
            } else {
                print("response failed getAllVideos : ",response!)
                self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
            }
        }
    }
    
    func settingUDID() {
        let uid = UIDevice.current.identifierForVendor!.uuidString
        ApiHandler.sharedInstance.registerDevice(key: uid) { (err,isSuccess,response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    
                    let msg = response?.value(forKey: "msg") as! NSDictionary
                    let device = msg.value(forKey: "Device") as! NSDictionary
                    let key = device.value(forKey: "key") as! String
                    let deviceID = device.value(forKey: "id") as! String
                    print("deviceKey: ",key)
                    
                    UserDefaults.standard.set(key, forKey: "deviceKey")
                    UserDefaults.standard.set(deviceID, forKey: "deviceID")
                    
                    print("response@200: ",response!)
                  
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.getAllVideos(relatedVideo:self.videosRelatedArr,isVideoEmpty:false)
                    }
                } else {
                   print("response 201: ",response!)
                   self.getAllVideos(relatedVideo:self.videosRelatedArr,isVideoEmpty:false)
                 //   self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12.0))
                  /*   ApiHandler.sharedInstance.showDeviceDetails(key: uid) { (isSuccess, response) in
                        if isSuccess{
                            if response?.value(forKey: "code") as! NSNumber == 200 {
                                
                                let msg = response?.value(forKey: "msg") as! NSDictionary
                                let device = msg.value(forKey: "Device") as! NSDictionary
                                let key = device.value(forKey: "key") as! String
                                let deviceID = device.value(forKey: "id") as! String
                                print("device id: ",deviceID)
                                
                                UserDefaults.standard.set(key, forKey: "deviceKey")
                                UserDefaults.standard.set(deviceID, forKey: "deviceID")
                                
                                print("deviceKey: ", key)
                                print("response@200: ",response!)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.getAllVideos(relatedVideo:self.videosRelatedArr,isVideoEmpty:false)
                                }
                            }else{
                                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12.0))
                            }
                        }
                    }*/
                }
            } else {
                self.showToast(message: err, font: .systemFont(ofSize: 12))

                print("Something went wrong in API registerDevice: ",response!)
            }
        }
    }
    
    func pushToHome() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        self.view.window?.rootViewController = nav
    }
}
