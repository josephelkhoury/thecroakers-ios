//
//  favWorkingViewController.swift
//  MusicTok
//
//  Created by Mac on 08/02/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import XLPagerTabStrip

class favWorkingViewController: UIViewController,IndicatorInfoProvider {
    
    var itemInfo:IndicatorInfo = "View"
    
    var audioPlayer: AVPlayer?
    var isPlaying = false
    
    var videosDataArr = [videoMainMVC]()
    var soundsDataArr = [soundsMVC]()
    var hashTagDataArr = [hashTagMVC]()
    
    @IBOutlet weak var videosView: UIView!
    @IBOutlet weak var soundsView: UIView!
    @IBOutlet weak var hashtagView: UIView!
    
    @IBOutlet weak var videosWhoopsView: UIView!
    @IBOutlet weak var soundsWhoopsView: UIView!
    @IBOutlet weak var hashTagWhoopsView: UIView!
    
    @IBOutlet weak var videosCV: UICollectionView!
    @IBOutlet weak var soundsTV: UITableView!
    @IBOutlet weak var hashTagTV: UITableView!
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("vid")
        
        self.view.backgroundColor = .white
        
        self.videosCV.delegate = self
        self.videosCV.dataSource = self
        
        self.soundsTV.delegate = self
        self.soundsTV.dataSource = self
        
        self.hashTagTV.delegate = self
        self.hashTagTV.dataSource = self
        
        print(itemInfo.title)
        
        if itemInfo.title == "Sounds"{
            print("Sounds")
            self.getSoundsDataAPI()
            soundsView.isHidden = false
            
            videosView.isHidden = true
            hashtagView.isHidden = true
        } else if itemInfo.title == "Hashtags" {
            print("Hashtags")
            self.getHashtagsAPI()
            hashtagView.isHidden = false
            
            videosView.isHidden = true
            soundsView.isHidden = true
        } else {
            print("Videos")
            self.getVideosAPI()
            videosView.isHidden = false
            
            soundsView.isHidden = true
            hashtagView.isHidden = true
        }
        
