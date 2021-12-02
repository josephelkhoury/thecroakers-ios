//
//  FilterCollectionViewCell.swift
//  MusicTok
//
//  Created by Mac on 2021-08-14.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureImageView()
    }
    
    func configureImageView() {
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurredEffectView = UIVisualEffectView(effect: blur)
        blurredEffectView.alpha = 0.4
        blurredEffectView.frame = self.imageView.bounds
        self.imageView.addSubview(blurredEffectView)
    }

}
