


import UIKit
import Alamofire
import SDWebImage
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GIDSignInDelegate{
    
    @IBOutlet weak var inner_view: UIView!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var btn_menu: UIBarButtonItem!
    
    
    @IBOutlet weak var video_view: UIView!
    
    @IBOutlet weak var outer_view: UIView!
    @IBOutlet weak var user_img: UIImageView!
    
    @IBOutlet weak var lbl_video: UILabel!
    
    @IBOutlet weak var lbl_follow: UILabel!
    
    @IBOutlet weak var lbl_fan: UILabel!
    
    @IBOutlet weak var lbl_heart: UILabel!
    
    @IBOutlet weak var video_img: UIImageView!
    
    @IBOutlet weak var like_img: UIImageView!
    
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    var first_name:String! = ""
    var last_name:String! = ""
    var email:String! = ""
    var my_id:String! = ""
    var profile_pic:String! = ""
    var signUPType:String! = ""
    
    var allVideos:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        video_view.layer.cornerRadius = 15.0
        video_view.clipsToBounds = true
        
        user_img.layer.masksToBounds = false
        user_img.layer.cornerRadius = user_img.frame.height/2
        user_img.clipsToBounds = true
        
    
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
            UIApplication.shared.statusBarStyle = .default
        
        
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
            self.inner_view.alpha = 1
            
            btn_menu.tintColor = UIColor.clear
            self.navigationItem.title = "Login"
            
          self.navigationItem.rightBarButtonItem?.isEnabled = false
            
        }else{
            self.inner_view.alpha = 0
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            btn_menu.tintColor = UIColor.black
            self.navigationItem.title = "Profile"
            self.getAllVideos()
        }
    }
    
    // Facbook Login
    
    @IBAction func FBLogin(_ sender: Any) {
        
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        
                       
                    }
                }
            }
        }
        
    }
    
    func getFBUserData(){
        
        let sv = HomeViewController.displaySpinner(onView: self.view)
        if((AccessToken.current) != nil){
            
            print("access token fb: ",AccessToken.current!)
            
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email,age_range"]).start(completion: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as! [String : AnyObject]
                    print(dict)
                    if let dict = result as? [String : AnyObject]{
                        if(dict["email"] as? String == nil || dict["id"] as? String == nil || dict["email"] as? String == "" || dict["id"] as? String == "" ){
                            
                            HomeViewController.removeSpinner(spinner: sv)
                            
                            self.alertModule(title:"Error", msg:"You cannot login with this facebook account because your facebook is not linked with any email")
                            
                        }else{
                            HomeViewController.removeSpinner(spinner: sv)
                            self.email = dict["email"] as? String
                            self.first_name = dict["first_name"] as? String
                            self.last_name = dict["last_name"] as? String
                            self.my_id = dict["id"] as? String
                            let dic1 = dict["picture"] as! NSDictionary
                            let pic = dic1["data"] as! NSDictionary
                            self.profile_pic = pic["url"] as? String
                            
                            self.signUPType = "facebook"
                         
                            self.SignUpApi()
                            
                        }
                    }
                    
                }else{
                    
                    HomeViewController.removeSpinner(spinner: sv)
                    
                    
                }
            })
        }
        
    }
    
    // get All videos api
    
    
    func getAllVideos(){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showMyAllVideos!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let parameter :[String:Any]? = ["my_fb_id":UserDefaults.standard.string(forKey: "uid")!,"fb_id":UserDefaults.standard.string(forKey: "uid")!]
        
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
                
                HomeViewController.removeSpinner(spinner: sv)
                
                self.allVideos = []
                print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                      

                        if  let sectionData = myCountry[0] as? NSDictionary{
                            
                            let user_info = sectionData["user_info"] as? NSDictionary
                            let str1:String! = (user_info!["first_name"] as! String)
                            let str2:String! = (user_info!["last_name"] as! String)
                            self.navigationItem.title = str1+" "+str2
                            
                            self.user_img.sd_setImage(with: URL(string:user_info!["profile_pic"] as! String), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
                                                        
                            self.lbl_follow.text = sectionData["total_following"] as? String
                            self.lbl_fan.text = sectionData["total_fans"] as? String
                            self.lbl_heart.text = sectionData["total_heart"] as? String
                            
                            if let  myCountry1 = (sectionData["user_videos"] as? [[String:Any]]){
                            for Dict in myCountry1 {
                                
                                
                                
                                let count = Dict["count"] as! NSDictionary
                                let sound = Dict["sound"] as! NSDictionary
                                
                                let like_count = count["like_count"] as! String
                                let video_comment_count = count["video_comment_count"] as! String
                                let view = count["view"] as! String
                                let thum = Dict["gif"] as! String
                                let liked = Dict["liked"] as! String
                                let sound_name = sound["sound_name"] as? String ?? ""
                                let video = Dict["video"] as! String
                                let v_id = Dict["id"] as! String
                                
                                let first_name = user_info?["first_name"] as! String
                                let last_name = user_info?["last_name"] as! String
                                let profile_pic = user_info?["profile_pic"] as! String
                                
                                 let u_id = user_info?["fb_id"] as! String
                                
                                let obj = Videos(video: video, thum: thum, liked: liked,like_count: like_count, video_comment_count: video_comment_count,first_name: first_name, last_name: last_name, profile_pic: profile_pic,sound_name: sound_name, v_id: v_id, view: view,u_id:u_id)
                                
                                self.allVideos.add(obj)
                               
                                }
                            }
                            
                        }
                    }

                    if(self.allVideos.count == 0){
                        
                        self.lbl_video.text = "0 Video"
                        
                        self.outer_view.alpha = 1
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                        
                    }else{
                        
                        self.lbl_video.text = String(self.allVideos.count)+" Videos"
                        
                        self.outer_view.alpha = 0
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                    }
                    
                    
                    
                    
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
                
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        
    }
    
    // get only like videos api
    
    func getLikeVideos(){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.my_liked_video!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!]
        
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
                
                HomeViewController.removeSpinner(spinner: sv)
                
                self.allVideos = []
                print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        
                        
                        if  let sectionData = myCountry[0] as? NSDictionary{
                            
                            let user_info = sectionData["user_info"] as? NSDictionary
                            let str1:String! = (user_info!["first_name"] as! String)
                            let str2:String! = (user_info!["last_name"] as! String)
                            self.navigationItem.title = str1+" "+str2
                            
                            self.user_img.sd_setImage(with: URL(string:user_info!["profile_pic"] as! String), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
                            
                            self.lbl_follow.text = sectionData["total_following"] as? String
                            self.lbl_fan.text = sectionData["total_fans"] as? String
                            self.lbl_heart.text = sectionData["total_heart"] as? String
                            
                         if let myCountry1 = sectionData["user_videos"] as? [[String:Any]]{
                            for Dict in myCountry1 {
                                
                                
                                
                                let count = Dict["count"] as! NSDictionary
                                let sound = Dict["sound"] as! NSDictionary
                                
                                let like_count = count["like_count"] as! String
                                let video_comment_count = count["video_comment_count"] as! String
                                let view = count["view"] as! String
                                let thum = Dict["gif"] as! String
                                let liked = Dict["liked"] as! String
                                let sound_name = sound["sound_name"] as? String ?? ""
                                let video = Dict["video"] as! String
                                let v_id = Dict["id"] as! String
                                
                                let first_name = user_info?["first_name"] as! String
                                let last_name = user_info?["last_name"] as! String
                                let profile_pic = user_info?["profile_pic"] as! String
                                
                                let u_id = user_info?["fb_id"] as? String
                                
                                let obj = Videos(video: video, thum: thum, liked: liked,like_count: like_count, video_comment_count: video_comment_count,first_name: first_name, last_name: last_name, profile_pic: profile_pic,sound_name: sound_name, v_id: v_id, view: view, u_id: u_id)
                                
                                self.allVideos.add(obj)
                                
                                
                            }
                            
                        }
                    }
                    }
                    
                    if(self.allVideos.count == 0){
                        
                        self.lbl_video.text = "0 Video"
                        
                        self.outer_view.alpha = 1
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                        
                    }else{
                        
                        self.lbl_video.text = String(self.allVideos.count)+" Videos"
                        
                        self.outer_view.alpha = 0
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                    }
                    
                    
                    
                    
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
                
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        
    }
    
    // Collectionview Deleagte methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.allVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:ProfileCell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "cellProfile", for: indexPath) as! ProfileCell
        let obj = self.allVideos[indexPath.item] as! Videos
        cell.lbl_seen.text = obj.view
        
        cell.video_image.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"Spinner-1s-200px.gif"))
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj = self.allVideos[indexPath.item] as! Videos
        
        UserDefaults.standard.set(obj.video, forKey: "dis_url")
        UserDefaults.standard.set(obj.thum, forKey: "dis_img")
        StaticData.obj.userName = obj.first_name+" "+obj.last_name
        StaticData.obj.userImg = obj.profile_pic
        StaticData.obj.liked = obj.liked
        StaticData.obj.comment_count = obj.video_comment_count
        StaticData.obj.like_count = obj.like_count
        StaticData.obj.soundName = obj.sound_name
        StaticData.obj.videoID = obj.v_id
        StaticData.obj.other_id = obj.u_id
        DispatchQueue.main.async {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController

            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.layer.frame.width / 3, height:  collectionView.layer.frame.width / 3)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    
    @IBAction func videoChange(_ sender: Any) {
        
        self.getAllVideos()
        
        self.video_img.image = UIImage(named:"Untitled-1-3")
        self.like_img.image = UIImage(named:"Untitled-1-2")
        
        
    }
    
    @IBAction func likeChange(_ sender: Any) {
        
        self.getLikeVideos()
        
        self.video_img.image = UIImage(named:"Untitled-1-1")
        self.like_img.image = UIImage(named:"Untitled-1-4")
        
    }
    
    @IBAction func options(_ sender: Any) {
        
        let actionSheet =  UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Edit Profile", style: .default, handler: {
            (_:UIAlertAction)in
            
            
            
            self.performSegue(withIdentifier:"gotoedit", sender: self)
            
        })
        
        let gallery = UIAlertAction(title: "Logout", style: .destructive, handler: {
            (_:UIAlertAction)in
            
            UserDefaults.standard.set("", forKey: "uid")
            self.navigationItem.title = "Profile"
             self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.tabBarController?.selectedIndex = 1
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (_:UIAlertAction)in
            
        })
        actionSheet.addAction(camera)
        
        actionSheet.addAction(gallery)
        //actionSheet.addAction(Giphy)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.user_img
        }
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    // Gmail Login
    
    func GoogleApi(user: GIDGoogleUser!){
        
        let sv = HomeViewController.displaySpinner(onView: self.view)
        
        if(user.profile.email == nil || user.userID == nil || user.profile.email == "" || user.userID == ""){
            
            
            
            HomeViewController.removeSpinner(spinner: sv)
            self.alertModule(title:"Error", msg:"You cannot signup with this Google account because your Google is not linked with any email.")
            
        }else{
            
            
            HomeViewController.removeSpinner(spinner: sv)
            //SliderViewController.removeSpinner(spinner: sv)
            self.email = user.profile.email
            self.first_name = user.profile.givenName
            self.last_name = user.profile.familyName
            self.my_id = user.userID
            if user.profile.hasImage
            {
                let pic = user.profile.imageURL(withDimension: 100)
                self.profile_pic = pic!.absoluteString
                
            }else{
                self.profile_pic = ""
            }
            
            self.signUPType = "google"
            self.SignUpApi()
        }
        
        
    }
    
    // Register Api
    
    func SignUpApi(){
        
        
        let ud = UserDefaults.standard
        ud.set(self.profile_pic, forKey: "userImg")
        ud.set(self.first_name, forKey: "userFirstName")
        ud.set(self.last_name, forKey: "userLastName")
        ud.set(self.signUPType, forKey: "signupType")
        
        
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        var VersionString:String! = ""
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            VersionString = version
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.signUp!
        
        let parameter:[String:Any]?  = ["fb_id":self.my_id!,"first_name":self.first_name!,"last_name":self.last_name!,"profile_pic":self.profile_pic!,"gender":"m","signup_type":self.signUPType!,"version":VersionString!,"device":"iOS"]
        
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
                HomeViewController.removeSpinner(spinner: sv)
                print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    let myCountry = dic["msg"] as? NSArray
                    if let data = myCountry![0] as? NSDictionary{
                        print(data)
                    
                   
                        let uid = data["fb_id"] as! String
                    
                 
                    UserDefaults.standard.set(uid, forKey: "uid")
                        
                    
                   self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.inner_view.alpha = 0
                        
                    self.btn_menu.tintColor = UIColor.black
                    
                    self.getAllVideos()
                    }
                    
                }else{
                    
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
            case .failure(let error):
                
                print(error)
                
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
                
                
            }
        })
        
        
        
    }
    
    @IBAction func GoogleLogin(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //UIActivityIndicatorView.stopAnimating()
    }
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            // Perform any operations on signed in user here.
            self.GoogleApi(user: user)
            
            // ...
        } else {
            
            //            self.view.isUserInteractionEnabled = true
            //            KRProgressHUD.dismiss {
            //                print("dismiss() completion handler.")
            //
            //            }
            print("\(error.localizedDescription)")
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        
        
        
    }
    
    @IBAction func privacy(_ sender: Any) {
        
        guard let url = URL(string: "https://termsfeed.com/privacy-policy/9a03bedc2f642faf5b4a91c68643b1ae") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func terms(_ sender: Any) {
        
        guard let url = URL(string: "https://termsfeed.com/terms-conditions/72b8fed5b38e082d48c9889e4d1276a9") else { return }
        UIApplication.shared.open(url)
        
    }

    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @available(iOS 13.0, *)
    @IBAction func applelogin(_ sender: Any) {
        
        self.setupAppleIDCredentialObserver()
        let appleSignInRequest = ASAuthorizationAppleIDProvider().createRequest()
        appleSignInRequest.requestedScopes = [.fullName, .email]

         let controller = ASAuthorizationController(authorizationRequests: [appleSignInRequest])
         controller.delegate = self
         controller.presentationContextProvider = self

         controller.performRequests()
        
    }
    
    @available(iOS 13.0, *)
    private func setupAppleIDCredentialObserver() {
         let authorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
         authorizationAppleIDProvider.getCredentialState(forUserID: "currentUserIdentifier") { (credentialState: ASAuthorizationAppleIDProvider.CredentialState, error: Error?) in
           if let error = error {
             print(error)
             // Something went wrong check error state
             return
           }
           switch (credentialState) {
           case .authorized:
             //User is authorized to continue using your app
             break
           case .revoked:
             //User has revoked access to your app
             break
           case .notFound:
             //User is not found, meaning that the user never signed in through Apple ID
             break
           default: break
           }
         }
       }
    
    

}
extension ProfileViewController: ASAuthorizationControllerDelegate {
    @available(iOS 12.0, *)
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

