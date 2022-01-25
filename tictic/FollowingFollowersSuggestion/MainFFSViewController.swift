//
//  MainFFSViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import XLPagerTabStrip

protocol mainFFSDelegate: class {
    func btnFollowFunc(sender: UIButton, rcvrID: String)
}

class MainFFSViewController: ButtonBarPagerTabStripViewController, mainFFSDelegate {

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
        let child1 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewFollowingViewController") as! NewFollowingViewController
        child1.itemInfo = "Following"
        child1.userData = userData
        child1.delegate = self

        let child2 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewFollowersViewController") as! NewFollowersViewController
        child2.itemInfo = "Followers"
        child2.userData = userData
        child2.delegate = self
        
        let child3 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewSuggestionViewController") as! NewSuggestionViewController
        child3.itemInfo = "Suggestions"
        child3.userData = userData
        child3.delegate = self
        
        return [child1,child2,child3]
    }

    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func findFriendsPressed(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NewFindFriendsViewController") as! NewFindFriendsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnFollowFunc(sender: UIButton, rcvrID: String) {
        let uid = UserDefaults.standard.string(forKey: "userID")
        if uid == "" || uid == nil {
            loginScreenAppear()
        } else {
            followUserFunc(rcvrID:rcvrID)
            if sender.currentTitle == "Friends" || sender.currentTitle == "Following" {
                sender.setTitle("Follow", for: .normal)
                sender.backgroundColor = UIColor(named: "theme")
                sender.layer.borderWidth = 1
                sender.layer.borderColor = UIColor(named: "theme")?.cgColor
                sender.setTitleColor(.white, for: .normal)
            } else {
                sender.setTitle("Following", for: .normal)
                sender.backgroundColor = .white
                sender.layer.borderWidth = 1
                sender.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                sender.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    func followUserFunc(rcvrID:String) {
        let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        
        self.followUser(rcvrID: rcvrID, userID: userID, ProfileUserFollow: 0)
    }
    
    
    //MARK:- Login screen will appear func
    func loginScreenAppear() {
        let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen
        
        self.present(navController, animated: true, completion: nil)
    }
    
    // Follow user API
    func followUser(rcvrID:String,userID:String,ProfileUserFollow:Int) {
        //AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.followUser(sender_id: userID, receiver_id: rcvrID) { (isSuccess, response) in
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    AppUtility?.stopLoader(view: self.view)
                } else {
                    AppUtility?.stopLoader(view: self.view)
                    self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
                }
                
            } else {
                AppUtility?.stopLoader(view: self.view)
                self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
            }
        }
    }
}
