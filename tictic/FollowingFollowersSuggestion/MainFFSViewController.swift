//
//  MainFFSViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import XLPagerTabStrip

class MainFFSViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var lblNavigationTitle: UILabel!
    var userData = [userMVC]()
    var SelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblNavigationTitle.text = "@\(self.userData[0].username)"
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
        let child1 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FFsDetailViewController") as! FFsDetailViewController
        child1.itemInfo = "Following"
        child1.userData = userData

        let child2 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FFsDetailViewController") as! FFsDetailViewController
        child2.itemInfo = "Followers"
        child2.userData = userData
        
        let child3 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FFsDetailViewController") as! FFsDetailViewController
        child3.itemInfo = "Suggestions"
        child3.userData = userData
        
        return [child1,child2,child3]
    }

    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func findFriendsPressed(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NewFindFriendsViewController") as! NewFindFriendsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
