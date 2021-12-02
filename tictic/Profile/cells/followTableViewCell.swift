//
//  followersTableViewCell.swift
//  TIK TIK
//
//  Created by Mac on 22/01/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class followTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var desc: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        img.layer.masksToBounds = false
        img.layer.cornerRadius = img.frame.height/2
        img.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
