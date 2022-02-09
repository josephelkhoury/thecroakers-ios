//
//  commentsNewTableViewCell.swift
//  TIK TIK
//
//  Created by Mac on 15/09/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

protocol commentsDelegate: class {
    func goToUserProfile(userID: String)
    func loginScreenAppear()
    func updateObj(obj: commentNew, indexPath: IndexPath, islike:Bool)
    func deleteComment(comment_id: String, indexPath: IndexPath)
}

class commentsNewTableViewCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var leftLayoutConstraint: NSLayoutConstraint!;
    @IBOutlet weak var rightLayoutConstraint: NSLayoutConstraint!;
    
    weak var delegate: commentsDelegate?
    private(set) var liked = false
    private(set) var liked_count:Int!
    var userID = ""
    var arrComment: commentNew?
    var arrVideo: videoMainMVC?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImg.layer.masksToBounds = false
        userImg.layer.cornerRadius = userImg.frame.height/2
        userImg.clipsToBounds = true
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressComment))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.addGestureRecognizer(lpgr)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(commentObj: commentNew, arrVideo: videoMainMVC) {
        self.arrComment = commentObj
        self.arrVideo = arrVideo
        
        if commentObj.commentID != "0" {
            leftLayoutConstraint.constant = 50
            rightLayoutConstraint.constant = 18
        } else {
            leftLayoutConstraint.constant = 12
            rightLayoutConstraint.constant = 10
        }
        
        self.userID = commentObj.userID
        self.userName.text = commentObj.userName
        let cmntWithoutTime = "\(commentObj.comment)"
        let cmnt = cmntWithoutTime
        self.comment.text = cmnt
        let userImgPath = AppUtility?.detectURL(ipString: commentObj.imgName)
        let userImgUrl = URL(string: userImgPath!)
        self.userImg.sd_setImage(with: userImgUrl, placeholderImage: UIImage(named: "noUserNew"))
        
        self.likeCount.text = commentObj.like_count ?? "0".shorten()
        self.liked_count = Int(commentObj.like_count) ?? 0
        
        if commentObj.like ==  "1" {
            likeBtn.isSelected = true
            liked = true
        } else {
            likeBtn.isSelected = false
            liked = false
        }
    }
    
    @IBAction func goToUserProfile(_ sender: Any) {
        delegate?.goToUserProfile(userID: self.userID)
    }
    
    @IBAction func like(_ sender: AnyObject) {
        btnLike(senderTag:sender.tag)
    }
    
    func btnLike(senderTag:Int) {
        let userID = UserDefaults.standard.string(forKey: "userID")
        
        if userID != "" && userID != nil {
            var obj = self.arrComment
            if self.liked == true {
                likeBtn.isSelected = false
                liked_count = liked_count - 1
                self.likeCount.text = "\(liked_count!)"
                obj!.like = "0"
                obj!.like_count  = "\(liked_count!)"
                self.liked = false
            } else {
                likeBtn.isSelected = true
                liked_count = liked_count + 1
                self.likeCount.text = "\(liked_count!)"
                obj!.like = "1"
                self.liked = true
                obj!.like_count  = "\(liked_count!)"
            }
            delegate?.updateObj(obj: obj!, indexPath: indexPath!, islike: true)
        } else {
            delegate?.loginScreenAppear()
        }
    }
    
    // MARK:- handleLongPressComment
    @objc func handleLongPressComment(gestureReconizer: UILongPressGestureRecognizer) {
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID != "" && userID != nil && (userID == arrComment?.userID || userID == arrVideo?.userID) {
            self.delegate?.deleteComment(comment_id: self.arrComment!.id, indexPath: indexPath!)
        }
    }
}
