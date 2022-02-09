//
//  commentsNewViewController.swift
//  TIK TIK
//
//  Created by Mac on 15/09/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import NVActivityIndicatorView
import IQKeyboardManagerSwift

class commentsNewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, commentsDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var video_id = ""
    var commentsArr = [commentNew]()
    
    @IBOutlet weak var cmntTxtfieldBackView: UIView!
    @IBOutlet weak var noCommentLbl: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var loaderView: NVActivityIndicatorView!
    
    @IBOutlet weak var commentTxtField: UITextField!
    
    var userImg = ""
    var userFullName = ""
    var arrVideo : videoMainMVC?
    var index = 0
    var comment_id = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(commentsNewViewController.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
        
        self.noCommentLbl.isHidden = true
        
        doneDisable()
        getUserInfo()
        
        commentsTableView.estimatedRowHeight = 44.0
        commentsTableView.rowHeight = UITableView.automaticDimension
        commentsTableView.tableFooterView = UIView()

        newGetComments()
        loaderView.type = .lineSpinFadeLoader
        loaderView.backgroundColor = .clear
        loaderView.color = #colorLiteral(red: 1, green: 0.5223166943, blue: 0, alpha: 1)
        
        loaderView.startAnimating()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeBackgroundAni()
    }
    
    func changeBackgroundAni() {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)

        }, completion:nil)
    }
    
    //    MARK:- MOVE COMMENT TEXT FIELD TO FRONT
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.cmntTxtfieldBackView.frame.origin.y == 0 {
                self.cmntTxtfieldBackView.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.cmntTxtfieldBackView.frame.origin.y != 0 {
            self.cmntTxtfieldBackView.frame.origin.y = 0
        }
    }
    
    @objc func expandComment(_ sender: AnyObject) {
        let expanded = commentsArr[sender.tag].expanded
        commentsArr[sender.tag].expanded = !expanded
        self.commentsTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return commentsArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let obj = commentsArr[section] as commentNew
        
        if obj.expanded == true && commentsArr[section].repliesArr!.count > 0 {
            return commentsArr[section].repliesArr!.count + 1
        }
        
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if commentsArr[section].repliesArr!.count > 0  {
            return 20
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if commentsArr[section].repliesArr!.count > 0  {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
            let button = UIButton(frame: CGRect(x: 55, y: 0, width: 100, height: 20))
            
            button.setTitleColor(UIColor.gray, for: UIControl.State.normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.contentHorizontalAlignment = .left
            button.tag = section
            button.addTarget(self, action: #selector(expandComment(_:)), for: .touchUpInside)
            
            let obj = commentsArr[section] as commentNew
            
            if commentsArr[section].repliesArr != nil {
                if (obj.expanded == true) {
                    button.setTitle("Show less", for: UIControl.State.normal)
                } else {
                    button.setTitle("View replies ("+obj.repliesCount+")", for: UIControl.State.normal)
                }
            }
            
            footerView.addSubview(button)
            
            return footerView
        }
        
        return nil;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsNewTVC") as! commentsNewTableViewCell
        
        //let time = timeManage(ind: indexPath)
        
        if self.commentsArr.count <= 0 {
            self.noCommentLbl.isHidden = false
        } else {
            self.noCommentLbl.isHidden = true
            commentsCount.text = "\(commentsArr.count)" + (commentsArr.count == 1 ? " comment" : " comments")
            
            var obj: commentNew
            
            if indexPath.row == 0 {
                obj = commentsArr[indexPath.section] as commentNew
            } else {
                obj = commentsArr[indexPath.section].repliesArr![indexPath.row - 1]
            }
            
            cell.indexPath = indexPath
            cell.configure(commentObj: obj, arrVideo: arrVideo!)
            cell.likeBtn.tag = indexPath.row
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var obj: commentNew
        
        if indexPath.row == 0 {
            obj = commentsArr[indexPath.section] as commentNew
            comment_id = obj.id
        } else {
            obj = commentsArr[indexPath.section].repliesArr![indexPath.row - 1]
            comment_id = commentsArr[indexPath.section].id
        }
        
        commentTxtField.placeholder = "Reply to "+obj.userName+" "
        commentTxtField.text = "@"+obj.userName+" "
        commentTxtField.becomeFirstResponder()
    }
    
    func goToUserProfile(userID: String) {
        let storyMain = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyMain.instantiateViewController(withIdentifier: "newProfileVC") as!  newProfileViewController
        vc.isOtherUserVisting = true
        vc.hidesBottomBarWhenPushed = true
        vc.otherUserID = userID
        self.navigationController?.pushViewController(vc, animated: true)
        NotificationCenter.default.post(name: Notification.Name("pauseVideo"), object: nil)
    }
    
    func loginScreenAppear() {
        let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen

        self.present(navController, animated: true, completion: nil)
    }
    
    func updateObj(obj: commentNew, indexPath: IndexPath, islike:Bool) {
        if indexPath.row == 0 {
            self.commentsArr.remove(at: indexPath.section)
            self.commentsArr.insert(obj, at: indexPath.section)
        } else {
            self.commentsArr[indexPath.section].repliesArr?.remove(at: indexPath.row - 1)
            self.commentsArr[indexPath.section].repliesArr?.insert(obj, at: indexPath.row - 1)
        }
        
        if islike {
            self.likeComment(commentID: obj.id)
        }
    }
    
    func likeComment(commentID:String) {
        ApiHandler.sharedInstance.likeComment(comment_id: commentID) { (isSuccess, response) in
       
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    //print("likeVideo response msg: ",response?.value(forKey: "msg"))
                } else {
                    //print("likeVideo response msg: ",response?.value(forKey: "msg"))
                }
            }
        }
    }
    
    func deleteComment(comment_id: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Comment?", message: "Are you sure you want to delete the comment?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteCommentAPI(comment_id: comment_id, indexPath: indexPath)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        present(alert, animated: true, completion: nil)
    }
    
    // DELETE Comment
    func deleteCommentAPI(comment_id: String, indexPath: IndexPath) {
        ApiHandler.sharedInstance.deleteComment(comment_id: comment_id) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                let code = response?.value(forKey: "code") as! NSNumber
                if code == 200 {
                    DispatchQueue.main.async {
                        if indexPath.row == 0 {
                            self.commentsArr.remove(at: indexPath.section)
                        } else {
                            self.commentsArr[indexPath.section].repliesArr?.remove(at: indexPath.row - 1)
                        }
                        self.commentsTableView.reloadData()
                    }
                } else {
                    AppUtility?.displayAlert(title: "Try Again", message: "Something went wrong")
                }
            }
        }
    }
    
    //    MARK:- Get All Comments list
    
    /*func getComments() {
        commentsArr.removeAll()
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showVideoComments!
        //        let  sv = HomeViewController.displaySpinner(onView: self.out_view)
        //        UserDefaults.standard.object(forKey: "video_id")
        let parameter :[String:Any]? = ["video_id":video_id]
        
        //        let parameter :[String:Any]? = ["video_id":UserDefaults.standard.object(forKey: "video_id")!]
        
        print(url)
        print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
        
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                //                HomeViewController.removeSpinner(spinner: sv)
                
                self.commentsArr = []
                print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    let allComments = (dic["msg"] as? [[String:Any]])!
                    
                    //        MARK:- LBL NO COMMENT HIDDEN
                    if allComments.count == 0 {
                        self.loaderView.stopAnimating()
                        self.noCommentLbl.isHidden = false
                    } else {
                        self.loaderView.stopAnimating()
                    }
                    for Dict in allComments {
                        
                        let commentsDict = Dict as NSDictionary
                        var comments:String! = ""
                        var v_id:String! = ""
                        var c_id:String! = ""
                        var like_count:String! = ""
                        var like:String! = ""
                        var first_name:String! = ""
                        var last_name:String! = ""
                        var profile_pic:String! = ""
                        var c_time:String! = ""
                        if let comm =  commentsDict["comments"] as? String {
                            comments = comm
                            print("Comments:- ",comments!)
                        }
                        if let created =  commentsDict["created"] as? String {
                            c_time = created
                        }
                        if let myID =  commentsDict["video_id"] as? String {
                            v_id = myID
                        }
                        if let comment_id =  commentsDict["comment_id"] as? String {
                            c_id = comment_id
                        }
                        if let l_count =  commentsDict["like_count"] as? String {
                            like_count = l_count
                        }
                        
                        if let aLike =  commentsDict["like"] as? String {
                            like = aLike
                        }
                        if let u_info = commentsDict["user_info"] as? NSDictionary {
                            if let myFirest =  u_info["first_name"] as? String {
                                first_name = myFirest
                            }
                            if let myLast =  u_info["last_name"] as? String {
                                last_name = myLast
                            }
                            if let myPic =  u_info["profile_pic"] as? String {
                                profile_pic = myPic
                            }
                        }
                        
                        let userName = first_name + last_name
                        
                        print("time: ",c_time!)
                        //                        let obj = Comment(comments: comments, first_name: first_name, last_name: last_name,profile_pic: profile_pic, v_id: v_id,c_time:c_time)
                        let obj = commentNew(id: "", userName: userName, userID: "", comment: comments, imgName: profile_pic, time: c_time, like: like, like_count: like_count, vidID: "", commentID: c_id)
                        
                        self.commentsArr.append(obj)
                    }
                    
                    //                    self.comments_array = NSMutableArray(array: self.comments_array.reversed())
                    self.commentsArr = self.commentsArr.reversed()
                    
                    self.commentsTableView.delegate = self
                    self.commentsTableView.dataSource = self
                    self.commentsTableView.reloadData()
                    //                    if(self.commentsArr.count > 0){
                    //                        DispatchQueue.main.async {
                    //                            let indexPath = IndexPath(row: 0, section: 0)
                    //                            self.commentsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    //                        }
                    //                    }
                } else {
                }
                
            case .failure(let error):
                print("failure err",error)
                //                HomeViewController.removeSpinner(spinner: sv)
                //                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
    }*/
    
    func newGetComments() {
        commentsArr.removeAll()
        ApiHandler.sharedInstance.showVideoComments(video_id: self.video_id) { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let allComments = response?.value(forKey: "msg") as! [[String:Any]]
                    
                    self.loaderView.stopAnimating()
                    for Dict in allComments {
                        let commentsDict = Dict["VideoComment"] as! NSDictionary
                        //let vidDict = Dict["Video"] as! NSDictionary
                        let repliesDict = Dict["VideoCommentReply"] as! [[String:Any]]
                        let userDict = Dict["User"] as! NSDictionary
                        
                        let id = commentsDict.value(forKey: "id") as! String
                        let userID = commentsDict.value(forKey: "user_id") as! String
                        let vidID = commentsDict.value(forKey: "video_id") as! String
                        let commentID = commentsDict.value(forKey: "comment_id") as! String
                        let comment = commentsDict.value(forKey: "comment") as! String
                        let time = commentsDict.value(forKey: "created") as! String
                        let like = commentsDict.value(forKey: "like")
                        let like_count = commentsDict.value(forKey: "like_count")
                        
                        let userName = userDict.value(forKey: "username")
                        let userIMG = userDict.value(forKey: "profile_pic")
                        
                        var repliesArr = [commentNew]()
                        
                        for replyObj in repliesDict {
                            let replyDict = replyObj as NSDictionary
                            let id = replyDict.value(forKey: "id") as! String
                            let userID = replyDict.value(forKey: "user_id") as! String
                            let vidID = replyDict.value(forKey: "video_id") as! String
                            let commentID = replyDict.value(forKey: "comment_id") as! String
                            let comment = replyDict.value(forKey: "comment") as! String
                            let time = replyDict.value(forKey: "created") as! String
                            let like = replyDict.value(forKey: "like")
                            let like_count = replyDict.value(forKey: "like_count")
                            
                            let userDict = replyDict.value(forKey: "User") as! NSDictionary
                            let userName = userDict.value(forKey: "username")
                            let userIMG = userDict.value(forKey: "profile_pic")
                            
                            let obj = commentNew(id: id, userName: "\(userName!)", userID: userID, comment: comment, imgName: "\(userIMG!)", time: time, like: "\(like!)", like_count: "\(like_count!)", vidID: vidID, commentID: commentID, repliesCount: "0", repliesArr: nil, expanded: false)
                            
                            repliesArr.append(obj)
                        }
                        
                        let obj = commentNew(id: id, userName: "\(userName!)", userID: userID, comment: comment, imgName: "\(userIMG!)", time: time, like: "\(like!)", like_count: "\(like_count!)", vidID: vidID, commentID: commentID, repliesCount: "\(repliesDict.count)", repliesArr: repliesArr, expanded: false)
                     
                        self.commentsArr.append(obj)
                    }
                    
                    self.commentsArr = self.commentsArr.reversed()

                    self.commentsTableView.delegate = self
                    self.commentsTableView.dataSource = self
                    self.commentsTableView.reloadData()
                } else {
                    self.loaderView.stopAnimating()
                    self.noCommentLbl.isHidden = false
                }
            }
        }
    }
    
    //    MARK:- Dismiss click on anywhere on view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            NotificationCenter.default.post(name: Notification.Name("reloadVidDetails"), object: nil)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK:- BTN DONE DISABLE
    func doneDisable() {
        let v = commentTxtField.inputAccessoryView as? IQToolbar
        v?.doneBarButton.tintColor = UIColor.clear
        v?.doneBarButton.isEnabled = false
        
        //        commentTxtField.inputAccessoryView = .none
    }
    
    //    MARK:- Textfield action on done/send
    
    @IBAction func commentTxtFieldAction(_ sender: Any) {
        print("Send pressed")
        
        //        let ud = UserDefaults.standard
        //        let userImg = ud.object(forKey: "userImg")
        //        let firstName = ud.object(forKey: "userFirstName")
        //        let lastName = ud.object(forKey: "userLastName")
        
        print("userImg: ",userImg)
        print("Fullname: ",userFullName)
        //        print("lastName: ",lastName)
        
        
        let comment = commentTxtField.text
        guard let text = comment, !text.isEmpty else {
            showToast(message: "Enter a comment", font: .systemFont(ofSize: 14.0))
            return
        }
        print("comment guard:", text)  //do something if it's not empt
        
        let currentTime = Date()
        
        self.view.endEditing(true)
        newUpdateCommentsOnServer(cmnt: comment!)
        commentTxtField.placeholder = "Add comment..."
        commentTxtField.text = ""
        comment_id = "0"
    }
    
    //    MARK:- UPDATE COMMENTS
    /*func updateCommentsOnServer(cmnt:String) {
        //                     let obj = friends_array[index] as! Home
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.postComment!
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
        //                     let  sv = HomeViewController.displaySpinner(onView: view)
        
        self.loaderView.startAnimating()
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"video_id":self.video_id,"comment":cmnt]
        print(parameter!)
        
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                //                                            HomeViewController.removeSpinner(spinner: sv)
                self.loaderView.stopAnimating()
                print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200") {
                    self.getComments()
                    print("Updated comments on server::,,,, done 200")
                } else {
                }
                
            case .failure(let error):
                print(error)
            }
        })
    }*/
    
    func newUpdateCommentsOnServer(cmnt:String) {
        self.loaderView.startAnimating()
        ApiHandler.sharedInstance.postCommentOnVideo(user_id: UserDefaults.standard.string(forKey: "userID")!, comment: cmnt, video_id: self.video_id, comment_id: comment_id) { (isSuccess,response,err) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    self.loaderView.stopAnimating()
                    var data = [String:Any]()
                    data = ["SelectedIndex":self.index,"Count":self.commentsArr.count]
                    NotificationCenter.default.post(name: Notification.Name("commentVideo"), object: data)
                    self.newGetComments()
                } else {
                    self.loaderView.stopAnimating()
                }
            } else {
                self.showToast(message: err, font: .systemFont(ofSize: 12))
            }
        }
    }
    
    //    MARK:- FETCH USER INFO
    func getUserInfo() {
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.get_user_data!
        var userID = UserDefaults.standard.string(forKey: "userID")
        
        if userID == "" || userID == nil{
            userID = ""
        }
        let parameter :[String:Any]? = ["fb_id":/*UserDefaults.standard.string(forKey: "uid")!*/userID!]
        
        print(url)
        print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
        
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            respones in
            switch respones.result {
            case .success( let value):
                
                let json  = value
                            
                print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        
                        if  let sectionData = myCountry[0] as? NSDictionary{
                            
                            let firstName = sectionData["first_name"] as? String
                            let lastName = sectionData["last_name"] as? String
                            
                            self.userImg = (sectionData["profile_pic"] as? String)!
                            
                            self.userFullName = "\(firstName ?? "")\(lastName ?? "")"
                        }
                    }
                    
                } else {
                    print("unable to fetch user data",dic["msg"] as! String)
                }
  
            case .failure(let error):
                print(error)
                print("unable to fetch user data")
            }
        })
    }
    
    
    //    MARK:- TIME MANAGE
    func timeManage(ind:IndexPath) -> String{
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        print("hour: ",hour)
        print("minutes: ",minutes)
        print("time current data: ",date)
        
        let cmntTime = commentsArr[ind.section].time
        print("cmntTime: ",cmntTime)
        
        let dat = date.originToString(dateFormat: cmntTime+" +0000")
        print("time dat: ",dat)
        
        let previousDate = "\(cmntTime) +0000"
        //        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let previousDateFormated : Date? = dateFormatter.date(from: previousDate)
        //        let difference = currentDate.timeIntervalSince(previousDateFormated!)
        //        var differenceInDays = Int(difference/(60 * 60 * 24 ))
        //        print("difference from now: ",differenceInDays)
        print("previousDateFormated: ",previousDateFormated)
        
        
        previousDateFormated?.days(from: date)
        print("new time interval in minutes : ",previousDateFormated?.days(from: date))
        //        let finaldate = date.daysTo(Date(dat))
        //        print("final date: ",finaldate)
        
        let timeAgo = timeDiff(privTime: previousDateFormated!)
        print("Time Ago:- ",timeAgo)
        
        return "\(timeAgo)"
    }
    //    MARK:- Dismiss keyboard
    
    
    @IBAction func btnCross(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("reloadVidDetails"), object: nil)

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        dismiss(animated: true, completion: nil)
    }
    
    //    MARK:- COMMENT TIME AGO
    func timeDiff(privTime: Date) -> String {
        let currentDate = Date()
        let yearsRaw = privTime.years(from: currentDate)
        let monthsRaw = privTime.months(from: currentDate)
        let daysRaw = privTime.days(from: currentDate)
        let hoursRaw = privTime.hours(from: currentDate)
        let minutesRaw = privTime.minutes(from: currentDate)
        let secondsRaw = privTime.seconds(from: currentDate)
        
        //        negative sign remove
        let years = abs(yearsRaw)
        let months = abs(monthsRaw)
        let days = abs(daysRaw)
        let hours = abs(hoursRaw)
        let minutes = abs(minutesRaw)
        let seconds = abs(secondsRaw)
        print("years ago: ",years)
        print("months ago: ",months)
        print("days ago: ",days)
        print("hours ago: ",hours)
        print("minutes ago: ",minutes)
        print("seconds ago: ",seconds)
        
        if (seconds < 60 && seconds > 0)
        {
            return "\(seconds)s"
        }
        else if(minutes < 60 && minutes > 0){
            return "\(minutes)m"
        }
        else if(hours < 24 && minutes > 0){
            return "\(hours)h"
        }
        else if(days < 30 && days > 0){
            return "\(days)d"
        }
        else if(months < 12 && months > 0){
            return "\(months)m"
        }
        else if(years < 100 && years > 0){
            return "\(years)m"
        }
        
        return "Just Now"
    }
}

extension Date {
    func originToString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: self)
    }
}

public extension Date {
    func daysTo(_ date: Date) -> Int? {
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day  // This will return the number of day(s) between dates
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        var result: String = ""
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if seconds(from: date) > 0 { return "\(seconds(from: date))" }
        if days(from: date)    > 0 { result = result + " " + "\(days(from: date)) D" }
        if hours(from: date)   > 0 { result = result + " " + "\(hours(from: date)) H" }
        if minutes(from: date) > 0 { result = result + " " + "\(minutes(from: date)) M" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))" }
        return ""
    }
    
}
extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 175, y: self.view.frame.size.height*0.12, width: 350, height: 40))
        //    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.backgroundColor = #colorLiteral(red: 0.3129099309, green: 0.3177284598, blue: 0.3219906092, alpha: 0.8590539384)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 2;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
    

