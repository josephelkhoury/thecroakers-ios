//
//  TabbarViewController.swift
//  TIK TIK
//
//  Created by Mac on 24/04/2019.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController,UITabBarControllerDelegate {
    
    var button = UIButton(type: .custom)
    
    var bgView:UIImageView?
    var homeTouchCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // tabBar.barTintColor = UIColor.white
        self.tabBar.isTranslucent = true
        self.tabBar.unselectedItemTintColor = UIColor.white
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        self.addCenterButtonNew(withImage: UIImage(named: "33")!, highlightImage: UIImage(named: "33")!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openShareLink), name: Notification.Name("openShareLink"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openShareLink()
    }
    
    @objc func openShareLink() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.shareLink != "" {
            ApiHandler.sharedInstance.showShareLink(link: delegate.shareLink!) { (isSuccess, response) in
                delegate.shareLink = ""
                if isSuccess {
                    if response?.value(forKey: "code") as! NSNumber == 200 {
                        
                        let msg = response?.value(forKey: "msg") as! NSDictionary
                        let shareLink = msg.value(forKey: "ShareLink") as! NSDictionary
                        
                        let type = shareLink.value(forKey: "type") as! String
                        let entity_id = shareLink.value(forKey: "entity_id") as! String
                        
                        if type == "user" {
                            if let rootViewController = UIApplication.topViewController() {
                                let storyMain = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyMain.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
                                vc.isOtherUserVisting = true
                                vc.hidesBottomBarWhenPushed = true
                                vc.otherUserID = entity_id
                                UserDefaults.standard.set(entity_id, forKey: "otherUserID")
                                rootViewController.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else if type == "video" {
                            if let rootViewController = UIApplication.topViewController() {
                                let storyMain = UIStoryboard(name: "Main", bundle: nil)
                                let vc =  storyMain.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
                                vc.isOtherController =  true
                                vc.hidesBottomBarWhenPushed = true
                                vc.video_id = entity_id
                                rootViewController.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[2] {
            
            let userID = UserDefaults.standard.string(forKey: "userID")
            if userID != "" && userID != nil {
                var myUser: [User]? {didSet {}}
                myUser = User.readUserFromArchive()
                if myUser![0].role == "user" {
                    upgradeScreenAppear()
                    return false
                } else {
                    return true
                }
            } else {
                newLoginScreenAppear()
                return false
            }
        } else if (viewController == tabBarController.viewControllers?[3]) {
            let userID = UserDefaults.standard.string(forKey: "userID")
            
            if (userID != "") && (userID != nil) {
                return true
            } else {
                newLoginScreenAppear()
                return false
            }
        } else {
            return true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(self.tabBar)
    }
    
    // Add Custom video making button in tabbar
    private func addCenterButton() {
        button.setImage(UIImage(named: "33"), for: .normal)
        let square = self.tabBar.frame.size.height
        button.frame = CGRect(x: 0, y: 0, width: square, height: square)
        button.center = self.tabBar.center
        self.view.addSubview(button)
        self.view.bringSubviewToFront(button)
        tabBar.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        tabBar.topAnchor.constraint(equalTo: button.centerYAnchor).isActive = false
        tabBar.bottomAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        button.addTarget(self, action: #selector(didTouchCenterButton(_:)), for: .touchUpInside)
    }
    
    @objc
    private func didTouchCenterButton(_ sender: AnyObject) {
        if (UserDefaults.standard.string(forKey: "userID") == "" || UserDefaults.standard.string(forKey: "userID") == nil) {
            newLoginScreenAppear()
        } else {
            var myUser: [User]? {didSet {}}
            myUser = User.readUserFromArchive()
            if myUser![0].role == "user" {
                upgradeScreenAppear()
            }
            else {
                let vc1 = storyboard?.instantiateViewController(withIdentifier: "actionMediaVC") as! actionMediaViewController
                UserDefaults.standard.set("", forKey: "url")
                vc1.modalPresentationStyle = .fullScreen
                self.present(vc1, animated: true, completion: nil)
            }
        }
    }
    
    // Tabbar delegate Method
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0 {            
            print("index@0")
            // self.tabBar.isTranslucent = true
            // UITabBar.appearance().shadowImage = UIImage()
            // UITabBar.appearance().backgroundImage = UIImage()
            tabBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.tabBar.unselectedItemTintColor = UIColor.white
            
            homeTouchCount += 1
            
            if homeTouchCount == 2 {
                print("homeTouchCount: ",homeTouchCount)
                NotificationCenter.default.post(name: Notification.Name("reloadScreenNotification"), object: nil)
                homeTouchCount = 0
            }
        } else {
            tabBar.barTintColor = UIColor.white
            self.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            //            button.setImage(UIImage(named: "28"), for: .normal)
            //            self.bgView?.alpha = 0
            //you might need to modify this frame to your tabbar frame
            //            self.bgView?.removeFromSuperview()
            
            homeTouchCount = 0
        }
    }
    
    func alertModule(title:String,msg:String) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleTouchTabbarCenter(sender : UIButton)
    {
        if (UserDefaults.standard.string(forKey: "userID") == "" || UserDefaults.standard.string(forKey: "userID") == nil) {
            newLoginScreenAppear()
        } else {
            var myUser: [User]? {didSet {}}
            myUser = User.readUserFromArchive()
            if myUser![0].role == "user" {
                upgradeScreenAppear()
            }
            else {
                let vc1 = storyboard?.instantiateViewController(withIdentifier: "actionMediaVC") as! actionMediaViewController
                UserDefaults.standard.set("", forKey: "url")
                vc1.modalPresentationStyle = .fullScreen
                self.present(vc1, animated: true, completion: nil)
            }
        }
    }
    
    func addCenterButtonNew(withImage buttonImage : UIImage, highlightImage: UIImage) {
        var paddingBottom : CGFloat = 0.0
        
        if !DeviceType.iPhoneWithHomeButton {
            paddingBottom = 4.0
        }
        
        let button = UIButton(type: .custom)
        button.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin]
        button.frame = CGRect(x: 0.0, y: 0.0, width: buttonImage.size.width , height: buttonImage.size.height)
        button.setBackgroundImage(buttonImage, for: .normal)
        button.setBackgroundImage(highlightImage, for: .highlighted)
        
        let rectBoundTabbar = self.tabBar.bounds
        let xx = rectBoundTabbar.midX
        let yy = rectBoundTabbar.midY - paddingBottom
        button.center = CGPoint(x: xx, y: yy)
        
        self.tabBar.addSubview(button)
        self.tabBar.bringSubviewToFront(button)
        
        button.addTarget(self, action: #selector(handleTouchTabbarCenter), for: .touchUpInside)
        
        if let count = self.tabBar.items?.count {
            let i = floor(Double(count / 2))
            let item = self.tabBar.items![Int(i)]
            item.title = "Notifications"
        }
    }
    
    func newLoginScreenAppear() {
        let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen

        self.present(navController, animated: true, completion: nil)
    }
    
    func upgradeScreenAppear() {
        let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "UpgradeVC"))
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen

        self.present(navController, animated: true, completion: nil)
    }
}
