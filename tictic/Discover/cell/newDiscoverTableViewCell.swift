//
//  newDiscoverTableViewController.swift
//  TIK TIK
//
//  Created by Mac on 26/10/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import SDWebImage

//@available(iOS 13.0, *)
class newDiscoverTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    var arrData = ["night3","night2","night3","night3","night2","night3"]
    @IBOutlet weak var discoverCollectionView: UICollectionView!
    
    @IBOutlet var entityImageView: UIImageView!
    @IBOutlet weak var lblItemCount: UILabel!
    @IBOutlet weak var hashName : UILabel!
    @IBOutlet weak var hashNameSub : UILabel!
    @IBOutlet weak var viewCountVideo: UIView!
    @IBOutlet weak var arrow: UIImageView!
    
    var videosObj = [videoMainMVC]()
    var section = "0"
    
    //MARK:- Outlets
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    //MARK:- SetupView
    
    func setupView(){
        self.arrow.tintColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        self.viewCountVideo.layer.cornerRadius = 5
    }
    
    //MARK:- Switch Action
    
    //MARK:- Button Action
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videosObj.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier:"newDiscoverCVC" , for: indexPath) as! newDiscoverCollectionViewCell
        
        let vidObj = videosObj[indexPath.row]
//        cell.img.sd_setImage(with: URL(string:vidObj.videoGIF), placeholderImage: UIImage(named: "videoPlaceholder"))
        
        let gifURL : String = (AppUtility?.detectURL(ipString: vidObj.videoGIF))!
//        let imageURL = UIImage.gifImageWithURL(gifURL)
//        cell.img.image = imageURL
        
        cell.img.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.img.sd_setImage(with: URL(string:(gifURL)), placeholderImage: UIImage(named:"videoPlaceholder"))

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
        return CGSize(width: self.discoverCollectionView.frame.size.width/4, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let rootViewController = UIApplication.topViewController() {
            let storyMain = UIStoryboard(name: "Main", bundle: nil)
            let vc =  storyMain.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
            vc.videosMainArr =  self.videosObj
            vc.isOtherController = true
            vc.currentIndex = indexPath
            vc.hidesBottomBarWhenPushed = true
           /* let vc =  storyMain.instantiateViewController(withIdentifier: "homeFeedVC") as! homeFeedViewController
            vc.discoverVideoArr = videosObj
            vc.indexAt = indexPath
            vc.currentVidIP = indexPath
            vc.hidesBottomBarWhenPushed = true*/
            rootViewController.navigationController?.pushViewController(vc, animated: true)
        }
        print("videosObj.count",videosObj.count)
        print(indexPath.row)
    }
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    //MARK: Location
    
    //MARK: Google Maps
    
    //MARK:- View Life Cycle End here...

}
