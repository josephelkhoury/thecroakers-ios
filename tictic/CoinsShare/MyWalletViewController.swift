//
//  MyWalletViewController.swift
//  Vibez
//
//  Created by Mac on 27/10/2020.
//  Copyright © 2020 Dinosoftlabs. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import StoreKit
import SwiftyStoreKit

enum Product:String,CaseIterable{
    
    case buy100Coins   = "com.bundleIdentifier.tiktik.buy100Coins"
    case buy500Coins   = "com.bundleIdentifier.tiktik.buy500Coins"
    case buy2000Coins  = "com.bundleIdentifier.tiktik.buy2000Coins"
    case buy5000Coins  = "com.bundleIdentifier.tiktik.buy5000Coins"
    case buy10000Coins = "com.bundleIdentifier.tiktik.buy10000Coins"
}

class MyWalletViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,SKProductsRequestDelegate{
   
    
    //MARK:- Variables
    
  var getAllCoinValue =  [
    ["coin":"100 Coins","Price":"$0.99","Product_id":"com.bundleIdentifier.tiktik.buy100Coins"],
    ["coin":"500 Coins","Price":"$4.99","Product_id":"com.bundleIdentifier.tiktik.buy500Coins"],
    ["coin":"2000 Coins","Price":"$19.99","Product_id":"com.bundleIdentifier.tiktik.buy2000Coins"],
    ["coin":"5000 Coins","Price":"$48.99","Product_id":"com.bundleIdentifier.tiktik.buy5000Coins"],
    ["coin":"10000 Coins","Price":"$99.99","Product_id":"com.bundleIdentifier.tiktik.buy10000Coins"]]
    
    var Coin_Name = ""
    var Coin = ""
    var Price = ""
    var userData = [userMVC]()
    private var models =  [SKProduct]()
    
    
    //MARK:- Outlets
    @IBOutlet weak var tblGetAllCoins: UITableView!
    @IBOutlet weak var lblTotalCoin: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchproduct()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(userData[0].wallet)
        self.lblTotalCoin.text = userData[0].wallet
    }
    
    //MARK:- Button Action
    
    @IBAction func btnCashout(_ sender: Any) {

        let vc = storyboard?.instantiateViewController(withIdentifier: "CashOutVC")as! CashOutViewController
        vc.userData =  self.userData
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func btnBackAction(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.getAllCoinValue.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
     
        let cell =  tableView.dequeueReusableCell(withIdentifier: "CoinShareCell") as! CoinShareTableViewCell
        cell.lblCoin.text = self.getAllCoinValue[indexPath.row]["coin"] as! String
        cell.lblCoinPrice.text = self.getAllCoinValue[indexPath.row]["Price"] as! String
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product_ID = self.getAllCoinValue[indexPath.row]["Product_id"] as! String
        self.Coin_Name = self.getAllCoinValue[indexPath.row]["coin"] as! String
        self.Price = self.getAllCoinValue[indexPath.row]["Price"] as! String
        let objCoin = Coin_Name.components(separatedBy: " ")
        self.Coin = objCoin[0]
        self.purchase(purchase: product_ID)
   
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 60
    
    }
    
    func Add_Coin_My_Wallet(coin:String,name:String,price:String,TID:String){
        
        AppUtility?.startLoader(view: self.view)
     
        ApiHandler.sharedInstance.purchaseCoin(uid: userData[0].userID, coin: coin, title: name, price: price, transaction_id: TID){ (isSuccess, response)  in
            if isSuccess{
                AppUtility?.stopLoader(view: self.view)
                print(response)
                let dic = response as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    let res =  dic.value(forKey: "msg") as! [[String:Any]]
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
    
    //MARK:- In App Purchase get Product
    
    func fetchproduct(){
          
          let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({$0.rawValue})))
          request.delegate =  self
          request.start()
     
      }
    
  
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    
        DispatchQueue.main.async {
            print("SKProductsRequest:\(response.products)")
            self.models =  response.products
            self.tblGetAllCoins.reloadData()
        }
      
    }
/*    func requestProductInfo() {
        print("about to fetch product info")
        if SKPaymentQueue.canMakePayments() {
            var productID:NSSet = NSSet(objects: "ProductID")
            
                let productIdentifiers: NSSet = NSSet(array: productID)
                let productRequest : SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)

                //we set our class as its delegate (so we can handle the response)& trigger the request.
                productRequest.delegate = self
                productRequest.start()
                print("Fetching Products");
            }
            else {
                print("can't make purchases")
            }
        }*/
    
    
 
    //MARK:- Swifty Store Kit
   

    func purchase(purchase : String) {
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        SwiftyStoreKit.purchaseProduct(purchase) { result in
            
            HomeViewController.removeSpinner(spinner: sv)
            
            switch result {
            
            case .success(let productId):
                print("Purchase Success: \(productId)")
                
                print("Purchase detail: \(productId.self)")
                print("productId :\(productId.productId)")
                print("product quantity :\(productId.quantity)")
                print("product transaction :\(productId.transaction)")
                
                print("product originalTransaction :\(productId.originalTransaction)")
                self.Add_Coin_My_Wallet(coin: self.Coin, name: self.Coin_Name, price: self.Price, TID: "\(productId.originalTransaction)")
            case .error(let error):
                print("Purchase Failed: \(error)")
                self.alertModule(title:"Purchase Failed", msg:"Please try again")
            }
        }
        
    }
    
    func alertWithTitle(title : String, message : String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert

    }
    
}
