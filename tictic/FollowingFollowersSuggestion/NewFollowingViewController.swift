//
//  FollowingViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import SDWebImage

class NewFollowingViewController: UIViewController {
    
    //MARK:- Outlets
    
    @IBOutlet weak var tblFollowing: UITableView!
    var FollowingArr = [[String:Any]]()
    var isOtherUserVisting =  false
    var userData = [userMVC]()
    
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        tblFollowing.delegate = self
        tblFollowing.dataSource = self
        self.getFollowingAPI()
    }
    
    //MARK:- API Handler
    func getFollowingAPI(){
        
        AppUtility?.startLoader(view: self.view)
        
        ApiHandler.sharedInstance.showFollowing(user_id: UserDefaults.standard.string(forKey: "userID")!, other_user_id: userData[0].userID) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess{
                let code = response?.value(forKey: "code") as! NSNumber
                if code == 200 {
                    let msgArr = response?.value(forKey: "msg") as! NSArray
                    for objMsg in msgArr{
                        
                        let dict = objMsg as! NSDictionary
                        let followerDict = dict.value(forKey: "FollowingList") as! [String:Any]

                        self.FollowingArr.append(followerDict)
                    }
                    
                    self.tblFollowing.reloadData()
                } else {
                    print("!200: ",response as Any)
                }
            }
        }
    }
}
extension NewFollowingViewController: UITableViewDelegate,UITableViewDataSource{
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.FollowingArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ffsTVC") as! ffsTVC
        
        let obj = FollowingArr[indexPath.row]
        let btnFollow = obj["button"] as? String
        let userImg = obj["profile_pic"] as? String
        let username = obj["username"] as? String
        let bio = obj["bio"] as? String
        cell.btnFollow.layer.borderWidth = 1
        cell.btnFollow.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cell.btnFollow.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        cell.btnFollow.setTitle("Friend", for: .normal)
        cell.lblTitle.text = username
        cell.imgIcon.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgIcon.sd_setImage(with: URL(string:(AppUtility?.detectURL(ipString: userImg ?? ""))!), placeholderImage: UIImage(named:"noUserImg"))
        cell.lblDescription.text = bio
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard FollowingArr[indexPath.row]["id"] != nil else { showToast(message: "Null", font: .systemFont(ofSize: 12)); return}
        
        let otherUserID = FollowingArr[indexPath.row]["id"] as! String
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
        vc.isOtherUserVisting = true
        vc.hidesBottomBarWhenPushed = true
        vc.otherUserID = otherUserID
        UserDefaults.standard.set(otherUserID, forKey: "otherUserID")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