        print("User ID: \(appleIDCredential.user)")
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print(appleIDCredential)
        case let passwordCredential as ASPasswordCredential:
            print(passwordCredential)
        default: break
        }
        
        
        if let userEmail = appleIDCredential.email {
                     print("Email: \(userEmail)")
                       self.email = userEmail
                       self.my_id = appleIDCredential.user
                   }

                   if let userGivenName = appleIDCredential.fullName?.givenName,
                       
                     let userFamilyName = appleIDCredential.fullName?.familyName {
                       //print("Given Name: \(userGivenName)")
                      // print("Family Name: \(userFamilyName)",
                        self.my_id = appleIDCredential.user
                       self.first_name = userGivenName
                       self.last_name = userFamilyName
                       
                    print("my id apple: ",my_id)
                       
                   
                   
                       self.my_id = appleIDCredential.user
//                      self.first_name = userGivenName
//                      self.last_name = userFamilyName
                      
                   print("my id apple: ",my_id)

                   if let authorizationCode = appleIDCredential.authorizationCode,
                     let identifyToken = appleIDCredential.identityToken {
                     print("Authorization Code: \(authorizationCode)")
                     print("Identity Token: \(identifyToken)")
                     //First time user, perform authentication with the backend
                     //TODO: Submit authorization code and identity token to your backend for user validation and signIn
                       //self.signUp(self)
                      // if(self.email != ""){
                           
                           self.signUPType = "apple"
                           self.profile_pic = ""
                           self.SignUpApi()
                      // }else{
                        
                        //self.alertModule(title:"Error", msg: "Please share your email.")
                   // }
          return
        }
//                    MARK:- JK
                    }else{
                          self.my_id = appleIDCredential.user
                        self.signUPType = "apple"
                        self.profile_pic = ""
                    UserDefaults.standard.set(self.my_id, forKey: "uid")
                    inner_view.alpha = 0
                    self.getAllVideos()
//                    dismiss(animated: true, completion: nil)
                    }
        //TODO: Perform user login given User ID
        
        
        
        
      }
      
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization returned an error: \(error.localizedDescription)")
      }
    }
    extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
        @available(iOS 13.0, *)
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
      }
}
