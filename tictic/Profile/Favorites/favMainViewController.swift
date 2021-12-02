//
//  favMainViewController.swift
//  MusicTok
//
//  Created by Mac on 06/02/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class favMainViewController: ButtonBarPagerTabStripViewController {


    
    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor(named: "theme")!
        settings.style.buttonBarItemFont = UIFont.boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        /*settings.style.buttonBarItemTitleColor = .black
          settings.style.buttonBarLeftContentInset = 20
          settings.style.buttonBarRightContentInset = 20*/

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 138/255.0, green: 138/255.0, blue: 144/255.0, alpha: 1.0)
            newCell?.label.textColor = UIColor(named: "theme")
        }
        
        self.view.backgroundColor = .white
        
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    

    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        let child1 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "favWorkingVC") as! favWorkingViewController
        child1.itemInfo = "Videos"

        let child2 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "favWorkingVC") as! favWorkingViewController
        child2.itemInfo = "Sounds"
        
        let child3 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "favWorkingVC") as! favWorkingViewController
        child3.itemInfo = "Hashtags"

        return [child1,child2,child3]
    }
    @IBAction func btnBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}


