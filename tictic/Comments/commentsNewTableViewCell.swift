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
}

class commentsNewTableViewCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var time: UILabel!
    
    weak var delegate: commentsDelegate?
    var userID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImg.layer.masksToBounds = false
        userImg.layer.cornerRadius = userImg.frame.height/2
        userImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func goToUserProfile(_ sender: Any) {
        delegate?.goToUserProfile(userID: self.userID)
    }
}
