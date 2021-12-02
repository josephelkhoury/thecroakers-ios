//
//  liveUsersViewController.swift
//  zarathx
//
//  Created by Mac on 14/12/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import AgoraRtcKit
import SDWebImage

class liveUsersViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
 
    @IBOutlet weak var liveUserCollectionView: UICollectionView!
    
    let commentsArr = [commentNew]()
    
    private lazy var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: nil)
        engine.setLogFilter(AgoraLogFilter.info.rawValue)
        engine.setLogFile(FileCenter.logFilePath())
        return engine
    }()
   
    var arrliveUser = [[String:Any]]()
    var isNotification = false
    var ip = 0
    
    private var settings = Settings()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.getAllLivesUser()
       
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        if isNotification == false{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier,
            segueId.count > 0 else {
            return
        }
        
        switch segueId {
        case "usersToLive":
            let liveVC = segue.destination as? LiveRoomViewController
            
            liveVC?.isAudiance = true
            liveVC?.userImgString = self.arrliveUser[ip]["user_picture"] as!String
            liveVC?.userNameString  = self.arrliveUser[ip]["user_name"] as! String
            settings.role = .audience
            settings.roomName = self.arrliveUser[ip]["user_id"] as? String
            
            print(self.arrliveUser[ip]["id"] as? String)
            print("ip: ",ip)

            print(settings.roomName)
            liveVC?.dataSource = self
            
        default:
            break
        }
        
    }
    //MARK:-Firebase
    
    func getAllLivesUser(){
        let sv = HomeViewController.displaySpinner(onView: self.view)
        let reference = Database.database().reference()
        let LiveUser = reference.child("LiveUsers")
        LiveUser.observe(.value) { [self] (snapshot) in
            HomeViewController.removeSpinner(spinner: sv)
            self.arrliveUser.removeAll()
            for users in snapshot.children.allObjects as! [DataSnapshot] {
                print(users.value)
                self.arrliveUser.append(users.value as! [String:Any])
                
                self.liveUserCollectionView.reloadData()
            }
            if self.arrliveUser.count == 0 {
                self.liveUserCollectionView.isHidden =  true
            }else{
                self.liveUserCollectionView.isHidden =  false
            }
        }
        
    }

    //MARK:- Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrliveUser.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "liverUserCVC", for: indexPath) as! liverUserCollectionViewCell
        cell.lblName.text =  self.arrliveUser[indexPath.row]["user_name"] as! String
        let CoverImgURL =  self.arrliveUser[indexPath.row]["user_picture"] as!String
        print(CoverImgURL)
        cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.white
        cell.imgUser.sd_setImage(with: URL(string: (AppUtility?.detectURL(ipString: CoverImgURL))!), placeholderImage: UIImage(named: "videoPlaceholder"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LiveRoomVC") as! LiveRoomViewController
        let navigationController = UINavigationController(rootViewController: vc)
//        KeyCenter.isAudience =  true
        navigationController.modalPresentationStyle = .fullScreen
////
//        vc.isAudiance = true
//        vc.userNameString = (self.arrliveUser[indexPath.row]["user_name"] as! String)
//        vc.userImgString = (self.arrliveUser[indexPath.row]["user_picture"] as! String)
//
//        settings.roomName = (self.arrliveUser[indexPath.row]["user_id"] as! String)
//        settings.role = .audience
//        vc.dataSource = self
        print(self.arrliveUser[indexPath.row]["user_id"] as! String)
        StaticData.obj.liveUserID = self.arrliveUser[indexPath.row]["user_id"] as! String
        StaticData.obj.liveUserName = self.arrliveUser[indexPath.row]["user_name"] as! String

        
        self.ip = indexPath.row
        
        performSegue(withIdentifier: "usersToLive", sender: nil)
        
        
//        navigationController.navigationBar.isHidden =  true
//        self.present(navigationController, animated: true, completion: nil)
      
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            let noOfCellsInRow = 2
            
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
            
            let size = Int((liveUserCollectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            
            return CGSize(width: size, height: 250)
        
    }
    
}
extension liveUsersViewController: LiveVCDataSource {
    func liveVCNeedSettings() -> Settings {
        return settings
    }
    
    func liveVCNeedAgoraKit() -> AgoraRtcEngineKit {
        return agoraKit
    }
}

extension liveUsersViewController: SettingsVCDelegate {
    func settingsVC(_ vc: SettingsViewController, didSelect dimension: CGSize) {
        settings.dimension = dimension
    }
    
    func settingsVC(_ vc: SettingsViewController, didSelect frameRate: AgoraVideoFrameRate) {
        settings.frameRate = frameRate
    }
}

extension liveUsersViewController: SettingsVCDataSource {
    func settingsVCNeedSettings() -> Settings {
        return settings
    }
}

