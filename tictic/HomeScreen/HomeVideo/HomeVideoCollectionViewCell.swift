//
//  HomeVideoCollectionViewCell.swift
//  MusicTok
//
//  Created by Mac on 06/08/2021.
//  Copyright © 2021 MAC. All rights reserved.
//



import UIKit
import AVFoundation
import GSPlayer
import MarqueeLabel
import DSGradientProgressView
import SDWebImage

protocol videoLikeDelegate: class {
    func updateObj(obj: videoMainMVC , index: Int,islike:Bool)
}

class HomeVideoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var progressView: DSGradientProgressView!
    @IBOutlet weak var nameBtn: UIButton!
    @IBOutlet weak var captionLbl: AttrTextView!
    @IBOutlet weak var musicLbl: MarqueeLabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var statusProfile: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentCountLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var musicBtn: UIButton!
    @IBOutlet weak var sourceRepliesLbl: UILabel!
    @IBOutlet weak var imgMusicBtn: UIImageView!
    @IBOutlet weak var pauseImgView: UIImageView!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var replyLbl: UILabel!
    
    // MARK: - Variables
    
    private(set) var isPlaying = false
    var isUserPaused = false
    private(set) var liked = false
    private(set) var liked_count:Int!
    @IBOutlet weak var heightTV: NSLayoutConstraint!
    
    var arrVideo: videoMainMVC?
    var videoURL: String?
    weak var delegate: videoLikeDelegate?
    var delegateHomeVideoVC:HomeVideoViewController!

    // MARK: Lifecycles
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK:- awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("commentVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("pauseVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("playVideo"), object: nil)
        self.setupView()
    }
    
    //MARK:- Deinit Notification
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("commentVideo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("pauseVideo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("playVideo"), object: nil)
    }
    
    //MARK:- SetupView
    func setupView() {
        pauseImgView.isHidden = true
        playerView.contentMode = .scaleAspectFill
        self.profileImgView.makeRounded()
        //self.imgMusicBtn.makeRounded()
        //self.musicBtn.makeRounded()
        self.videoPlayer()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        playerView.isUserInteractionEnabled = true
        self.playerView.addGestureRecognizer(tap)
    }
    
    //MARK:- Configuration
    
    func configure(post: videoMainMVC) {
        self.arrVideo = post
        self.nameBtn.setTitle("@" + post.username, for: .normal)
        self.nameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        self.profileImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        let userImgPath = AppUtility?.detectURL(ipString: post.userProfile_pic)
        let userImgUrl = URL(string: userImgPath!)
        self.profileImgView.sd_setImage(with: userImgUrl, placeholderImage: UIImage(named: "noUserNew"))
        
        let playerIcon = AppUtility?.detectURL(ipString: post.CDPlayer)
        let CDPlayerUrl = URL(string: playerIcon!)
        //self.imgMusicBtn.sd_setImage(with:CDPlayerUrl, placeholderImage: UIImage(named: ""))
        
        self.musicLbl.text = post.soundName
        self.likeCountLbl.text = post.like_count ?? "0".shorten()
        self.commentCountLbl.text = post.comment_count ?? "0".shorten()
        self.liked_count = Int(post.like_count) ?? 0
        
        if post.allow_likes == "false" {
            self.likeBtn.isHidden = true
            self.likeCountLbl.isHidden = true;
        }
        else {
            self.likeBtn.isHidden = false
            self.likeCountLbl.isHidden = false;
        }
        
        if post.allow_comments == "false" {
            self.commentBtn.isHidden = true
            self.commentCountLbl.isHidden = true;
        }
        else {
            self.commentBtn.isHidden = false
            self.commentCountLbl.isHidden = false;
        }
        
        if post.verified == "0" {
            self.statusProfile.isHidden = true
        }
        
        if post.like ==  "1" {
            //likeBtn.tintColor = .red
            likeBtn.isSelected = true
            liked = true
        } else {
            //likeBtn.tintColor = .white
            likeBtn.isSelected = false
            liked = false
        }
        
        if post.allow_duet == "0" {
            replyBtn.isHidden = true;
            replyLbl.isHidden = true;
        } else {
            replyBtn.isHidden = false;
            replyLbl.isHidden = false;
        }
        
        let duetVidID = post.duetVideoID
        
        if duetVidID != "0" {
            self.playerView.contentMode = .scaleAspectFit
        } else {
            self.playerView.contentMode = .scaleAspectFill
        }
        
        if self.arrVideo?.main_video_id != "<null>" {
            musicBtn.isSelected = true
            sourceRepliesLbl.text = "Original"
        } else {
            musicBtn.isSelected = false
            sourceRepliesLbl.text = "Croaks"
        }
        
        self.captionLbl.setText(text: post.description,textColor: .white, withHashtagColor: #colorLiteral(red: 0.7580462098, green: 0.8360280395, blue: 0.4221232533, alpha: 1), andMentionColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), andCallBack: { (strng, type) in
            
            switch type {
                case .hashtag:
                    if let rootViewController = UIApplication.topViewController() {
                        let storyMain = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyMain.instantiateViewController(withIdentifier: "hashtagsVideoVC") as! hashtagsVideoViewController
                        vc.hashtag = strng
                        vc.hidesBottomBarWhenPushed = true
                        rootViewController.navigationController?.pushViewController(vc, animated: true)
                    }
                    break
                    
                case .mention:
                    if let rootViewController = UIApplication.topViewController() {
                        let storyMain = UIStoryboard(name: "Main", bundle: nil)
                        
                        let vc = storyMain.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
                        vc.isOtherUserVisting = true
                        vc.hidesBottomBarWhenPushed = true
                        vc.isTagName = strng
                        vc.isTagUser  =  true
                        vc.otherUserID = "-1"
                        rootViewController.navigationController?.pushViewController(vc, animated: true)
                    }
                    break
            }
            
        }, normalFont: .systemFont(ofSize: 12, weight: UIFont.Weight.medium), hashTagFont: .systemFont(ofSize: 12, weight: UIFont.Weight.bold), mentionFont: .systemFont(ofSize: 12, weight: UIFont.Weight.bold))
        
        let numberLines = captionLbl.numberOfLines(textView: captionLbl)
        self.heightTV.constant =  CGFloat(numberLines * 24)
        
        self.videoURL = AppUtility?.detectURL(ipString: self.arrVideo!.videoURL)
    }
    
    func replay() {
        if !isPlaying {
            playerView.play(for: URL(string: self.videoURL!) as! URL,filterName:"",filterIndex:0)
            play()
        }
    }
    
    func play() {
        musicLbl.holdScrolling = false
        playerView.play(for: URL(string: self.videoURL!) as! URL,filterName:"",filterIndex:0)
        playerView.isHidden = false
        isPlaying = true
    }
    
    func pause() {
        playerView.pause(reason: .hidden)
        musicLbl.holdScrolling = true
        isPlaying = false
    }
    
    @objc func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        print("singletapped")
      
            if self.playerView.state == .playing {
                self.playerView.pause(reason: .userInteraction)
                self.pauseImgView.isHidden = false
            } else {
                self.pauseImgView.isHidden = true
                self.playerView.resume()
            }
    }
   
    //MARK:- Player
    
    func videoPlayer() {
        playerView.stateDidChanged = { state in
            switch state {
                case .none:
                    print("none")
                case .error(let error):
                    self.progressView.wait()
                    self.progressView.isHidden = false
                    
                    NotificationCenter.default.post(name: Notification.Name("errInPlay"), object: nil, userInfo: ["err":error.localizedDescription])
                case .loading:
                    self.progressView.wait()
                    self.progressView.isHidden = false
                case .paused(let playing, let buffering):
                    self.progressView.signal()
                    self.progressView.isHidden = true
                    //self.musicBtn.stopRotating()
                    //self.imgMusicBtn.stopRotating()
                case .playing:
                    self.pauseImgView.isHidden = true
                    self.progressView.isHidden = true
                    //self.musicBtn.startRotating()
                    //self.imgMusicBtn.startRotating()
            }
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func postReply(_ sender: AnyObject) {
        pause()
        if (UserDefaults.standard.string(forKey: "userID") == "" || UserDefaults.standard.string(forKey: "userID") == nil) {
            delegateHomeVideoVC.loginScreenAppear()
        } else {
            var myUser: [User]? {didSet {}}
            myUser = User.readUserFromArchive()
            if myUser![0].role == "user" {
                delegateHomeVideoVC.upgradeScreenAppear()
            }
            else {
                if let rootViewController = UIApplication.topViewController() {
                    let storyMain = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyMain.instantiateViewController(withIdentifier: "actionMediaVC") as! actionMediaViewController
                    vc.arrVideo = self.arrVideo
                    vc.modalPresentationStyle = .overFullScreen
                    rootViewController.navigationController?.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func like(_ sender: AnyObject) {
        btnLike(senderTag:sender.tag)
    }
    
    func btnLike(senderTag:Int) {
        print("Like btn SenderTag:\(senderTag)")
        let userID = UserDefaults.standard.string(forKey: "userID")
        
        if userID != "" && userID != nil {
            var obj = self.arrVideo
            if self.liked == true {
                //self.likeBtn.tintColor = .white
                likeBtn.isSelected = false
                liked_count = liked_count - 1
                self.likeCountLbl.text = "\(liked_count!)"
                obj!.like = "0"
                obj!.like_count  = "\(liked_count!)"
                self.liked = false
            } else {
                //self.likeBtn.tintColor = .red
                likeBtn.isSelected = true
                liked_count = liked_count + 1
                self.likeCountLbl.text = "\(liked_count!)"
                obj!.like = "1"
                self.liked = true
                obj!.like_count  = "\(liked_count!)"
            }
            delegate?.updateObj(obj: obj!, index: senderTag, islike: true)
        } else {
            delegateHomeVideoVC.loginScreenAppear()
        }
    }
    
    @IBAction func btnprofile (_ sender: AnyObject) {
        if let rootViewController = UIApplication.topViewController() {
            let storyMain = UIStoryboard(name: "Main", bundle: nil)
            print("obj user id : ", arrVideo!.userID)
            let vc = storyMain.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
            vc.isOtherUserVisting = true
            vc.hidesBottomBarWhenPushed = true
            vc.otherUserID = arrVideo!.userID
            UserDefaults.standard.set(arrVideo!.userID, forKey: "otherUserID")
            rootViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func comment(_ sender: AnyObject) {
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID == nil || userID == "" {
            delegateHomeVideoVC.loginScreenAppear()
        } else {
            print("comment btn tag:", sender.tag)
            if let rootViewController = UIApplication.topViewController() {
                let storyMain = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyMain.instantiateViewController(withIdentifier: "commentsNewVC") as! commentsNewViewController
                vc.video_id = self.arrVideo!.videoID
                vc.arrVideo = self.arrVideo
                vc.index =  sender.tag
                let navController = UINavigationController()
                navController.viewControllers = [vc]
                navController.modalPresentationStyle = .overFullScreen
                navController.navigationBar.isHidden = true
                rootViewController.navigationController?.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func share(_ sender: Any) {
        if let rootViewController = UIApplication.topViewController() {
            let storyMain = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyMain.instantiateViewController(withIdentifier: "shareVC") as! shareViewController
            vc.videoID = self.arrVideo!.videoID
            vc.objToShare.removeAll()
            vc.objToShare.append(self.videoURL!)
            vc.currentVideoUrl = self.videoURL!
            vc.arrVideo = self.arrVideo
            vc.modalPresentationStyle = .overFullScreen
            rootViewController.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func showMainVideo(_ sender: AnyObject) {
        if let rootViewController = UIApplication.topViewController() {
            let storyMain = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyMain.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
            vc.video_id = self.arrVideo!.main_video_id
            vc.currentIndex = IndexPath.init(index: 0)
            vc.isOtherController =  true
            vc.hidesBottomBarWhenPushed = true
            rootViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func showReplies(_ sender: AnyObject) {
        if let rootViewController = UIApplication.topViewController() {
            let storyMain = UIStoryboard(name: "Main", bundle: nil)
            
            if self.arrVideo?.main_video_id != "<null>" {
                let vc = storyMain.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
                vc.video_id = self.arrVideo!.main_video_id
                vc.currentIndex = IndexPath.init(index: 0)
                vc.isOtherController =  true
                vc.hidesBottomBarWhenPushed = true
                rootViewController.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = storyMain.instantiateViewController(withIdentifier: "VideoRepliesVC") as! VideoRepliesViewController
                vc.video_id = self.arrVideo!.videoID
                vc.hidesBottomBarWhenPushed = true
                rootViewController.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK:- NotificationCenter
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        if notification.name.rawValue == "commentVideo" {
            let notif = notification.object as! [String:Any]
            var obj = self.arrVideo
            var comentCount:Int =  notif["Count"] as! Int
            comentCount = comentCount + 1
            obj?.comment_count = "\(comentCount)"
            self.commentCountLbl.text = "\(comentCount)"
            delegate?.updateObj(obj: obj!, index:  notif["SelectedIndex"] as! Int, islike: false)
        } else if notification.name.rawValue == "pauseVideo" {
            pause()
        } else if notification.name.rawValue == "playVideo" {
            play()
        }
    }
}

extension UIView {
    
    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    func startRotating(duration: Double = 3) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(M_PI * 2.0)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}
extension String {
    func shorten() -> String{
        let number = Double(self)
        let thousand = number! / 1000
        let million = number! / 1000000
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        }
        else {
            return "\(self)"
        }
    }
}
extension UITextView {
       func numberOfLines(textView: UITextView) -> Int {
        let layoutManager = textView.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
}
