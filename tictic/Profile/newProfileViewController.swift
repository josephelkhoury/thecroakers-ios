//
//  newProfileViewController.swift
//  TIK TIK
//
//  Created by Mac on 13/10/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import DropDown
import Lottie
import ContentLoader
class newProfileViewController:UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    //MARK:- Outlets
    
    @IBOutlet weak var userInfoCollectionView: UICollectionView!
    @IBOutlet weak var userItemsCollectionView: UICollectionView!
    @IBOutlet weak var videosCV: UICollectionView!
    @IBOutlet weak var suggestionsCollectionView: UICollectionView!
    @IBOutlet weak var uperViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var suggestionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnFollowEdit: UIButton!
    @IBOutlet weak var btnShowSuggetions: UIButton!
    @IBOutlet weak var viewSuggestion: UIView!
    @IBOutlet weak var btnSuggestionArrow: UIButton!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet var scrollViewOutlet: UIScrollView!
    @IBOutlet var whoopsView: UIView!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet var userImageOutlet: [UIImageView]!
    @IBOutlet weak var userHeaderName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileDropDownBtn: UIButton!
    @IBOutlet weak var btnBackOutlet: UIButton!
  //  @IBOutlet weak var btnChatOutlet: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var OtherUserFollowView: UIView!
    
    var myUser: [User]? {didSet {}}
    var userID = ""
    var otherUserID = ""
    let profileDropDown = DropDown()
    var videosMainArr = [videoMainMVC]()
    var likeVidArr = [videoMainMVC]()
    var privateVidArr = [videoMainMVC]()
    var userVidArr = [videoMainMVC]()
    var userData = [userMVC]()
    var suggestedUsersArr = [suggestionUsersModel]()
    var privacySettingData = [privacySettingMVC]()
    var pushNotiSettingData = [pushNotiSettingMVC]()
    var isOtherUserVisting = false
    var storeSelectedIP = IndexPath(item: 0, section: 0)
    var isSuggExpended = false
    var indexSelected = 0
    var isTagUser = false
    var isTagName = ""
    var userInfo = [["type":"Following","count":"170"],["type":"Followers","count":"60.1K"],["type":"Likes","count":"5.7M"]]
    var userItem = [["Image":"music tok icon-2","ImageSelected":"music tok icon-5","isSelected":"true"],["Image":"likeVideo","ImageSelected":"music tok icon-6","isSelected":"false"],["Image":"music tok icon-1","ImageSelected":"music tok icon-4","isSelected":"false"]]
    
  /*  var suggestionArr = [["Image":"music tok icon-2","ImageSelected":"music tok icon-5","isSelected":"true"],["Image":"likeVideo","ImageSelected":"music tok icon-6","isSelected":"false"],["Image":"music tok icon-1","ImageSelected":"music tok icon-4","isSelected":"false"]]*/
 
    var format = ContentLoaderFormat()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userID = UserDefaults.standard.string(forKey: "userID")!
        
        if (userID != "" && (self.otherUserID == "" || userID == self.otherUserID)) {
            self.isOtherUserVisting = false
        }
        else {
            self.isOtherUserVisting = true
        }
        
        format.color = "#F6F6F6".hexColor
        format.radius = 5
        format.animation = .fade
        view.startLoading(format: format)
        
        print("Search User ID: \(self.otherUserID)")
        self.fetchSuggestedPeopleAPI()
        btnLive.isHidden =  true
        setupDropDowns()
        self.suggestionViewHeight.constant = 0
        self.viewSuggestion.isHidden = true
     
        if #available(iOS 10.0, *) {
            scrollViewOutlet.refreshControl = refresher
        } else {
            scrollViewOutlet.addSubview(refresher)
        }
        
        if isOtherUserVisting {
            userItem = [["Image":"music tok icon-2","ImageSelected":"music tok icon-5","isSelected":"true"],["Image":"likeVideo","ImageSelected":"music tok icon-6","isSelected":"false"]]
        }
        suggestionsCollectionView.delegate = self
        self.btnMessage.setTitle("Message", for: .normal)
        self.btnMessage.backgroundColor = .white
        self.btnMessage.setTitleColor(.black, for: .normal)
        self.btnMessage.layer.borderWidth = 1
        self.btnMessage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        suggestionsCollectionView.dataSource =  self
        print("count: ",userItem.count)
    }
    
    @objc
    func requestData() {
        print("requesting data")
        for i in 0..<self.userItem.count {
            var obj  = self.userItem[i]
            obj.updateValue("false", forKey: "isSelected")
            self.userItem.remove(at: i)
            self.userItem.insert(obj, at: i)
        }
        
        self.StoreSelectedIndex(index: storeSelectedIP.row)
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    //MARK:- WILL APPEAR
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        if (self.navigationController!.viewControllers.count == 1) {
            NSLog("self is RootViewController");
            
            print("self is RootViewController", self.navigationController!.viewControllers.count)
            
            self.tabBarController?.tabBar.isHidden = false
        }
        self.fetchingUserDataFunc()
    }
    
    func fetchingUserDataFunc() {
       // self.userID = UserDefaults.standard.string(forKey: "userID")!  comment:- Arslan
        AppUtility?.startLoader(view: self.view)
        
        if isOtherUserVisting {
            self.btnFollowEdit.setTitle("Follow", for: .normal)
            self.btnFollowEdit.backgroundColor = UIColor(named: "theme")
            self.btnFollowEdit.setTitleColor(.white, for: .normal)
            self.btnFollowEdit.layer.borderWidth = 0
            self.OtherUserFollowView.isHidden =  false
                    
            self.btnShowSuggetions.setImage(UIImage(named: "arrowDown"), for: .normal)
            btnFollow.isHidden = true   //false :- Add icon on user_Profile image
            btnBackOutlet.isHidden = false
            btnLive.isHidden = true
            
            if isTagUser == true {
                self.showOwnDetailByName()
            }else{
                self.getOtherUserDetails()
            }
          
          /*  if indexSelected == 0 {
                self.getUserVideos()
            }else{
                self.getLikedVideos()
            }*/
           
        } else {
            self.userID = UserDefaults.standard.string(forKey: "userID")!
            btnFollow.isHidden = false
            self.getUserDetails()
            self.btnFollowEdit.setTitle("Edit Profile", for: .normal)
            self.btnFollowEdit.backgroundColor = .white
            self.btnFollowEdit.setTitleColor(.black, for: .normal)
            self.btnFollowEdit.layer.borderWidth = 1
            self.OtherUserFollowView.isHidden =  true
            self.btnShowSuggetions.setImage(UIImage(named: "9"), for: .normal)
            
            if (self.navigationController!.viewControllers.count == 1) {
                btnBackOutlet.isHidden = true
                btnLive.isHidden = false
            }
            else {
                btnBackOutlet.isHidden = false
                btnLive.isHidden = true
            }
            self.otherUserID = ""
            //getUserVideos()
            
            let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressVideo))
            lpgr.minimumPressDuration = 0.5
            lpgr.delegate = self
            lpgr.delaysTouchesBegan = true
            self.videosCV.addGestureRecognizer(lpgr)
            
        }
        print("videosArr.count: ",videosMainArr.count)
    }
    
    
    //MARK:- Button Action
    @IBAction func btnChat(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "newChatVC") as! newChatViewController
        vc.receiverData = userData
        vc.otherVisiting = true
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func profileDropDownAction(_ sender: AnyObject) {
        let uid = UserDefaults.standard.string(forKey: "userID")
        if uid == "" || uid == nil{
            loginScreenAppear()
        }else{
            if isOtherUserVisting{
                self.profileDropDown.show()
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewSettingsPrivacyViewController") as! NewSettingsPrivacyViewController
            vc.userData = self.userData
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnLive(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
        vc.userData = self.userData
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden =  true
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
        
    }
    @IBAction func profilePicPressed(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ShareProfileViewController") as! ShareProfileViewController
  //      let vc = storyboard?.instantiateViewController(withIdentifier: "imagePreviewVC") as! ImagePreviewViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.userData =  self.userData//.userProfile_pic
    //    vc.isUserPofile = true
        self.tabBarController!.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnFollowAction(_ sender: Any) {
        if isOtherUserVisting{
            let uid = UserDefaults.standard.string(forKey: "userID")
            if uid == "" || uid == nil{
                loginScreenAppear()
            }else{
                self.followUser(rcvrID: self.otherUserID, userID: UserDefaults.standard.string(forKey: "userID")!, ProfileUserFollow: 1)
            }
         
        } else {
            let vc =  storyboard?.instantiateViewController(withIdentifier: "NewEditProfileViewController") as! NewEditProfileViewController
            vc.userData =  self.userData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSuggArrow(_ sender: Any) {
        if isOtherUserVisting ==  true{
            if self.isSuggExpended == true {
                UIView.animate(withDuration: 0.5) {
                    self.btnShowSuggetions.setImage(UIImage(named: "arrowDown"), for: .normal)
                    self.suggestionViewHeight.constant = 0
                    self.view.layoutIfNeeded()
                    self.isSuggExpended = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.viewSuggestion.isHidden = true
                    }
                }
            } else {
                self.isSuggExpended = true
                UIView.animate(withDuration: 0.5) {
                    self.btnShowSuggetions.setImage(UIImage(named: "arrowUp"), for: .normal)
                    self.suggestionViewHeight.constant = 220
                    self.viewSuggestion.isHidden = false
                    self.view.layoutIfNeeded()
                    
                }
            }
            print("Pressed")
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "favMainVC") as! favMainViewController
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK:- Delgate Functions
    
    @objc func btnFollowFunc(sender : UIButton) {
        print(sender.tag)
        
        let uid = UserDefaults.standard.string(forKey: "userID")
        if uid == "" || uid == nil {
            loginScreenAppear()
        } else {
            followUserFunc(cellNo: sender.tag)
            if sender.currentTitle == "following" {
                sender.setTitle("follow", for: .normal)
                sender.backgroundColor = UIColor(named: "theme")
                sender.setTitleColor(UIColor(named: "theme"), for: .normal)
                sender.setTitleColor(.white, for: .normal)
            } else {
                sender.setTitle("following", for: .normal)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    func followUserFunc(cellNo:Int){
        let suggUser = self.suggestedUsersArr[cellNo]
        let rcvrID = suggUser.id
        let userID = UserDefaults.standard.string(forKey: "userID")
        
        self.followUser(rcvrID: rcvrID!, userID: userID!, ProfileUserFollow: 0)
    }
    
    
    //MARK:- Login screen will appear func
    func loginScreenAppear() {
        let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen
        
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func btnCrossTapped(sender : UIButton) {
        print(sender.tag)
        self.remove(index: sender.tag)
    }
    
    func remove(index: Int) {
        suggestedUsersArr.remove(at: index)
        
        let indexPath = IndexPath(row: index, section: 0)
        suggestionsCollectionView.performBatchUpdates({
            self.suggestionsCollectionView.deleteItems(at: [indexPath])
        }, completion: {
            (finished: Bool) in
            self.suggestionsCollectionView.reloadItems(at: self.suggestionsCollectionView.indexPathsForVisibleItems)
        })
    }
    
    //MARK: CollectionView.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView ==  userInfoCollectionView {
            return self.userInfo.count
        } else if collectionView ==  videosCV {
            return videosMainArr.count
        } else if collectionView == suggestionsCollectionView {
            return self.suggestedUsersArr.count
        } else {
            return self.userItem.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "newProfileItemsCVC", for:indexPath) as! newProfileItemsCollectionViewCell
        
        if collectionView ==  userInfoCollectionView{
            
            cell.lblCount.text =  self.userInfo[indexPath.row]["count"]
            cell.typeFollowing.text = self.userInfo[indexPath.row]["type"]
            
            if indexPath.row ==  self.userInfo.count - 1 {
                cell.verticalView.isHidden = true
            }
            else {
                cell.verticalView.isHidden = false
            }
            
        } else if collectionView == videosCV {
            let videoObj = videosMainArr[indexPath.row]
            let gifURL = AppUtility?.detectURL(ipString: videoObj.videoGIF)
            cell.imgVideoTrimer.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgVideoTrimer.sd_setImage(with: URL(string:(gifURL!)), placeholderImage: UIImage(named:"videoPlaceholder"))
            cell.lblViewerCount.text(videoObj.view)
        } else if collectionView == suggestionsCollectionView {
            let obj = suggestedUsersArr[indexPath.row]
            cell.contentView.layer.cornerRadius = 2
            cell.contentView.layer.masksToBounds = true
            cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgUser.sd_setImage(with: URL(string:(AppUtility?.detectURL(ipString: obj.profile_pic ?? ""))!), placeholderImage: UIImage(named:"videoPlaceholder"))
            cell.lblName.text = (obj.first_name ?? "") + " " + (obj.last_name ?? "")
            cell.lblDesc.text = obj.username
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(btnFollowFunc(sender:)), for: .touchUpInside)
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(btnCrossTapped(sender:)), for: .touchUpInside)
        } else {
            if indexPath.row == 0 {
                if self.userItem[indexPath.row]["isSelected"] == "false" {
                    cell.horizontalView.isHidden  = true
                    cell.imgItems.image = UIImage(named: self.userItem[indexPath.row]["Image"]!)
                } else {
                    cell.horizontalView.isHidden  = false
                    cell.imgItems.image = UIImage(named: self.userItem[indexPath.row]["ImageSelected"]!)
                }
            }
            if indexPath.row == 1 {
                if self.userItem[indexPath.row]["isSelected"] == "false" {
                    cell.horizontalView.isHidden  = true
                    cell.imgItems.image = UIImage(named: self.userItem[indexPath.row]["Image"]!)
                } else {
                    cell.horizontalView.isHidden  = false
                    cell.imgItems.image = UIImage(named: self.userItem[indexPath.row]["ImageSelected"]!)
                }
            }
            if indexPath.row == 2{
                if self.userItem[indexPath.row]["isSelected"] == "false" {
                    cell.horizontalView.isHidden  = true
                    cell.imgItems.image = UIImage(named: self.userItem[indexPath.row]["Image"]!)
                } else {
                    cell.horizontalView.isHidden  = false
                    cell.imgItems.image = UIImage(named: self.userItem[indexPath.row]["ImageSelected"]!)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == userItemsCollectionView{
            
            for i in 0..<self.userItem.count {
                var obj  = self.userItem[i]
                obj.updateValue("false", forKey: "isSelected")
                self.userItem.remove(at: i)
                self.userItem.insert(obj, at: i)
            }
            
            self.StoreSelectedIndex(index: indexPath.row)
            self.indexSelected =  indexPath.row
            self.storeSelectedIP = indexPath
        }
        else if collectionView == userInfoCollectionView {
            print("ip: ",indexPath.row)
            
            if indexPath.row == 0 {
                /*if userData[0].following == "0" {
                    //self.showToast(message: "0 Following", font: .systemFont(ofSize: 12))
                    return
                }*/
                
                let vc = storyboard?.instantiateViewController(withIdentifier: "MainFFSViewController") as! MainFFSViewController
                vc.userData = userData
                vc.SelectedIndex = indexPath.row
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
                /*if userData[0].followers == "0" {
                    //self.showToast(message: "0 Followers", font: .systemFont(ofSize: 12))
                    return
                }*/
                let vc = storyboard?.instantiateViewController(withIdentifier: "MainFFSViewController") as! MainFFSViewController
                vc.userData = userData
                vc.SelectedIndex = indexPath.row
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = storyboard?.instantiateViewController(withIdentifier: "ShowLikesPopUpViewController") as! ShowLikesPopUpViewController
                vc.userData = userData
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
            }
        }
        else if collectionView == videosCV {
            let vc = storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
            vc.videosMainArr = videosMainArr
            vc.currentIndex = indexPath
//            vc.otherUserID =  self.otherUserID
            vc.isOtherController =  true
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func StoreSelectedIndex(index:Int) {
        var obj  =  self.userItem[index]
        obj.updateValue("true", forKey: "isSelected")
        self.userItem.remove(at: index)
        self.userItem.insert(obj, at: index)
        
        if index == 0 {
            print("my vid")
            AppUtility?.startLoader(view: self.view)
            getUserVideos()
            
        } else if index == 1 {
            print("liked")
            AppUtility?.startLoader(view: self.view)
            getLikedVideos()
            
            
        } else {
            print("private")
            AppUtility?.startLoader(view: self.view)
            getPrivateVideos()
            
        }
        self.userItemsCollectionView.reloadData()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let index = Int(self.userItemsCollectionView.contentOffset.x) / Int(self.userItemsCollectionView.frame.width)
        print("index: ",index)
        if index == 0 {
        } else {
        }
        
        let y: CGFloat = scrollView.contentOffset.y
        print(y)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == userInfoCollectionView{
            return CGSize(width: (self.userInfoCollectionView.frame.size.width )/3, height: self.userInfoCollectionView.frame.size.height)
            
        } else  if collectionView == userItemsCollectionView {
            return CGSize(width: Int(self.userItemsCollectionView.frame.size.width)/(self.userItem.count), height: Int(self.userItemsCollectionView.frame.size.height))
            
        } else if collectionView == suggestionsCollectionView {
            return CGSize(width: (self.suggestionsCollectionView.frame.size.width - 34)/3, height: 170)
        } else {
            return CGSize(width: self.videosCV.frame.size.width/3-1, height: 204)
        }
    }
  
    @IBAction func btnBack(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "otherUserID")
        navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        print("toppppppp")
    }
    //MARK:- API Handler
    
    // GET USER OWN DETAILS
    func getUserDetails() {
        self.userData.removeAll()
        ApiHandler.sharedInstance.showOwnDetail(user_id: self.userID) { (isSuccess, response) in
            if isSuccess{
               self.view.hideLoading()
                
                print("response UserDetails : ",response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let userObjMsg = response?.value(forKey: "msg") as! NSDictionary
                    let userObj = userObjMsg.value(forKey: "User") as! NSDictionary
                    
                    let privSettingObj = userObjMsg.value(forKey: "PrivacySetting") as! NSDictionary
                    let pushNotiSettingObj = userObjMsg.value(forKey: "PushNotification") as! NSDictionary
                    
                    // PRIVACY SETTING DATA
                    let direct_message = privSettingObj.value(forKey: "direct_message") as! String
                    let duet = privSettingObj.value(forKey: "duet") as! String
                    let liked_videos = privSettingObj.value(forKey: "liked_videos") as! String
                    let video_comment = privSettingObj.value(forKey: "video_comment") as! String
                    let videos_download = privSettingObj.value(forKey: "videos_download")
                    let privID = privSettingObj.value(forKey: "id")
                    
                    let privObj = privacySettingMVC(direct_message: direct_message, duet: duet, liked_videos: liked_videos, video_comment: video_comment, videos_download: "\(videos_download!)", id: "\(privID!)")
                    self.privacySettingData.append(privObj)
                    
                    // PUSH NOTIFICATION SETTING DATA
                    let cmnt = pushNotiSettingObj.value(forKey: "comments")
                    let direct_messages = pushNotiSettingObj.value(forKey: "direct_messages")
                    let likes = pushNotiSettingObj.value(forKey: "likes")
                    let pushID = pushNotiSettingObj.value(forKey: "id")
                    let new_followers = pushNotiSettingObj.value(forKey: "new_followers")
                    let video_updates = pushNotiSettingObj.value(forKey: "video_updates")
                    let mentions = pushNotiSettingObj.value(forKey: "mentions")
                    
                    let pushObj = pushNotiSettingMVC(comments: "\(cmnt!)", direct_messages: "\(direct_messages!)", likes: "\(likes!)", mentions: "\(mentions!)", new_followers: "\(new_followers!)", video_updates: "\(video_updates!)", id: "\(pushID!)")
                    
                    self.pushNotiSettingData.append(pushObj)
                    
                    let userImage = (userObj.value(forKey: "profile_pic") as? String)!
                    let userName = (userObj.value(forKey: "username") as? String)!
                    let followers = "\(userObj.value(forKey: "followers_count") ?? "")"
                    let followings = "\(userObj.value(forKey: "following_count") ?? "")"
                    let likesCount = "\(userObj.value(forKey: "likes_count") ?? "")"
                    let videoCount = "\(userObj.value(forKey: "video_count") ?? "")"
                    let firstName = (userObj.value(forKey: "first_name") as? String)!
                    let lastName = (userObj.value(forKey: "last_name") as? String)!
                    let gender = (userObj.value(forKey: "gender") as? String)!
                    let bio = (userObj.value(forKey: "bio") as? String)!
                    let dob = (userObj.value(forKey: "dob") as? String)!
                    let website = (userObj.value(forKey: "website") as? String)!
                    let wallet = (userObj.value(forKey: "wallet") as? String)!
                    let paypal = (userObj.value(forKey: "paypal") as? String)!
                    let userId = (userObj.value(forKey: "id") as? String)!
                    UserDefaults.standard.setValue(wallet, forKey: "wallet")
                    
                    print("profile_pic:",userImage)
                    
                    let user = userMVC(userID: userId, first_name: firstName, last_name: lastName, gender: gender, bio: bio, website: website, dob: dob, social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImage, role: "", username: userName, social: "", device_token: "", videoCount: videoCount, likesCount: likesCount, followers: followers, following: followings, followBtn: "",wallet:wallet,paypal:paypal)
                    
                    self.userData.append(user)
                    
                    self.setProfileData()
                } else {
                    print("showOwnDetail API:",response?.value(forKey: "msg") as Any)
                }
                
            } else {
                print("showOwnDetail API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
    
    // GET other USER DETAILS By Name

    func showOwnDetailByName() {
        self.userData.removeAll()
        var uid = ""
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID != nil || userID != ""{
            uid = userID!
        }
        
        ApiHandler.sharedInstance.showOwnDetailByName(username: self.isTagName, user_id:uid) { (isSuccess, response) in
            if isSuccess{
               self.view.hideLoading()
                
                print("response UserDetails : ", response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let userObjMsg = response?.value(forKey: "msg") as! NSDictionary
                    let userObj = userObjMsg.value(forKey: "User") as! NSDictionary
                    
                    let privSettingObj = userObjMsg.value(forKey: "PrivacySetting") as! NSDictionary
                    let pushNotiSettingObj = userObjMsg.value(forKey: "PushNotification") as! NSDictionary
                    
                    // PRIVACY SETTING DATA
                    let direct_message = privSettingObj.value(forKey: "direct_message") as! String
                    let duet = privSettingObj.value(forKey: "duet") as! String
                    let liked_videos = privSettingObj.value(forKey: "liked_videos") as! String
                    let video_comment = privSettingObj.value(forKey: "video_comment") as! String
                    let videos_download = privSettingObj.value(forKey: "videos_download")
                    let privID = privSettingObj.value(forKey: "id")
                    
                    let privObj = privacySettingMVC(direct_message: direct_message, duet: duet, liked_videos: liked_videos, video_comment: video_comment, videos_download: "\(videos_download!)", id: "\(privID!)")
                    self.privacySettingData.append(privObj)
                    
                    // PUSH NOTIFICATION SETTING DATA
                    let cmnt = pushNotiSettingObj.value(forKey: "comments")
                    let direct_messages = pushNotiSettingObj.value(forKey: "direct_messages")
                    let likes = pushNotiSettingObj.value(forKey: "likes")
                    let pushID = pushNotiSettingObj.value(forKey: "id")
                    let new_followers = pushNotiSettingObj.value(forKey: "new_followers")
                    let video_updates = pushNotiSettingObj.value(forKey: "video_updates")
                    let mentions = pushNotiSettingObj.value(forKey: "mentions")
                    
                    let pushObj = pushNotiSettingMVC(comments: "\(cmnt!)", direct_messages: "\(direct_messages!)", likes: "\(likes!)", mentions: "\(mentions!)", new_followers: "\(new_followers!)", video_updates: "\(video_updates!)", id: "\(pushID!)")
                    
                    self.pushNotiSettingData.append(pushObj)
                    
                    let userImage = (userObj.value(forKey: "profile_pic") as? String)!
                    let userName = (userObj.value(forKey: "username") as? String)!
                    let followers = "\(userObj.value(forKey: "followers_count") ?? "")"
                    let followings = "\(userObj.value(forKey: "following_count") ?? "")"
                    let likesCount = "\(userObj.value(forKey: "likes_count") ?? "")"
                    let videoCount = "\(userObj.value(forKey: "video_count") ?? "")"
                    let firstName = (userObj.value(forKey: "first_name") as? String)!
                    let lastName = (userObj.value(forKey: "last_name") as? String)!
                    let gender = (userObj.value(forKey: "gender") as? String)!
                    let bio = (userObj.value(forKey: "bio") as? String)!
                    let dob = (userObj.value(forKey: "dob") as? String)!
                    let website = (userObj.value(forKey: "website") as? String)!
                    let wallet = (userObj.value(forKey: "wallet") as? String)!
                    let paypal = (userObj.value(forKey: "paypal") as? String)!
                    let userId = (userObj.value(forKey: "id") as? String)!
                    UserDefaults.standard.setValue(wallet, forKey: "wallet")
                    self.otherUserID =  userId
                    print("profile_pic:",userImage)
                    
                    let user = userMVC(userID: userId, first_name: firstName, last_name: lastName, gender: gender, bio: bio, website: website, dob: dob, social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImage, role: "", username: userName, social: "", device_token: "", videoCount: videoCount, likesCount: likesCount, followers: followers, following: followings, followBtn: "",wallet:wallet,paypal:paypal)
                    
                    self.userData.append(user)
                    
                    self.setProfileData()
                } else {
                    print("showOwnDetail API:",response?.value(forKey: "msg") as Any)
                }
                
            } else {
                print("showOwnDetail API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
    
    // GET other USER DETAILS
    func getOtherUserDetails() {
        self.userData.removeAll()
        
        var uid = ""
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID != "" && userID != nil {
            uid = userID!
        } else {
            uid = self.otherUserID
        }
        
        print("otheruser: ", self.otherUserID)
        print("userID: ", self.userID)
        
        ApiHandler.sharedInstance.showOtherUserDetail(user_id: uid, other_user_id: self.otherUserID) { (isSuccess, response) in
            
            self.view.hideLoading()
            if isSuccess {
                
                print("response OtherUserDetails: ",response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let userObjMsg = response?.value(forKey: "msg") as! NSDictionary
                    let userObj = userObjMsg.value(forKey: "User") as! NSDictionary
                    
                    let userImage = (userObj.value(forKey: "profile_pic") as? String)!
                    let userName = (userObj.value(forKey: "username") as? String)!
                    let followers = "\(userObj.value(forKey: "followers_count") ?? "")"
                    let followings = "\(userObj.value(forKey: "following_count") ?? "")"
                    let likesCount = "\(userObj.value(forKey: "likes_count") ?? "")"
                    let videoCount = "\(userObj.value(forKey: "video_count") ?? "")"
                    let firstName = (userObj.value(forKey: "first_name") as? String)!
                    let lastName = (userObj.value(forKey: "last_name") as? String)!
                    let gender = (userObj.value(forKey: "gender") as? String)!
                    let bio = (userObj.value(forKey: "bio") as? String)!
                    let dob = (userObj.value(forKey: "dob") as? String)!
                    let website = (userObj.value(forKey: "website") as? String)!
                    let followBtn = (userObj.value(forKey: "button") as? String)!
                    let wallet = (userObj.value(forKey: "wallet") as? String)!
                    let paypal = (userObj.value(forKey: "paypal") as? String)!
                    
                    UserDefaults.standard.setValue(wallet, forKey: "wallet")
                    
                    let userId = (userObj.value(forKey: "id") as? String)!
                    
                    let user = userMVC(userID: userId, first_name: firstName, last_name: lastName, gender: gender, bio: bio, website: website, dob: dob, social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImage, role: "", username: userName, social: "", device_token: "", videoCount: videoCount, likesCount: likesCount, followers: followers, following: followings, followBtn: followBtn, wallet: wallet,paypal:paypal)
                    
                    self.userData.append(user)
                    self.setProfileData()
                } else {
                    print("showOtherUserDetail API:",response?.value(forKey: "msg") as Any)
                }
                
            } else {
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                print("showOtherUserDetail API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
    
    //  GET USERS VIDEOS
    func getUserVideos() {
        print("userID test: ",userID)
        self.userVidArr.removeAll()
        self.videosMainArr.removeAll()
        
        var uid = ""
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID != "" && userID != nil {
            uid = userID!
        } else {
            uid = self.otherUserID
        }
        
        ApiHandler.sharedInstance.showVideosAgainstUserID(user_id: uid, other_user_id: self.otherUserID) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess{
                print("response: ",response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let userObjMsg = response?.value(forKey: "msg") as! NSDictionary
                    let userPublicObj = userObjMsg.value(forKey: "public") as! NSArray
                    
                    for i in 0..<userPublicObj.count{
                        let publicObj  = userPublicObj.object(at: i) as! NSDictionary
                        
                        let videoObj = publicObj.value(forKey: "Video") as! NSDictionary
                        let userObj = publicObj.value(forKey: "User") as! NSDictionary
                        let soundObj = publicObj.value(forKey: "Sound") as! NSDictionary
                        let topicObj = publicObj.value(forKey: "Topic") as! NSDictionary
                        let countryObj = publicObj.value(forKey: "Country") as! NSDictionary
                        
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
                        
                        self.userVidArr.append(video)
                    }
                    
                }
                self.videosMainArr = self.userVidArr
                if self.videosMainArr.isEmpty == true {
                    self.whoopsView.isHidden = false
                } else {
                    self.whoopsView.isHidden = true
                }
                
                print("videosMainArr.count: ",self.videosMainArr.count)
                
                self.videosCV.reloadData()
                
                let height = self.videosCV.collectionViewLayout.collectionViewContentSize.height + 30
                self.uperViewHeightConst.constant = height
                print("height: ",height)
                self.view.layoutIfNeeded()
                self.videosCV.reloadData()
            }else{
                print("showVideosAgainstUserID API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
    
    // GET LIKED VIDEOS
    func getLikedVideos() {
        print("userID test: ",userID)
        self.likeVidArr.removeAll()
        self.videosMainArr.removeAll()
        
        var uid = ""
        if otherUserID != "" {
            uid = self.otherUserID
        } else {
            uid = self.userID
        }

        ApiHandler.sharedInstance.showUserLikedVideos(user_id: uid) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess{
                print("response: ",response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let likeObjMsg = response?.value(forKey: "msg") as! NSArray
                    
                    for i in 0..<likeObjMsg.count{
                        let likeObj  = likeObjMsg.object(at: i) as! NSDictionary
                        
                        if let videoObj = likeObj.value(forKey: "Video") as? NSDictionary {
                            print(videoObj.value(forKey: "User"))
                            let userObj = videoObj.value(forKey: "User") as? NSDictionary
                            let topicObj = videoObj.value(forKey: "Topic") as! NSDictionary
                            let countryObj = videoObj.value(forKey: "Country") as! NSDictionary
                            
                            if videoObj.value(forKey: "video") is NSNull{}else{
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
                                
                                let userID = userObj?.value(forKey: "id") as! String
                                let username = userObj?.value(forKey: "username") as! String
                                let userOnline = userObj?.value(forKey: "online") as! String
                                let userImg = userObj?.value(forKey: "profile_pic") as! String
                                let verified = userObj?.value(forKey: "verified")
                                
                                let topicID = topicObj.value(forKey: "id")
                                let topicName = topicObj.value(forKey: "name")
                                
                                let countryID = countryObj.value(forKey: "id")
                                let countryName = countryObj.value(forKey: "name")
                                
                                let video = videoMainMVC(videoID: videoID, videoUserID: "", fb_id: "", description: videoDesc, videoURL: videoUrl, videoTHUM: videoThum, videoGIF: videoGif, view: views, section: "", sound_id: "", privacy_type: "", allow_likes: allowLikes, allow_comments: allowComments, allow_duet: allowDuet, block: "", main_video_id: "\(main_video_id!)", duet_video_id: "", old_video_id: "", created: created, like: like, favourite: "", comment_count: videoComments, like_count: videoLikes, followBtn: "", duetVideoID: "\(duetVidID!)", userID: userID, first_name: "", last_name: "", gender: "", bio: "", website: "", dob: "", social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImg, role: "", username: username, social: "", device_token: "", videoCount: "", verified: "\(verified ?? "")", soundName:  "",CDPlayer: "", topicID: "\(topicID!)", topicName: "\(topicName!)", countryID: "\(countryID!)", countryName: "\(countryName!)")
                                
                                self.likeVidArr.append(video)
                            }
                        }
                    }
                }
                self.videosMainArr = self.likeVidArr
                if self.videosMainArr.isEmpty == true {
                    self.whoopsView.isHidden = false
                } else {
                    self.whoopsView.isHidden = true
                }
                self.videosCV.reloadData()
                let height = self.videosCV.collectionViewLayout.collectionViewContentSize.height
                self.uperViewHeightConst.constant = height
                print("height: ",height)
                self.view.layoutIfNeeded()
                self.videosCV.reloadData()
                
            } else {
                print("showVideosAgainstUserID API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
    
    //GET PRIVATE VIDEOS
    func getPrivateVideos() {
        print("userID test: ",userID)
        self.likeVidArr.removeAll()
        self.videosMainArr.removeAll()
        
        var uid = ""
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID != "" && userID != nil {
            uid = userID!
        } else {
            uid = self.otherUserID
        }
        
        ApiHandler.sharedInstance.showVideosAgainstUserID(user_id: uid, other_user_id: self.otherUserID) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess{
                print("response: ",response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let userObjMsg = response?.value(forKey: "msg") as! NSDictionary
                    let userPrivateObj = userObjMsg.value(forKey: "private") as! NSArray
                    
                    for i in 0..<userPrivateObj.count{
                        let privateObj  = userPrivateObj.object(at: i) as! NSDictionary
                        
                        let videoObj = privateObj.value(forKey: "Video") as! NSDictionary
                        let userObj = privateObj.value(forKey: "User") as! NSDictionary
                        let soundObj = privateObj.value(forKey: "Sound") as! NSDictionary
                        let topicObj = privateObj.value(forKey: "Topic") as! NSDictionary
                        let countryObj = privateObj.value(forKey: "Country") as! NSDictionary
                        
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
                        
                        self.privateVidArr.append(video)
                    }
                    
                }
                self.videosMainArr = self.privateVidArr
                if self.videosMainArr.isEmpty == true {
                    self.whoopsView.isHidden = false
                } else {
                    self.whoopsView.isHidden = true
                }
                self.videosCV.reloadData()
                
                let height = self.videosCV.collectionViewLayout.collectionViewContentSize.height
                self.uperViewHeightConst.constant = height
                print("height: ",height)
                self.view.layoutIfNeeded()
                self.videosCV.reloadData()
                
            }else{
                print("showVideosAgainstUserID API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
    // Follow user API
    func followUser(rcvrID:String,userID:String,ProfileUserFollow:Int){
        
        print("Recid: ",rcvrID)
        print("senderID: ",userID)
        
        AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.followUser(sender_id: userID, receiver_id: rcvrID) { (isSuccess, response) in
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    AppUtility?.stopLoader(view: self.view)
                    
                    if ProfileUserFollow == 1 {
                        if let resmsg =  response?.value(forKey: "msg") as? [String:Any] {
                            let objUser =  resmsg["User"] as! [String:Any]
                            if objUser["button"] as! String == "follow" {
                                self.btnFollowEdit.setTitle("Follow", for: .normal)
                                self.OtherUserFollowView.isHidden =  true
                            } else {
                                self.OtherUserFollowView.isHidden =  false
                            }
                    }
                }
                    //                    self.fetchSuggestedPeopleAPI()
                }else {
                    AppUtility?.stopLoader(view: self.view)
                    self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
                }
                
            }else {
                AppUtility?.stopLoader(view: self.view)
                self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
            }
        }
    }
  //MARK:- Setup Profile Data
    func setProfileData() {
        let user = userData[0]
        self.userInfo = [["type":"Following","count":user.following],["type":"Followers","count":user.followers],["type":"Likes","count":user.likesCount]]
        print(user.followBtn)
        if isOtherUserVisting == true {
            if user.followBtn == "follow" || user.followBtn == "follow back" {
                if user.followBtn == "follow" {
                    self.btnFollowEdit.setTitle("Follow", for: .normal)
                }
                else if user.followBtn == "follow back" {
                    self.btnFollowEdit.setTitle("Follow back", for: .normal)
                }
                self.OtherUserFollowView.isHidden =  true
            } else {
                self.OtherUserFollowView.isHidden =  false
                self.btnMessage.setTitle("Message", for: .normal)
                self.btnMessage.backgroundColor = .white
                self.btnMessage.setTitleColor(.black, for: .normal)
                self.btnMessage.layer.borderWidth = 1
                self.btnMessage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        }
        let profilePic = AppUtility?.detectURL(ipString: user.userProfile_pic)
        self.userName.text = "@\(user.username)"
        self.userHeaderName.text = user.first_name+" "+user.last_name
        for img in userImageOutlet {
            img.sd_imageIndicator = SDWebImageActivityIndicator.gray
            img.sd_setImage(with: URL(string:profilePic!), placeholderImage: UIImage(named: "noUserImg"))
        }
        
        if indexSelected == 0 {
            self.getUserVideos()
        } else {
            self.getLikedVideos()
        }
        
        userInfoCollectionView.reloadData()
    }
    
    //MARK:- Setup Drop Down
    func setupDropDowns() {
        profileDropDown.width = 150
        profileDropDown.anchorView = profileDropDownBtn
        profileDropDown.backgroundColor = .white
        profileDropDown.bottomOffset = CGPoint(x: 0, y: profileDropDownBtn.bounds.height)
        
        if isOtherUserVisting == true {
            btnBackOutlet.isHidden = false
            profileDropDown.dataSource = [
                "Report",
                "Block"
            ]
        } else {
            btnBackOutlet.isHidden = true
            profileDropDown.dataSource = [
                "Edit Profile",
                "Favourite",
                "Setting",
                "Payout",
                "Wallet",
                "Logout"
            ]
        }
        
        profileDropDown.selectionAction = { [weak self] (index, item) in
            switch item {
            case "Report":
                print("selected item: ",item)
                
                let alertController = UIAlertController(title: "REPORT", message: "Enter the details of Report", preferredStyle: .alert)
                
                alertController.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = "Report Title"
                }
                
                let reportAction = UIAlertAction(title: "Report", style: .default, handler: { alert -> Void in
                    let firstTextField = alertController.textFields![0] as UITextField
                    let secondTextField = alertController.textFields![1] as UITextField
                    
                    print("fst txt: ",firstTextField)
                    print("scnd txt: ",secondTextField.text)
                    
                    guard let text = secondTextField.text, !text.isEmpty else {
                        self?.showToast(message: "Fill All Fields", font: .systemFont(ofSize: 12))
                        return
                    }
                    self!.reportUser(reportReason: text)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
                
                alertController.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = "Reason"
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(reportAction)
                
                self!.present(alertController, animated: true, completion: nil)
                
            case "Block":
                print("selected item: ",item)
                self!.blockUser()
                
            case "Edit Profile":
                print("selected item: ",item)
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "NewEditProfileViewController") as! NewEditProfileViewController
                 vc.userData = self!.userData
                 vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
                
            case "Favourite":
                print("selected item: ",item)
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "favMainVC") as! favMainViewController
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
                
            case "Setting":
                print("selected item: ",item)
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "NewSettingsPrivacyViewController") as! NewSettingsPrivacyViewController
                vc.userData = self!.userData
                  vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
                
            case "Payout":
                print("selected item: ",item)
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "PayoutViewController") as! PayoutViewController
                vc.hidesBottomBarWhenPushed = true
                vc.user = self!.userData
                self?.navigationController?.pushViewController(vc, animated: true)
                
            case "Wallet":
                print("selected item: ",item)
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "MyWalletVC") as! MyWalletViewController
                vc.hidesBottomBarWhenPushed = true
                vc.userData = self!.userData
                self?.navigationController?.pushViewController(vc, animated: true)
                
            case "Logout":
                print("select item: ",item)
                
                self?.tabBarController?.selectedIndex = 0
                
                self?.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self?.tabBarController?.tabBar.unselectedItemTintColor = UIColor.white
                var myUser: [User]? {didSet {}}
                myUser = User.readUserFromArchive()
                myUser?.removeAll()
                
                self!.logoutUserApi()
                
            default:
                print("select item: ",item)
            }
        }
    }
    
    //block User
    func blockUser() {
        AppUtility?.startLoader(view: self.view)
        let uid = UserDefaults.standard.string(forKey: "userID")
        let otherUid = UserDefaults.standard.string(forKey: "otherUserID")
        
        print("block uid: \(uid) blockUid: \(otherUid)")
        ApiHandler.sharedInstance.blockUser(user_id: uid!, block_user_id: otherUid!) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    self.showToast(message: "Blocked", font: .systemFont(ofSize: 12))
                    self.navigationController?.popToRootViewController(animated: true)
                    
                } else {
                    print("blockUser API:",response?.value(forKey: "msg") as! String)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    //Logout User
    func logoutUserApi(){
        let userID = UserDefaults.standard.string(forKey: "userID")
        print("user id: ",userID as Any)
        AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.logout(user_id: userID! ) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    print(response?.value(forKey: "msg") as Any)
                    UserDefaults.standard.set("", forKey: "userID")
                } else {
                    print("logout API:",response?.value(forKey: "msg") as! String)
                }
            } else {
                print("logout API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
    
    //Report user func
    func reportUser(reportReason: String) {
        AppUtility?.startLoader(view: self.view)
        
        print("report user id: \(otherUserID) userID: \(UserDefaults.standard.string(forKey: "userID")!)")
        
        ApiHandler.sharedInstance.reportUser(user_id: UserDefaults.standard.string(forKey: "userID")!, report_user_id: otherUserID, report_reason_id: "1", description: reportReason) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    self.showToast(message: "Report Under Review", font: .systemFont(ofSize: 12))
                }else{
                    print("reportUser API:",response?.value(forKey: "msg") as Any)
                }
            } else {
                print("reportUser API:",response?.value(forKey: "msg") as Any)
                
            }
        }
    }
    
    // DELETE VIDEO
    func deleteVideoAPI(indexPath:IndexPath) {
        let videoID = videosMainArr[indexPath.row].videoID
        AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.deleteVideo(video_id: videoID) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                let code = response?.value(forKey: "code") as! NSNumber
                if code == 200 {
                    DispatchQueue.main.async {
                        self.videosMainArr.remove(at: indexPath.row)
                        self.videosCV.deleteItems(at: [indexPath])
                    }
                } else {
                    AppUtility?.displayAlert(title: "Try Again", message: "Something went Wrong")
                }
            }
        }
    }
    
    //Fetch Seuggesed user
    func fetchSuggestedPeopleAPI() {
        self.suggestedUsersArr.removeAll()
        AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.suggestedPeople(user_id: self.otherUserID) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                if  response?.value(forKey: "code") as! NSNumber ==  200 {
                    let msgArr = response?.value(forKey: "msg") as? NSArray
                    for msg in msgArr ?? []{
                        let msgDict = msg as? NSDictionary
                        let userDict = msgDict?.value(forKey: "User")
                        let decoder = JSONDecoder()
                        
                        do {
                            let data = try JSONSerialization.data(withJSONObject: userDict as Any, options: .prettyPrinted)
                            let userM = try decoder.decode(suggestionUsersModel.self, from: data)
                            self.suggestedUsersArr.append(userM)
                            print("un: ", userM.username)
                            
                        } catch {
                            print("catch: ",error.localizedDescription)
                        }
                    }
                    self.suggestionsCollectionView.reloadData()
                } else {
                    print("!200: ",response as Any)
                }
            }
        }
    }
    //MARK:- Alert
    
    func alertModule(title:String,msg:String){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK:- handleLongPressVideo
    @objc func handleLongPressVideo(gestureReconizer: UILongPressGestureRecognizer) {

        print("longPressed")
        let p = gestureReconizer.location(in: self.videosCV)
        
        if let indexPath : IndexPath = (self.videosCV?.indexPathForItem(at: p)) as IndexPath?{
            let alert = UIAlertController(title: "Delete Video", message: "Are you sure you want to delete the item?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.deleteVideoAPI(indexPath: indexPath)
            }
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)

            present(alert, animated: true, completion: nil)
        }
    }
}

extension newProfileViewController: ContentLoaderDataSource {
    
    func numSections(in contentLoaderView: UIView) -> Int {
        return 1
    }
    
    func contentLoaderView(_ contentLoaderView: UIView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func contentLoaderView(_ contentLoaderView: UIView, cellIdentifierForItemAt indexPath: IndexPath) -> String {
        if contentLoaderView == userInfoCollectionView {
            
        }
        return "newProfileItemsCVC"
    }
}
