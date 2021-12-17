//
//  ffsTVC.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import SDWebImage

class ffsTVC: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnBell: UIButton!
    
    var user: [String:Any] = [:]
    weak var delegate: mainFFSDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnBell.isHidden = true
        btnFollow.addTarget(self, action: #selector(btnFollowTapped(sender:)), for: .touchUpInside)
    }
    
    func configure(user: [String:Any]) {
        self.user = user
        
        let txtFollow = user["button"] as! String
        let userImg = user["profile_pic"] as! String
        let username = user["username"] as! String
        let bio = user["bio"] as! String
        
        if txtFollow != "" {
            btnFollow.isHidden = false
            btnFollow.setTitle(txtFollow, for: .normal)
            
            if txtFollow == "Friends" || txtFollow == "Following" {
                btnFollow.backgroundColor = .white
                btnFollow.layer.borderWidth = 1
                btnFollow.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                btnFollow.setTitleColor(.black, for: .normal)
            } else {
                btnFollow.backgroundColor = UIColor(named: "theme")
                btnFollow.layer.borderWidth = 1
                btnFollow.layer.borderColor = UIColor(named: "theme")?.cgColor
                btnFollow.setTitleColor(.white, for: .normal)
            }
        }
        else {
            btnFollow.isHidden = true
        }
            
        lblTitle.text = username
        imgIcon.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgIcon.sd_setImage(with: URL(string:(AppUtility?.detectURL(ipString: userImg))!), placeholderImage: UIImage(named:"noUserImg"))

        lblDescription.text = bio
    }
    
    @objc func btnFollowTapped(sender : UIButton) {
        delegate?.btnFollowFunc(sender: sender, rcvrID: user["id"] as! String)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