        if #available(iOS 10.0, *) {
            soundsTV.refreshControl = refresher
            hashTagTV.refreshControl = refresher
            videosCV.refreshControl = refresher
        } else {
            soundsTV.addSubview(refresher)
            hashTagTV.addSubview(refresher)
            videosCV.addSubview(refresher)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc
    func requestData() {
        print("requesting data")
        
        if itemInfo.title == "Videos" {
            getVideosAPI()
        } else if itemInfo.title == "Sounds" {
            getSoundsDataAPI()
        } else {
            getHashtagsAPI()
        }
        
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    //    MARK:- videos API
    func getVideosAPI() {
        videosDataArr.removeAll()
        AppUtility?.startLoader(view: self.view)
        ApiHandler.sharedInstance.showFavouriteVideos(user_id: UserDefaults.standard.string(forKey: "userID")!) { (isSuccess, response) in
            if isSuccess {
                
                print("response: ",response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let vidObjMsg = response?.value(forKey: "msg") as! NSArray
                    
                    for vidObject in vidObjMsg {
                        let vidObj = vidObject as! NSDictionary
                        
                        let videoObj = vidObj.value(forKey: "Video") as! NSDictionary
                        let userObj = videoObj.value(forKey: "User") as! NSDictionary
                        let soundObj = videoObj.value(forKey: "Sound") as! NSDictionary
                        let topicObj = vidObj.value(forKey: "Topic") as! NSDictionary
                        let countryObj = videoObj.value(forKey: "Country") as! NSDictionary
                        
                        let videoUrl = videoObj.value(forKey: "video") as! String
                        let videoThum = videoObj.value(forKey: "thum") as! String
                        let videoGif = videoObj.value(forKey: "gif") as! String
                        let videoLikes = "\(videoObj.value(forKey: "like_count") ?? "")"
                        let videoComments = "\(videoObj.value(forKey: "comment_count") ?? "")"
                        let like = "\(videoObj.value(forKey: "like") ?? "")"
                        let allowLikes = videoObj.value(forKey: "allow_likes") as! String
                        let allowComments = videoObj.value(forKey: "allow_comments") as! String
                        let videoID = videoObj.value(forKey: "id") as! String
                        let videoDesc = videoObj.value(forKey: "description") as! String
                        let allowDuet = videoObj.value(forKey: "allow_duet") as! String
                        let created = videoObj.value(forKey: "created") as! String
                        let views = "\(videoObj.value(forKey: "view") ?? "")"
                        let main_video_id = videoObj.value(forKey: "main_video_id")
                        let duetVidID = videoObj.value(forKey: "duet_video_id")
                        
                        let userID = userObj.value(forKey: "id") as! String
                        let username = userObj.value(forKey: "username") as! String
                        let userOnline = userObj.value(forKey: "online") as! String
                        let userImg = userObj.value(forKey: "profile_pic") as! String
                        //                        let followBtn = userObj.value(forKey: "button") as! String
                        let verified = userObj.value(forKey: "verified")
                        
                        let soundID = soundObj.value(forKey: "id") as? String
                        let soundName = soundObj.value(forKey: "name") as? String
                        let cdPlayer = soundObj.value(forKey: "thum") as? String ?? ""
                        
                        let topicID = topicObj.value(forKey: "id")
                        let topicName = topicObj.value(forKey: "name")
                        
                        let countryID = countryObj.value(forKey: "id")
                        let countryName = countryObj.value(forKey: "name")
                        
                        let video = videoMainMVC(videoID: videoID, videoUserID: "", fb_id: "", description: videoDesc, videoURL: videoUrl, videoTHUM: videoThum, videoGIF: videoGif, view: views, section: "", sound_id: "\(soundID ?? "")", privacy_type: "", allow_likes: allowLikes, allow_comments: allowComments, allow_duet: allowDuet, block: "", main_video_id: "\(main_video_id!)", duet_video_id: "", old_video_id: "", created: created, like: like, favourite: "", comment_count: videoComments, like_count: videoLikes, followBtn: "", duetVideoID: "\(duetVidID!)", userID: userID, first_name: "", last_name: "", gender: "", bio: "", website: "", dob: "", social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImg, role: "", username: username, social: "", device_token: "", videoCount: "", verified: "\(verified ?? "")", soundName: "\(soundName ?? "")",CDPlayer: cdPlayer, topicID: "\(topicID!)", topicName: "\(topicName!)", countryID: "\(countryID!)", countryName: "\(countryName!)")
                        
                        self.videosDataArr.append(video)
                    }
                }
                
                AppUtility?.stopLoader(view: self.view)
                print("videoDataArr: ",self.videosDataArr)
                if self.videosDataArr.isEmpty {
                    self.videosWhoopsView.isHidden = false
                } else {
                    self.videosWhoopsView.isHidden = true
                }
                self.videosCV.reloadData()
            }
        }
    }
    
//    MARK:- sounds API
    func getSoundsDataAPI() {
        soundsDataArr.removeAll()
        AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.showFavouriteSounds(user_id: UserDefaults.standard.string(forKey: "userID")!) { (isSuccess, response) in
            if isSuccess {
                
                print("response: ",response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let sndObjMsg = response?.value(forKey: "msg") as! NSArray
                    
                    for sndObject in sndObjMsg{
                        let sndObj = sndObject as! NSDictionary
                        
                        let soundObj = sndObj.value(forKey: "Sound") as! NSDictionary
                        
                        let id = soundObj.value(forKey: "id") as? String
                        let audioUrl = soundObj.value(forKey: "audio") as? String
                        let duration = soundObj.value(forKey: "duration") as? String
                        let name = soundObj.value(forKey: "name") as? String
                        let description = soundObj.value(forKey: "description") as? String
                        let thum = soundObj.value(forKey: "thum") as? String
                        let section = soundObj.value(forKey: "section") as? String
                        let uploaded_by = soundObj.value(forKey: "uploaded_by") as? String
                        let created = soundObj.value(forKey: "created") as? String
                        let favourite = soundObj.value(forKey: "favourite")
                        let publish = soundObj.value(forKey: "publish") as? String
                        
                        let obj = soundsMVC(id: id ?? "", audioURL: audioUrl ?? "", duration: duration ?? "", name: name ?? "", description: description ?? "", thum: thum ?? "", section: section ?? "", uploaded_by: uploaded_by ?? "", created: created ?? "", favourite: "\(favourite ?? "")", publish: publish ?? "")
                        
                        self.soundsDataArr.append(obj)
                    }
                    
                }
                AppUtility?.stopLoader(view: self.view)
                print("videoDataArr: ",self.soundsDataArr)
                if self.soundsDataArr.isEmpty {
                    self.soundsWhoopsView.isHidden = false
                } else {
                    self.soundsWhoopsView.isHidden = true
                }
                self.soundsTV.reloadData()
            }
        }
    }
    
    //    MARK:- HASHTAGS API
    func getHashtagsAPI(){
        hashTagDataArr.removeAll()
        AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.showFavouriteHashtags(user_id: UserDefaults.standard.string(forKey: "userID")!) { (isSuccess, response) in
            
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                
                print("response: ", response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let hashObjMsg = response?.value(forKey: "msg") as! NSArray
                    
                    for hashObject in hashObjMsg {
                        let hashObj = hashObject as! NSDictionary
                        
                        let hashtag = hashObj.value(forKey: "Hashtag") as! NSDictionary
                        
                        let id = hashtag.value(forKey: "id") as! String
                        let name = hashtag.value(forKey: "name") as! String
                        let views = hashtag.value(forKey: "views") as! String
                        let favourite = hashtag.value(forKey: "favourite") as? NSNumber
                        
                        let obj = hashTagMVC(id: id, name: name, views: views, favourite: "\(favourite ?? 0)")
                        
                        self.hashTagDataArr.append(obj)
                    }
                }
                AppUtility?.stopLoader(view: self.view)
                print("hashTagDataArr: ", self.hashTagDataArr)
                if self.hashTagDataArr.isEmpty {
                    self.hashTagWhoopsView.isHidden = false
                } else {
                    self.hashTagWhoopsView.isHidden = true
                }
                self.hashTagTV.reloadData()
            }
        }
    }
}

