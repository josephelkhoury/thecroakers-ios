//
//  followingsViewController.swift
//  TIK TIK
//
//  Created by Mac on 29/12/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class followingsViewController: UIViewController {
    
    var followerUserID = ""
    var followersArr = [[String:Any]]()
    @IBOutlet weak var tblView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblView.delegate = self
        tblView.dataSource = self
        
        tblView.tableFooterView = UIView()
        
        getFollowersAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

            self.tabBarController?.tabBar.isHidden = true
        
    }

    func getFollowersAPI(){
        
//        self.view.activityStartAnimating()
        //AppUtility?.startLoader(view: self.view)
        
        var otherUserID = UserDefaults.standard.string(forKey: "otherUserID")
        
        if otherUserID == ""{
            otherUserID = UserDefaults.standard.string(forKey: "userID")
        }
        
        ApiHandler.sharedInstance.showFollowing(user_id: UserDefaults.standard.string(forKey: "userID")!, other_user_id: otherUserID!) { (isSuccess, response) in
            
//            self.view.activityStopAnimating()
            AppUtility?.stopLoader(view: self.view)
            
            if isSuccess{
                let code = response?.value(forKey: "code") as! NSNumber
                if code == 200{
                    let msgArr = response?.value(forKey: "msg") as! NSArray
                    for objMsg in msgArr{
                        
                        let dict = objMsg as! NSDictionary
                        let followerDict = dict.value(forKey: "FollowingList") as! [String:Any]

                        
                        self.followersArr.append(followerDict)
                    }
                    
                    self.tblView.reloadData()
                }else{
                    print("!200: ",response as Any)
                }
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
//        UserDefaults.standard.set("", forKey: "otherUserID")
        navigationController?.popViewController(animated: true)
    }
}

extension followingsViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.followersArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followTVC") as! followTableViewCell
        
        let obj = followersArr[indexPath.row]
        let btnFollow = obj["button"] as? String
        let userImg = obj["profile_pic"] as? String
        let username = obj["username"] as? String
        let bio = obj["bio"] as? String
        
        cell.btn.backgroundColor = .clear
        cell.btn.layer.cornerRadius = 3
        cell.btn.layer.borderWidth = 1
        cell.btn.layer.borderColor = UIColor.gray.cgColor
        
        cell.title.text = username
        cell.img.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.img.sd_setImage(with: URL(string:(AppUtility?.detectURL(ipString: userImg ?? ""))!), placeholderImage: UIImage(named:"noUserImg"))

        cell.desc.text = bio
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard followersArr[indexPath.row]["id"] != nil else { showToast(message: "Null", font: .systemFont(ofSize: 12)); return}
        
        let otherUserID = followersArr[indexPath.row]["id"] as! String
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
            vc.isOtherUserVisting = true
        vc.hidesBottomBarWhenPushed = true
//            vc.otherUserID = otherUserID
        UserDefaults.standard.set(otherUserID, forKey: "otherUserID")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}
