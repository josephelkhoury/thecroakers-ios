//
//  topicsVideoViewController.swift
//  MusicTok
//
//  Created by Mac on 04/02/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class topicsVideoViewController: UIViewController {
    
    @IBOutlet weak var videosCV: UICollectionView!
    @IBOutlet var topicTitle: [UILabel]!
    @IBOutlet weak var videosCount : UILabel!
    @IBOutlet weak var btnFav : UIImageView!
    @IBOutlet weak var btnAddFav : UIButton!
    
    
    var topicVideosArr = [videoMainMVC]()
    var topicData = [String:Any]()
    var topic = ""
    
    var pageNumber = 0
    var totalPages = 1
    var isDataLoading:Bool=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videosCV.delegate = self
        videosCV.dataSource = self
        
        for title in topicTitle {
            title.text = topic
        }
        getTopicDataAPI(topic: topic,starting_point: "\(self.pageNumber)")
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnFav(_ sender: Any) {
        
//        if self.hashtagData["favourite"] as! NSNumber == 0{
//            self.btnFav.image = #imageLiteral(resourceName: "btnFavFilled")
//        }
        
        self.addFavTopicAPI()
    }
    
    //    MARK:- API
    func getTopicDataAPI(topic:String,starting_point:String){
        
        //showToast(message: "Loading Videos...", font: .systemFont(ofSize: 12.0))
        var userID = UserDefaults.standard.string(forKey: "userID")
        
        if userID == "" || userID == nil{
            userID = ""
        }
        
        //AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.showVideosAgainstTopic(user_id: userID!, topic: topic,starting_point:starting_point) { (isSuccess, response) in
            
            AppUtility?.stopLoader(view: self.view)
            
            if isSuccess{
                let code = response?.value(forKey: "code") as! NSNumber
                
                if code == 200{
                    let msgArr = response?.value(forKey: "msg") as! NSArray
                    
                    for msgObj in msgArr{
                        
                        let videosData = msgObj as! NSDictionary
                        
                        self.topicData = videosData.value(forKey: "Topic") as! [String : Any]
                        
                        let videoObj = videosData.value(forKey: "Video") as! NSDictionary
                        let userObj = videoObj.value(forKey: "User") as! NSDictionary
                        let topicObj = videoObj.value(forKey: "Topic") as! NSDictionary
                        let countryObj = videoObj.value(forKey: "Country") as! NSDictionary
                        
                        let videoUrl = videoObj.value(forKey: "video") as! String
                        let videoThum = videoObj.value(forKey: "thum") as! String
                        let videoGif = videoObj.value(forKey: "gif") as! String
                        let videoLikes = "\(videoObj.value(forKey: "like_count") ?? "")"
                        let videoComments = "\(videoObj.value(forKey: "comment_count") ?? "")"
                        let like = "\(videoObj.value(forKey: "like") ?? "")"
                        let allowLikes = videoObj.value(forKey: "allow_likes") as! String
                        let allowComments = videoObj.value(forKey: "allow_comments") as! String
                        let allowReplies = videoObj.value(forKey: "allow_replies") as! String
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
                        
//                            let soundID = soundObj.value(forKey: "id") as? String
//                            let soundName = soundObj.value(forKey: "name") as? String
                        
                        let topicID = topicObj.value(forKey: "id")
                        let topicName = topicObj.value(forKey: "name")
                        
                        let countryID = countryObj.value(forKey: "id")
                        let countryName = countryObj.value(forKey: "name")
                        
                        let video = videoMainMVC(videoID: videoID, videoUserID: "", fb_id: "", description: videoDesc, videoURL: videoUrl, videoTHUM: videoThum, videoGIF: videoGif, view: views, section: "", sound_id: "", privacy_type: "", allow_likes: allowLikes, allow_comments: allowComments, allow_replies: allowReplies, allow_duet: allowDuet, block: "", main_video_id: "\(main_video_id!)", duet_video_id: "", old_video_id: "", created: created, like: like, favourite: "", comment_count: videoComments, like_count: videoLikes, followBtn: "", duetVideoID: "\(duetVidID!)", userID: userID, first_name: "", last_name: "", gender: "", bio: "", website: "", dob: "", social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: "", role: "", username: username, social: "", device_token: "", videoCount: "", verified: "\(verified!)", soundName: "",CDPlayer: "", topicID: "\(topicID!)", topicName: "\(topicName!)", countryID: "\(countryID!)", countryName: "\(countryName!)")
                        
                        self.topicVideosArr.append(video)
                        
                        print("videoLikes: ",videoLikes)
                    }
                    
                    self.videosCount.text = "\(self.topicVideosArr.count) Videos"
                    
                    if self.topicData["favourite"] as! NSNumber == 0{
                        self.btnFav.image = #imageLiteral(resourceName: "btnFavEmpty")
                        
                    }else{
                        self.btnFav.image = #imageLiteral(resourceName: "btnFavFilled")
                        self.btnAddFav.setTitle("Favorite", for: .normal)
                    }
                    self.videosCV.reloadData()
                }else{
                    self.totalPages = self.pageNumber
                }
            }
        }
    }
    
    func addFavTopicAPI(){
        let uid = UserDefaults.standard.string(forKey: "userID")
        guard uid != nil && uid != "" else {
            loginScreenAppear()
            return
        }
        
        //AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.addTopicFavourite(user_id: uid!, topic_id: self.topicData["id"] as! String) { (isSuccess, response) in
            
            AppUtility?.stopLoader(view: self.view)
            if isSuccess{
                let code = response?.value(forKey: "code") as! NSNumber
                
                if code == 200{
                    
                    if response?.value(forKey: "msg") as? String == "unfavourite"{
                        self.btnFav.image = #imageLiteral(resourceName: "btnFavEmpty")
                        self.btnAddFav.setTitle("Add to Favorite", for: .normal)
                        self.showToast(message: "UnFavorite", font: .systemFont(ofSize: 12))
                        return
                    }
                    
                    self.showToast(message: "Added to FAVORITE", font: .systemFont(ofSize: 12))
                    self.btnFav.image = #imageLiteral(resourceName: "btnFavFilled")
                    self.btnAddFav.setTitle("Favorite", for: .normal)
                    
                }else{
                    self.showToast(message: "Something went wront try again", font: .systemFont(ofSize: 12))
                }
            }
        }
    }
    
    //    MARK:- Login screen will appear func
    func loginScreenAppear(){
        let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen
        
        self.present(navController, animated: true, completion: nil)
    }
    
}
extension topicsVideoViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicVideosArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let vidCell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchVideosCVC", for: indexPath) as! searchVideosCollectionViewCell
        
        let vidObj = topicVideosArr[indexPath.row]
        //            let vidImg = baseUrl+vidObj.userProfile_pic
        
        let userImg = AppUtility?.detectURL(ipString: vidObj.userProfile_pic)
        
        vidCell.vidImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        vidCell.vidImg.sd_setImage(with: URL(string: (AppUtility?.detectURL(ipString: vidObj.videoGIF))!), placeholderImage: UIImage(named: "videoPlaceholder"))
        
        
        print(vidObj.videoGIF)
        //            let gifURL : String = (AppUtility?.detectURL(ipString: vidObj.videoGIF))!
        //            let imageURL = UIImage.gifImageWithURL(gifURL)
        //            vidCell.vidImg.image = imageURL
        
        //            vidCell.userImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        //            vidCell.userImg.sd_setImage(with: URL(string: userImg!), placeholderImage: UIImage(named: "noUserImg"))
        //
        //            vidCell.usernameLbl.text = vidObj.username
        //            vidCell.nameLbl.text = vidObj.first_name+" "+vidObj.last_name
        //            vidCell.likeCountLbl.text = vidObj.like_count
                    vidCell.descLbl.text = vidObj.view
        
        return vidCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 3

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((videosCV.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
        vc.videosMainArr = self.topicVideosArr
        vc.currentIndex = indexPath
        vc.isOtherController =  true
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension topicsVideoViewController {
    //MARK: ScrollView Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        
        isDataLoading = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        print("scrollViewDidEndDragging")
        if scrollView == self.videosCV{
                if ((videosCV.contentOffset.y + videosCV.frame.size.height) >= videosCV.contentSize.height)
                {
                    if !isDataLoading{
                        isDataLoading = true
                        print("Next page call")
                        if self.pageNumber < self.totalPages{
                            self.pageNumber = self.pageNumber + 1
                            getTopicDataAPI(topic: topic, starting_point: "\(self.pageNumber)")
                        }
                    }
                }
           }
      }
 }