//MARK:- fav VIDEOS setup
extension favWorkingViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videosDataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let vidCell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchVideosCVC", for: indexPath) as! searchVideosCollectionViewCell
        
        let vidObj = videosDataArr[indexPath.row]
        //            let vidImg = baseUrl+vidObj.userProfile_pic
        
        let userImg = AppUtility?.detectURL(ipString: vidObj.userProfile_pic)
        
        vidCell.vidImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        vidCell.vidImg.sd_setImage(with: URL(string: (AppUtility?.detectURL(ipString: vidObj.videoGIF))!), placeholderImage: UIImage(named: "videoPlaceholder"))
        
        //            let gifURL : String = (AppUtility?.detectURL(ipString: vidObj.videoGIF))!
        //            let imageURL = UIImage.gifImageWithURL(gifURL)
        //            vidCell.vidImg.image = imageURL
        
        vidCell.userImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        vidCell.userImg.sd_setImage(with: URL(string: userImg!), placeholderImage: UIImage(named: "noUserImg"))
        
        vidCell.usernameLbl.text = vidObj.username
        vidCell.nameLbl.text = vidObj.first_name+" "+vidObj.last_name
        vidCell.likeCountLbl.text = vidObj.like_count
        vidCell.descLbl.text = vidObj.description
        
        return vidCell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       /* let vc = storyboard?.instantiateViewController(withIdentifier: "homeFeedVC") as! homeFeedViewController
        vc.userVideoArr = videosDataArr
        vc.indexAt = indexPath
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)*/
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
        vc.videosMainArr = self.videosDataArr
        vc.currentIndex = indexPath
        vc.isOtherController =  true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((videosCV.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: 300)
    }
}

