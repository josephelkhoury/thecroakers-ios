//
//  ffsTVC.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit

class ffsTVC: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnBell: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
