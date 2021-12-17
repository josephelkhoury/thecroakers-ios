//
//  NewSuggestionViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import XLPagerTabStrip

class NewSuggestionViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var tblSuggestion: UITableView!
    
    var suggestionsArr = [[String:Any]]()
    var userData = [userMVC]()
    var itemInfo:IndicatorInfo = "View"
    weak var delegate: mainFFSDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblSuggestion.delegate = self
        tblSuggestion.dataSource = self
        fetchSuggestedPeopleAPI()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func fetchSuggestedPeopleAPI() {
        self.userData.removeAll()
        AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.suggestedPeople(user_id: UserDefaults.standard.string(forKey: "userID") ?? "") { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            let code = response?.value(forKey: "code") as! NSNumber
            if code == 200 {
                let msgArr = response?.value(forKey: "msg") as! NSArray
                for objMsg in msgArr {
                    let dict = objMsg as! NSDictionary
                    let followerDict = dict.value(forKey: "User") as! [String:Any]

                    self.suggestionsArr.append(followerDict)
                }
                self.tblSuggestion.reloadData()
            } else {
                print("!200: ",response as Any)
            }
        }
    }
}

extension NewSuggestionViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ffsTVC", for: indexPath) as! ffsTVC
        
        let obj = suggestionsArr[indexPath.row]
        cell.configure(user: obj)
        cell.delegate = delegate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard suggestionsArr[indexPath.row]["id"] != nil else { showToast(message: "Null", font: .systemFont(ofSize: 12)); return}
        
        let otherUserID = suggestionsArr[indexPath.row]["id"] as! String
        
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
