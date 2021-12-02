//
//  countryCodeTableViewCell.swift
//  TIK TIK
//
//  Created by Mac on 11/11/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class countryCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCountry: UIImageView!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var codeCountry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