//MARK:- fav SOUNDS and HASHTAGS setup
extension favWorkingViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == soundsTV{
            return soundsDataArr.count
        }
        return self.hashTagDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == hashTagTV {
            let hashCell = tableView.dequeueReusableCell(withIdentifier: "searchHashtagsTVC") as! searchHashtagsTableViewCell
            
            let hashObj = hashTagDataArr[indexPath.row]
            
            hashCell.titleLbl.text = hashObj.name
            hashCell.countLbl.text = hashObj.views
            
            if hashObj.favourite == "1" {
                hashCell.btnFav.setImage(UIImage(named: "btnFavFilled"), for: .normal)
            } else {
                hashCell.btnFav.setImage(UIImage(named:"btnFavEmpty"), for: .normal)
            }
            
            hashCell.btnFav.addTarget(self, action: #selector(favWorkingViewController.btnFavHashAction(_:)), for:.touchUpInside)

            return hashCell
        }
        
        let soundCell = tableView.dequeueReusableCell(withIdentifier: "searchSoundTVC") as! searchSoundTableViewCell
        
        let obj = soundsDataArr[indexPath.row]
        let sndImg = AppUtility?.detectURL(ipString: obj.thum)
        
        soundCell.soundImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        soundCell.soundImg.sd_setImage(with: URL(string:sndImg!), placeholderImage: UIImage(named: "noMusicIcon"))
        
        soundCell.titleLbl.text = obj.name
        soundCell.descLbl.text = obj.description
        soundCell.durationLbl.text = obj.duration
        
        if obj.favourite == "1"{
            soundCell.favBtn.setImage(UIImage(named: "btnFavFilled"), for: .normal)
        }else{
            soundCell.favBtn.setImage(UIImage(named:"btnFavEmpty"), for: .normal)
        }
        
        soundCell.favBtn.addTarget(self, action: #selector(favWorkingViewController.btnSoundFavAction(_:)), for:.touchUpInside)
        soundCell.selectBtn.addTarget(self, action: #selector(favWorkingViewController.btnSelectAction(_:)), for:.touchUpInside)
        
        soundCell.selectBtn.isHidden = true
        soundCell.favBtn.isHidden = true
        soundCell.btnPlay.isHidden = false
        soundCell.btnPlay.image = UIImage(named: "ic_play_icon")
        
        return soundCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == hashTagTV{
            return 50
        }
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == hashTagTV{
            let hashtag = hashTagDataArr[indexPath.row].name
            let vc = storyboard?.instantiateViewController(withIdentifier: "hashtagsVideoVC") as! hashtagsVideoViewController
            vc.hashtag = hashtag
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let obj = soundsDataArr[indexPath.row]
            self.playSound(soundUrl: (AppUtility?.detectURL(ipString: obj.audioURL))!,ip: indexPath)
        }
    }
    
    func playSound(soundUrl: String,ip:IndexPath) {
        let cell = soundsTV.cellForRow(at: ip) as! searchSoundTableViewCell
        
        if isPlaying == true {
            self.isPlaying = false
            cell.selectBtn.isHidden = true
            cell.favBtn.isHidden = true
            cell.btnPlay.image = UIImage(named: "ic_play_icon")
            
            self.audioPlayer?.pause()
        } else {
            cell.btnPlay.isHidden = true
            DispatchQueue.main.async {
                cell.loadIndicator.startAnimating()
            }
            
            guard  let url = URL(string: soundUrl)
            else {
                print("error to get the mp3 file")
                return
            }
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer = try AVPlayer(url: url as URL)
                guard let player = audioPlayer
                else {
                    return
                }
                
                player.play()
                
                
                DispatchQueue.main.async {
                    cell.loadIndicator.stopAnimating()
                }
                print("player.reasonForWaitingToPlay: ",player.reasonForWaitingToPlay)
                
                self.isPlaying = true
                cell.selectBtn.isHidden = false
                cell.favBtn.isHidden = false
                cell.btnPlay.isHidden = false
                cell.btnPlay.image = UIImage(named: "ic_pause_icon")
                print("progress: ",player.playProgress)
            } catch let error {
                self.isPlaying = false
                print(error.localizedDescription)
            }
        }
        
    }
    
    //    MAEK:- Btn fav sound Action
    @objc func btnSoundFavAction(_ sender : UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.soundsTV)
        let indexPath = self.soundsTV.indexPathForRow(at:buttonPosition)
        let cell = self.soundsTV.cellForRow(at: indexPath!) as! searchSoundTableViewCell
        
        let btnFavImg = cell.favBtn.currentImage
        
        if btnFavImg == UIImage(named: "btnFavEmpty"){
            cell.favBtn.setImage(UIImage(named: "btnFavFilled"), for: .normal)
        }else{
            cell.favBtn.setImage(UIImage(named: "btnFavEmpty"), for: .normal)
        }
        
        let obj = soundsDataArr[indexPath!.row]
        
        addFavSong(soundID: obj.id, btnFav: cell.favBtn)
    }
    
    //    MARK:- SELECT SOUND ACTION
    @objc func btnSelectAction(_ sender : UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.soundsTV)
        let indexPath = self.soundsTV.indexPathForRow(at:buttonPosition)
        let obj = soundsDataArr[indexPath!.row]
        
        //        let uid = UserDefaults.standard.string(forKey: "userID")
        //
        //        if uid == "" || uid == nil{
        //            loginScreenAppear()
        //        }else{
        //            //            saveSondToLocal(soundObj: obj)
        //        }
        
    }
    
    @objc func btnFavHashAction(_ sender : UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.hashTagTV)
        let indexPath = self.hashTagTV.indexPathForRow(at:buttonPosition)

        self.addFavHashAPI(ip: indexPath!)

    }
    
    //    MARK:- ADD FAV SOUND FUNC
    func addFavSong(soundID:String,btnFav:UIButton){
        AppUtility?.startLoader(view: self.view)
        ApiHandler.sharedInstance.addSoundFavourite(user_id: UserDefaults.standard.string(forKey: "userID")!, sound_id: soundID) { (isSuccess, response) in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                if response?.value(forKey: "code") as! NSNumber == 200{
                    print("msg: ",response?.value(forKey: "msg")!)
                    
                    if btnFav.currentImage == UIImage(named: "btnFavEmpty"){
                        self.showToast(message: "Removed From Favorite", font: .systemFont(ofSize: 12))
                    }else{
                        self.showToast(message: "Added to Favorite", font: .systemFont(ofSize: 12))
                    }
                    
                }else{
                    AppUtility?.stopLoader(view: self.view)
                    self.showToast(message: "!200", font: .systemFont(ofSize: 12))
                }
            }
        }
    }
    
