//
//  DiscoverViewController.swift
//  TheCroakers
//
//  Created by Joseph El Khoury on 11/29/21.
//  Copyright © 2021 Joseph El Khoury. All rights reserved.
//

import Foundation

import XLPagerTabStrip

class DiscoverViewController: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var lblNavigationTitle: UILabel!
    var userData = [userMVC]()
    var SelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblNavigationTitle.text = "Trending"
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemFont = .systemFont(ofSize: 15.0)
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 10
        settings.style.buttonBarRightContentInset = 10
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            newCell?.label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiscoverVC") as! newDiscoverViewController
        child1.itemInfo = "Topics"
        child1.section = "0"

        let child2 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiscoverVC") as! newDiscoverViewController
        child2.itemInfo = "Publishers"
        child2.section = "1"
        
        let child3 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiscoverVC") as! newDiscoverViewController
        child3.itemInfo = "Croakers"
        child3.section = "2"
        
        return [child1,child2,child3]
    }
}


