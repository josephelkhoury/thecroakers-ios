//
//  newDiscoverViewController.swift
//  TIK TIK
//
//  Created by Mac on 26/10/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SDWebImage

//@available(iOS 13.0, *)
class newDiscoverViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout, IndicatorInfoProvider {
    
    //MARK:- Outlets
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var discoverBannerCollectionView: UICollectionView!
    @IBOutlet weak var discoverTblView: UITableView!
    
    @IBOutlet var tblheight: NSLayoutConstraint!
    @IBOutlet weak var bannerPageController: UIPageControl!
    
    var entityDataArr = [[String:Any]]()
    var section = "0"
    
    var sliderArr = [sliderMVC]()
    var itemInfo:IndicatorInfo = "View"
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerPageController.tintColor = .white
        view.bringSubviewToFront(self.bannerPageController)
        self.scrollViewOutlet.delegate =  self
        getSliderData()
        getVideosData()
        self.setupView()
        
        AppUtility?.startLoader(view: self.view)
    }
    
    @objc
    func requestData() {
        self.entityDataArr.removeAll()
        self.sliderArr.removeAll()
        getVideosData()
        getSliderData()
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 10.0, *) {
            scrollViewOutlet.refreshControl = refresher
        } else {
            scrollViewOutlet.addSubview(refresher)
        }
    }
    
    //MARK:- SetupView
    
    func setupView(){
        tblheight.constant = CGFloat(entityDataArr.count * 190)
    }
    
    //MARK: TableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.bannerPageController.currentPage = Int(self.discoverBannerCollectionView.contentOffset.x) / Int(self.discoverBannerCollectionView.frame.width)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entityDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "newDiscoverTVC") as! newDiscoverTableViewCell
        let entityObj = entityDataArr[indexPath.row]
        let hashtag = entityObj["entityName"] as! String
        cell.hashName.text = hashtag
        cell.section = section
        cell.entityImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let entity_img = entityObj["entity_img"] as! String
        let image = AppUtility?.detectURL(ipString: entity_img)
        
        if section == "0" {
            cell.entityImageView.sd_setImage(with: URL(string:image!), placeholderImage: UIImage(named: "hashIcon"))
            cell.hashNameSub.text = "Trending Topic"
        }
        else if section == "1" || section == "2" {
            cell.entityImageView.sd_setImage(with: URL(string:image!), placeholderImage: UIImage(named: "noUserImg"))
            if section == "1" {
                cell.hashNameSub.text = "Trending Publisher"
            }
            else if section == "2" {
                cell.hashNameSub.text = "Trending Croaker"
            }
        }
        cell.videosObj = entityObj["videosObj"] as! [videoMainMVC]
        cell.lblItemCount.text = "\(entityObj["videos_count"] as! String)"
        cell.discoverCollectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = entityDataArr[indexPath.row]
        
        if section == "0" {
            let hashtag = obj["entityName"] as! String
            let vc = storyboard?.instantiateViewController(withIdentifier: "hashtagsVideoVC") as! hashtagsVideoViewController
            vc.hashtag = hashtag
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if section == "1" || section == "2" {
            let user_id = obj["user_id"] as! String
            let vc = storyboard?.instantiateViewController(withIdentifier: "newProfileVC") as! newProfileViewController
            vc.isOtherUserVisting = true
            vc.hidesBottomBarWhenPushed = true
            vc.otherUserID = user_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
    //MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sliderArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "newDiscoverBannerCVC", for: indexPath) as! newDiscoverBannerCollectionViewCell
        
        let obj = sliderArr[indexPath.row]
        let sliderUrl = AppUtility?.detectURL(ipString: obj.img)
        cell.img.sd_setImage(with: URL(string:sliderUrl!), placeholderImage: UIImage(named:"bannerPlaceholder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.discoverBannerCollectionView.frame.size.width, height: 192)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == discoverBannerCollectionView {
            let obj = sliderArr[indexPath.row]
            let sliderUrl = obj.url
            guard let url = URL(string: sliderUrl) else { return }
            UIApplication.shared.open(url)
        }
    }
    
    //    MARK:- SEARCH BTN ACTION
    
    @IBAction func searchBtnAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "discoverSearchVC") as! discoverSearchViewController
        //        let transition = CATransition()
        //        transition.duration = 0.5
        //        transition.type = CATransitionType.fade
        //        transition.subtype = CATransitionSubtype.fromLeft
        //        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        //        view.window!.layer.add(transition, forKey: kCATransition)
        vc.modalPresentationStyle = .overFullScreen
        //        present(vc, animated: false, completion: nil)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: false)
        //        present(vc, animated: false, completion: nil)
    }
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    //MARK: Location
    
    //MARK: Google Maps
    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK:- SLIDER DATA API
    func getSliderData(){
        sliderArr.removeAll()
        ApiHandler.sharedInstance.showAppSlider(section: section) { (isSuccess, response) in
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    
                    let sliderDataArr = response?.value(forKey: "msg") as! NSArray
                    
                    for i in 0..<sliderDataArr.count{
                        let sliderObj = sliderDataArr[i] as! NSDictionary
                        let appSlider = sliderObj.value(forKey: "AppSlider") as! NSDictionary
                        
                        let id = appSlider.value(forKey: "id") as! String
                        let img = appSlider.value(forKey: "image") as! String
                        let url = appSlider.value(forKey: "url") as! String
                        
                        let obj = sliderMVC(id: id, img: img, url: url)
                        
                        self.sliderArr.append(obj)
                    }
                }
                
                self.discoverBannerCollectionView.reloadData()
                self.bannerPageController.numberOfPages = self.sliderArr.count
            }
        }
    }
    
    //    MARK:- VIDEOS DATA API
    func getVideosData() {
        print(section)
        entityDataArr.removeAll()
        ApiHandler.sharedInstance.showDiscoverySections(section: section) { (isSuccess, response) in
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let videosTopics = response?.value(forKey: "msg") as? NSArray
                    for i in 0 ..< (videosTopics?.count ?? 0) {
                        let dic = videosTopics?[i] as! NSDictionary
                        var entityDic = NSDictionary()
                        var entityName = ""
                        var hashtagImg = ""
                        var userID = ""
                        var userImg = ""
                        
                        if self.section == "0" {
                            entityDic = dic.value(forKey: "Hashtag") as! NSDictionary
                            entityName =  entityDic.value(forKey: "name") as! String
                            hashtagImg =  entityDic.value(forKey: "image") as? String ?? ""
                        }
                        else if (self.section == "1" || self.section == "2") {
                            entityDic = dic.value(forKey: "User") as! NSDictionary
                            entityName =  entityDic.value(forKey: "username") as! String
                        }
                        
                        let views = entityDic.value(forKey: "views") as! String
                        let videoCount = "\(entityDic.value(forKey: "videos_count") as? NSNumber ?? 0)"
                        let videosObj = entityDic.value(forKey: "Videos") as! NSArray
                        
                        var videosArr = [videoMainMVC]()
                        videosArr.removeAll()
                        
                        for j in 0 ..< videosObj.count {
                            
                            let videosData = videosObj[j] as! NSDictionary
                            
                            let videoObj = videosData.value(forKey: "Video") as! NSDictionary
                            
                            var userObj = NSDictionary()
                            var soundObj = NSDictionary()
                            var topicObj = NSDictionary()
                            var countryObj = NSDictionary()
                            
                            if self.section == "0" {
                                userObj = videoObj.value(forKey: "User") as! NSDictionary
                                soundObj = videoObj.value(forKey: "Sound") as! NSDictionary
                                topicObj = videosData.value(forKey: "Hashtag") as! NSDictionary
                                countryObj = videoObj.value(forKey: "Country") as! NSDictionary
                            }
                            else if (self.section == "1" || self.section == "2") {
                                userObj = videosData.value(forKey: "User") as! NSDictionary
                                soundObj = videosData.value(forKey: "Sound") as! NSDictionary
                                topicObj = videosData.value(forKey: "Topic") as! NSDictionary
                                countryObj = videosData.value(forKey: "Country") as! NSDictionary
                            }
                            
                            let videoUrl = videoObj.value(forKey: "video") as! String
                            let videoThum = videoObj.value(forKey: "thum") as! String
                            let videoGif = videoObj.value(forKey: "gif") as! String
                            let videoLikes = "\(videoObj.value(forKey: "like_count") ?? "")"
                            let videoComments = "\(videoObj.value(forKey: "comment_count") ?? "")"
                            let like = "\(videoObj.value(forKey: "like") ?? "")"
                            let allowComment = videoObj.value(forKey: "allow_comments") as! String
                            let videoID = videoObj.value(forKey: "id") as! String
                            let videoDesc = videoObj.value(forKey: "description") as! String
                            let allowDuet = videoObj.value(forKey: "allow_duet") as! String
                            let created = videoObj.value(forKey: "created") as! String
                            let views = "\(videoObj.value(forKey: "view") ?? "")"
                            let duetVidID = videoObj.value(forKey: "duet_video_id")
                            
                            userID = userObj.value(forKey: "id") as! String
                            let username = userObj.value(forKey: "username") as! String
                            let userOnline = userObj.value(forKey: "online") as! String
                            userImg = userObj.value(forKey: "profile_pic") as! String
                            //                        let followBtn = userObj.value(forKey: "button") as! String
                            let verified = userObj.value(forKey: "verified")
                            
                            let soundID = soundObj.value(forKey: "id") as! String
                            let soundName = soundObj.value(forKey: "name") as! String
                            let cdPlayer = soundObj.value(forKey: "thum") as! String

                            let topicID = topicObj.value(forKey: "id")
                            let topicName = topicObj.value(forKey: "name")
                            
                            let countryID = countryObj.value(forKey: "id")
                            let countryName = countryObj.value(forKey: "name")
                            
                            let video = videoMainMVC(videoID: videoID, videoUserID: "", fb_id: "", description: videoDesc, videoURL: videoUrl, videoTHUM: videoThum, videoGIF: videoGif, view: views, section: "", sound_id: "", privacy_type: "", allow_comments: allowComment, allow_duet: allowDuet, block: "", duet_video_id: "", old_video_id: "", created: created, like: like, favourite: "", comment_count: videoComments, like_count: videoLikes, followBtn: "", duetVideoID: "\(duetVidID!)", userID: userID, first_name: "", last_name: "", gender: "", bio: "", website: "", dob: "", social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImg, role: "", username: username, social: "", device_token: "", videoCount: "", verified: "\(verified!)", soundName: soundName ?? "",CDPlayer: cdPlayer, topicID: "\(topicID!)", topicName: "\(topicName!)", countryID: "\(countryID!)", countryName: "\(countryName!)")
                            
                            videosArr.append(video)
                        }
                        
                        if self.section == "0" {
                            self.entityDataArr.append(["videosObj":videosArr, "entityName":entityName, "views":views, "videos_count":videoCount, "entity_img":hashtagImg])
                        }
                        else if self.section == "1" || self.section == "2" {
                            self.entityDataArr.append(["videosObj":videosArr, "entityName":entityName, "views":views, "videos_count":videoCount, "user_id":userID, "entity_img":userImg])
                        }
                    }
                    AppUtility?.stopLoader(view: self.view)
                } else {
                    self.showToast(message: "not200", font: .systemFont(ofSize: 12))
                    AppUtility?.stopLoader(view: self.view)
                }
            }
            
            AppUtility?.stopLoader(view: self.view)
            self.setupView()
            self.discoverTblView.reloadData()
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
