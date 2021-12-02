//
//  privacyTableViewCell.swift
//  TIK TIK
//
//  Created by Mac on 04/09/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class topicTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
