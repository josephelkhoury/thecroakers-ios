//
//  topicViewController.swift
//  TIK TIK
//
//  Created by Mac on 04/09/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import ContentLoader

class topicViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var privType = "N/A"
    var userID = ""
    var hashtagsArr = [hashTagMVC]()
    
    @IBOutlet weak var tableOutlet: UITableView!
    
    var format = ContentLoaderFormat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        format.color = "#F6F6F6".hexColor
        format.radius = 5
        format.animation = .fade
        view.startLoading(format: format)
        
        self.getFeaturedHashtags()
        self.tableOutlet.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK:- API Handler
    
    // GET FEATURED HASHTAGS
    func getFeaturedHashtags(){
        self.hashtagsArr.removeAll()
        ApiHandler.sharedInstance.showFeaturedHashtags(user_id: self.userID) { (isSuccess, response) in
            if isSuccess{
               self.view.hideLoading()
                
                print("response showFeaturedHashtags: ", response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                let hashtags = response?.value(forKey: "msg") as! NSArray
                    
                    for i in 0..<hashtags.count {
                        var hashtagDict  = hashtags.object(at: i) as! NSDictionary
                        hashtagDict = hashtagDict.value(forKey: "Hashtag") as! NSDictionary
                        let id = hashtagDict.value(forKey: "id") as! String
                        let name = hashtagDict.value(forKey: "name") as! String
                        let image = hashtagDict.value(forKey: "image") as! String
                        let featured = hashtagDict.value(forKey: "featured") as! String
                        let hashtag = hashTagMVC(id: id, name: name, image: image, featured: featured, views: "", favourite: "")
                        self.hashtagsArr.append(hashtag)
                        self.tableOutlet.reloadData()
                    }
                } else {
                    print("showFeatureedHashtags API:",response?.value(forKey: "msg") as Any)
                }
                
            } else {
                self.view.hideLoading()
                print("showFeaturedHashtags API:",response?.value(forKey: "msg") as Any)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashtagsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicTVC") as! topicTableViewCell
        
        let hashtag = self.hashtagsArr[indexPath.row]
        cell.title.text = hashtag.name
        cell.desc.text = "";
        
        let hashtag_id = UserDefaults.standard.string(forKey: "hashtag_id")
        if hashtag.id == hashtag_id {
            cell.accessoryType = .checkmark
            cell.accessoryView?.tintColor = UIColor(named: "theme")
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("index",indexPath.row)
        
        self.tableOutlet.cellForRow(at: indexPath)?.accessoryView?.tintColor = UIColor(named: "theme")
        self.tableOutlet.cellForRow(at: indexPath)?.accessoryView?.backgroundColor = .clear
        self.tableOutlet.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        print("indexpath.row: ", indexPath.row)
        
        tableOutlet.reloadData()
        
        let hashtag = self.hashtagsArr[indexPath.row]
        UserDefaults.standard.set(hashtag.id, forKey: "hashtag_id")
        
        NotificationCenter.default.post(name: Notification.Name("privTypeNC"), object: nil, userInfo: ["hashtag": hashtag])
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableOutlet.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        print("pressed")
    }
}
