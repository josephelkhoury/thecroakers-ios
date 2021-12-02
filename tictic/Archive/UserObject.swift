//
//  UserObject.swift
//  GrabMyTaxiDriver
//
//  Created by Mac on 11/02/2021.
//


import Foundation
import UIKit

class UserObject{
    
    var myswitchAccount: [switchAccount]? {didSet {}}
   
    static let shared = UserObject()
    
    
    func Objresponse(response:[String:Any]){
        
        self.myswitchAccount = switchAccount.readswitchAccountFromArchive()
        
        let userObjMsg = response["msg"] as! [String:Any]
        let userObj = userObjMsg["User"] as! NSDictionary
        print("user obj: ",userObj)
        let user = switchAccount()
            
        user.id = userObj.value(forKey: "id") as? String
        user.active = userObj.value(forKey: "active") as? String
        user.city = userObj.value(forKey: "city") as? String
        
        //user id for login
        UserDefaults.standard.set(userObj.value(forKey: "id") as? String, forKey: "userID")
        UserDefaults.standard.set(userObj.value(forKey: "auth_token") as? String, forKey: "authToken")

        user.country = userObj.value(forKey: "country") as? String
        user.created = userObj.value(forKey: "created") as? String
        user.device = userObj.value(forKey: "device") as? String
        user.dob = userObj.value(forKey: "dob") as? String

        user.email = userObj.value(forKey: "email") as? String
        user.fb_id = userObj.value(forKey: "fb_id") as? String

        user.first_name = userObj.value(forKey: "first_name") as? String
        user.gender = userObj.value(forKey: "gender") as? String
        user.last_name = userObj.value(forKey: "last_name") as? String
        user.ip = userObj.value(forKey: "ip") as? String
        user.lat = userObj.value(forKey: "lat") as? String
        user.long = userObj.value(forKey: "long") as? String
        user.online = userObj.value(forKey: "online") as? String
        user.password = userObj.value(forKey: "password") as? String
        user.phone = userObj.value(forKey: "phone") as? String
        user.bio = userObj.value(forKey: "bio") as? String

        user.profile_pic = userObj.value(forKey: "profile_pic") as? String
        user.role = userObj.value(forKey: "role") as? String
        user.social = userObj.value(forKey: "social") as? String
        user.social_id = userObj.value(forKey: "social_id") as? String
        user.username = userObj.value(forKey: "username") as? String
        user.verified = userObj.value(forKey: "verified") as? String
        user.version = userObj.value(forKey: "version") as? String
        user.website = userObj.value(forKey: "website") as? String

        user.comments = userObj.value(forKey: "comments") as? String
        user.direct_messages = userObj.value(forKey: "direct_messages") as? String

        user.likes = userObj.value(forKey: "likes") as? String
        user.mentions = userObj.value(forKey: "mentions") as? String
        user.new_followers = userObj.value(forKey: "new_followers") as? String
        user.video_updates = userObj.value(forKey: "video_updates") as? String
        user.direct_message = userObj.value(forKey: "direct_message") as? String

        user.duet = userObj.value(forKey: "duet") as? String
        user.liked_videos = userObj.value(forKey: "liked_videos") as? String
        user.video_comment = userObj.value(forKey: "video_comment") as? String
        user.videos_download = userObj.value(forKey: "videos_download") as? String
        
        AppUtility?.addDeviceData()
       
        if (myswitchAccount != nil && myswitchAccount?.count != 0){
            print("Multiple user Login on this app")
            self.myswitchAccount?.append(user)
        }else{
            print("First user Login on this app")
            self.myswitchAccount = [user]
        }
        
        if switchAccount.saveswitchAccountToArchive(switchAccount: self.myswitchAccount!) {
            print("User_Switch_Account Saved in Directory")
        }
    }
}
