//
//  CoinShareViewController.swift
//  MusicTok
//
//  Created by Mac on 29/04/2021.
//  Copyright © 2021 Dinosoftlabs. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class CoinShareViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
        
    //MARK:- Outlets
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var TotalCoin: UILabel!
    @IBOutlet weak var collectionViewAllCoinStickers: UICollectionView!
    @IBOutlet var viewHide: UIView!
    
    
    //MARK:- Variables
    var myUser:[User]? {didSet{}}
    var gift_count = ""
    var sticker_id  = ""
   // var coin_receiverID = ""
    var getAllCoinStricker = [[String:Any]]()
    var userData = [userMVC]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAllCoinsSticker()
        self.lblShare.text =  "Send gift to \(StaticData.obj.liveUserName)"
        self.TotalCoin.text! =  UserDefaults.standard.value(forKey: "wallet") as? String ?? "0"
        let tab =  UITapGestureRecognizer(target: self, action: #selector(self.hide(tab:)))
        viewHide.isUserInteractionEnabled =  true
        viewHide.addGestureRecognizer(tab)
      
    }

    
    
    
    //MARK:- Method
    @objc func hide(tab:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }

    
    //MARK:- Button Action
    @IBAction func btnRecchargeAction(_ sender: Any) {
        print(gift_count)
        print(UserDefaults.standard.value(forKey: "wallet") as? String ?? "0")
        if  Int(self.gift_count)!  >  Int(UserDefaults.standard.value(forKey: "wallet") as? String ?? "0")!{

            print("Please Recharge")
            self.alertModule(title: "Recharge", msg: "Please recharge, you have not enough coins")
            return
        }
        self.send_Coin(sticker_id:self.sticker_id , gift_count: self.gift_count)
    }
    
    
    //MARK:- CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.getAllCoinStricker.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetAllCoinsCollectionViewCell" , for: indexPath) as! GetAllCoinsCollectionViewCell
        let obj = self.getAllCoinStricker[indexPath.row]["Gift"] as! [String:Any]
        cell.lblCoinName.text =  obj["title"] as! String
        cell.lblCoinNumber.text =  obj["coin"] as! String
        let objremove = ApiHandler.sharedInstance.baseApiPath.replacingOccurrences(of: "api/", with: "")
        let CoverImgURL =  "\(objremove)\( obj["image"] as! String)"
        print(CoverImgURL)
        cell.imgCoin.sd_imageIndicator = SDWebImageActivityIndicator.white
        cell.imgCoin.sd_setImage(with: URL(string: CoverImgURL), placeholderImage: UIImage(named: "ic_coin"))
        if self.getAllCoinStricker[indexPath.row]["selected"] as! String == "1"{
            cell.tick.isHidden =  false
            
        }else{
            cell.tick.isHidden =  true

        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = self.getAllCoinStricker[indexPath.row]["Gift"] as! [String:Any]
        for var i in 0..<self.getAllCoinStricker.count{
            var obj = self.getAllCoinStricker[i]
            obj.updateValue("0", forKey: "selected")
            self.getAllCoinStricker.remove(at: i)
            self.getAllCoinStricker.insert(obj, at: i)
        }
        var obj1 = self.getAllCoinStricker[indexPath.row]
        obj1.updateValue("1", forKey: "selected")
        self.getAllCoinStricker.remove(at: indexPath.row)
        self.getAllCoinStricker.insert(obj1, at: indexPath.row)
        self.gift_count = obj["coin"] as! String
        self.sticker_id = obj["id"] as! String
        self.collectionViewAllCoinStickers.reloadData()
        
       // self.send_Coin(sticker_id: obj["id"] as! String, gift_count: obj["coin"] as! String)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:collectionViewAllCoinStickers.frame.size.width/4, height:100)
        
    }
    
    
    //MARK:-API Handler
    func getAllCoinsSticker(){

        //AppUtility?.startLoader(view: self.view)
     
        ApiHandler.sharedInstance.showGifts{ (isSuccess, response) in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                print(response)
                let dic = response as! NSDictionary
                let code = dic["code"] as! NSNumber
                if(code == 200){
                    let res =  dic.value(forKey: "msg") as! [[String:Any]]
                    self.getAllCoinStricker = res
                    for var i in 0..<self.getAllCoinStricker.count{
                        var obj = self.getAllCoinStricker[i]
                        obj.updateValue("0", forKey: "selected")
                        self.getAllCoinStricker.remove(at: i)
                        self.getAllCoinStricker.insert(obj, at: i)
                    }

                    self.collectionViewAllCoinStickers.reloadData()
            }else{
                AppUtility?.stopLoader(view: self.view)
                print("failed: ",response as Any)
            }
        }
    }

    }
    func send_Coin(sticker_id:String,gift_count:String){
        let userID = UserDefaults.standard.string(forKey: "userID")

        self.myUser = User.readUserFromArchive()
        ApiHandler.sharedInstance.sendGifts(sender_id:userID!, receiver_id: StaticData.obj.liveUserID, gift_id: sticker_id, gift_count:gift_count){ (isSuccess, response) in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                print(response)
                let dic = response as! NSDictionary
                let code = dic["code"] as! NSNumber
                if(code == 200){
                  let count =    Int(UserDefaults.standard.value(forKey: "wallet") as? String ?? "0")! - Int(self.gift_count)! 
                    self.TotalCoin.text! =  String(count)
                    self.Send_Coin_alert(title: "Gift",msg: "successfully coins shared")

            }else{
                AppUtility?.stopLoader(view: self.view)
                print("failed: ",response as Any)
            }
        }

    }
}
    
    //MARK:- Alert Controller
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func Send_Coin_alert(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}
