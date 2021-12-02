//
//  FollowersViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import SDWebImage

class NewFollowersViewController: UIViewController {
    
    //MARK:- Outlets
    
    @IBOutlet weak var tblFollowers: UITableView!
  
    var followersArr = [[String:Any]]()
    var isOtherUserVisting =  false
    var userData = [userMVC]()
    
    //MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblFollowers.delegate = self
        tblFollowers.dataSource = self
        self.getFollowersAPI()
    }

//MARK:- API Handler

    func getFollowersAPI(){
        
        AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.showFollowers(user_id: UserDefaults.standard.string(forKey: "userID")!, other_user_id: userData[0].userID) { (isSuccess, response) in
            
            AppUtility?.stopLoader(view: self.view)
            
            if isSuccess{
                let code = response?.value(forKey: "code") as! NSNumber
                if code == 200{
                    let msgArr = response?.value(forKey: "msg") as! NSArray
                    for objMsg in msgArr{
                        
                        let dict = objMsg as! NSDictionary
                        let followerDict = dict.value(forKey: "FollowerList") as! [String:Any]
                        
                        self.followersArr.append(followerDict)
                    }
                    
                    self.tblFollowers.reloadData()
                }else{
                    print("!200: ",response as Any)
                }
            }
        }
    }
}
extension NewFollowersViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.followersArr.count
    }    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ffsTVC") as! ffsTVC
        
        let obj = followersArr[indexPath.row]
        let btnFollow = obj["button"] as! String
        let userImg = obj["profile_pic"] as! String
        let username = obj["username"] as! String
        let bio = obj["bio"] as! String
        
        cell.btnFollow.backgroundColor = .clear
        cell.btnFollow.layer.cornerRadius = 3
        cell.btnFollow.layer.borderWidth = 1
        cell.btnFollow.layer.borderColor = UIColor.gray.cgColor
        cell.btnFollow.setTitle("Friend", for: .normal)
        cell.lblTitle.text = username
        cell.imgIcon.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgIcon.sd_setImage(with: URL(string:(AppUtility?.detectURL(ipString: userImg))!), placeholderImage: UIImage(named:"noUserImg"))

        cell.lblDescription.text = bio
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let otherUserID = followersArr[indexPath.row]["id"] as! String
        let vc = storyboard?.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
        vc.isOtherUserVisting = self.isOtherUserVisting
        vc.hidesBottomBarWhenPushed = true
        vc.otherUserID = otherUserID
        UserDefaults.standard.set(otherUserID, forKey: "otherUserID")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