//    MARK:- addFavHashAPI
    func addFavHashAPI(ip:IndexPath){
        
        let cell = self.hashTagTV.cellForRow(at: ip) as! searchHashtagsTableViewCell
        let hashObj = hashTagDataArr[ip.row]
        
        AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.addHashtagFavourite(user_id: UserDefaults.standard.string(forKey: "userID")!, hashtag_id: hashObj.id) { (isSuccess, response) in
            
            AppUtility?.stopLoader(view: self.view)
            if isSuccess{
                let code = response?.value(forKey: "code") as! NSNumber
                
                if code == 200{
                    
                    if response?.value(forKey: "msg") as? String == "unfavourite"{
                        cell.btnFav.setImage(#imageLiteral(resourceName: "btnFavEmpty"), for: .normal)
//                        self.btnAddFav.setTitle("Add to Favorite", for: .normal)
                        
                        self.showToast(message: "UnFavorite", font: .systemFont(ofSize: 12))
                        return
                    }
                    
                    self.showToast(message: "Added to FAVORITE", font: .systemFont(ofSize: 12))
//                    self.btnFav.image = #imageLiteral(resourceName: "btnFavFilled")
                    
                    cell.btnFav.setImage(#imageLiteral(resourceName: "btnFavFilled"), for: .normal)
                }else{
                    self.showToast(message: "Something went wront try again", font: .systemFont(ofSize: 12))
                }
            }
        }
    }
}
