//
//  AppDelegate.swift
//  MusicTok
//
//  Created by Mac on 24/04/2019.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKCoreKit
import FirebaseCore
import GoogleSignIn
import FirebaseMessaging
import UserNotifications
import SDWebImage

let NextLevelAlbumTitle = "NextLevel"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    // Web Apis Urls
    
    var baseUrl:String? = ""
    var imgbaseUrl:String? = ""
    var sharURl:String? =  ""
    var signUp:String? = "signup"
    var uploadVideo:String? = "uploadVideo_json"
    var showAllVideos:String? = "showAllVideos"
    var showMyAllVideos:String? = "showMyAllVideos"
    var likeDislikeVideo:String? = "likeDislikeVideo"
    var postComment:String? = "postComment"
    var showVideoComments:String? = "showVideoComments"
    var updateVideoView:String? = "updateVideoView"
    var fav_sound:String? = "fav_sound"
    var my_FavSound:String? = "my_FavSound"
    var allSounds:String? = "allSounds"
    var my_liked_video:String? = "my_liked_video"
    var discover:String? = "discover"
    var edit_profile:String? = "edit_profile"
    var follow_users:String? = "follow_users"
    var get_user_data:String? = "get_user_data"
    var uploadImage:String? = "uploadImage"
    var get_followers:String? = "get_followers"
    var get_followings:String? = "get_followings"
    var downloadFile:String? = "downloadFile"
    var getNotifications:String? = "getNotifications"
    var uploadMultipartVideo:String? = "uploadVideo"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let bundleIdentifier =  Bundle.main.bundleIdentifier
        StaticData.obj.BundleIdentifer = bundleIdentifier!
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        //AppUtility?.getIPAddress()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self //as? UNUserNotificationCenterDelegate
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().subscribe(toTopic: "topicEventSlotUpdated")
        
        application.registerForRemoteNotifications()
        
        UserDefaults.standard.set("", forKey: "otherUserID")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled=ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)  || handled
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            //let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaults.standard.set(fcmToken, forKey:"DeviceToken")
        print("fcm firebase token notification: ", fcmToken)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NotificationCenter.default.post(name: Notification.Name("removeLiveUserNoti"), object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
        Messaging.messaging().token { (token, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error.localizedDescription)")
            } else if let token = token {
                print("Token is \(token)")
                AppUtility?.addDeviceData()
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingMessageInfo) {
        guard let data = try? JSONSerialization.data(withJSONObject: remoteMessage, options: .prettyPrinted),
              let prettyPrinted = String(data: data, encoding: .utf8) else {
            return
        }
        print(remoteMessage)
        let res = remoteMessage
        print(res)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
    }
    
    // Firebase notification received
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        
        print("Handle push from Active state, received: \n \(notification.request.content)")
        print(notification.request.content.userInfo)
        
        let type  = notification.request.content.userInfo[AnyHashable("gcm.notification.type")] as? String
        //let request_id  = notification.request.content.userInfo[AnyHashable("gcm.notification.request_id")] as? String
        //let receiver_id  = notification.request.content.userInfo[AnyHashable("gcm.notification.user_id")] as? String
        //let receiver_name  = notification.request.content.userInfo[AnyHashable("gcm.notification.name")] as? String
        print(type)
        if type == "single_message" {
            
        } else {
            //            self.activeRequestAPI()
        }
        /*
         do {
         let notification = try MTNotificationBuilder.build(from: notification.request.content.userInfo)
         print(notification.alert)
         print(notification.body)
         print(notification.title)
         
         if notification.title == "Paid"{
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "paidNoti"), object: nil)
         }
         } catch let error {
         print(error)
         }
         */
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle tapped push from background, received: \n \(response.notification.request.content)")
        print(response.notification.request.content.userInfo)
        let userInfo = response.notification.request.content.userInfo as! [String:Any]
        
        let type  = userInfo["type"] as? String
        //let request_id  = userInfo["gcm.notification.request_id"] as? String
        //let receiver_id  = userInfo["gcm.notification.user_id"] as? String
        //let receiver_name  = userInfo["gcm.notification.name"] as? String
        print(userInfo)
        if type == "single_message" {
            
            //let storyMain = UIStoryboard(name: "Main", bundle: nil)
            //            if let rootViewController = UIApplication.topViewController() {
            //                let vc =  storyMain.instantiateViewController(withIdentifier: "newChatViewController") as! newChatViewController
            //                vc.modalPresentationStyle = .overFullScreen
            //                vc.isNotification =  false
            //                vc.requestID = request_id ?? "0"
            //                vc.receiverID = receiver_id ?? "0"
            //                vc.receiverName = receiver_name ?? "unknown"
            //                rootViewController.navigationController?.pushViewController(vc, animated: true)
            //            }
        } else {
            //            self.activeRequestAPI()
        }
        
        completionHandler()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    }
}
