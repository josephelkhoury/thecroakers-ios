//
//  countryCodeViewController.swift
//  TIK TIK
//
//  Created by Mac on 11/11/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import ContentLoader

class countryCodeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var tblCountry: UITableView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var constarintViewContainerTop: NSLayoutConstraint!
    
    var arrCountry = [[String:Any]]()
    var arrSearch = [[String:Any]]()
    var isSearching = false
    var isCodeShow = true
    var showWorldwide = "0"
    
    var countryDictionary = [String:[countryMVC]]()
    var countrySectionTitles = [String]()
    
    var format = ContentLoaderFormat()
    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //       self.setupView()
        //        self.getCountryCodes()
        self.tblCountry.layoutMargins = UIEdgeInsets.zero
        self.tblCountry.separatorInset = UIEdgeInsets.zero
        
        tblCountry.delegate = self
        tblCountry.dataSource = self
        
        format.color = "#F6F6F6".hexColor
        format.radius = 5
        format.animation = .fade
        view.startLoading(format: format)
        
        getCountries()
        //newGetCountryCodes()
        
        /*
         tfSearch.addTarget(self, action: #selector(CountryPopUpViewController.textFieldDidChange(_:)), for: .editingChanged)
         */
    }
    
    //MARK:- API Handler
    
    // GET Countries
    func getCountries() {
        countryDictionary.removeAll()
        ApiHandler.sharedInstance.showCountries(user_id: "", showWorldwide: showWorldwide) { (isSuccess, response) in
            if isSuccess{
               self.view.hideLoading()
                
                print("response showCountries: ", response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                let countries = response?.value(forKey: "msg") as! NSArray
                    
                    for i in 0..<countries.count {
                        var countryDict  = countries.object(at: i) as! NSDictionary
                        countryDict = countryDict.value(forKey: "Country") as! NSDictionary
                        
                        let id = countryDict.value(forKey: "id") as! String
                        let name = countryDict.value(forKey: "name") as! String
                        let cKey = String(name.prefix(1))
                        let short_name = countryDict.value(forKey: "short_name") as! String
                        let phonecode = countryDict.value(forKey: "phonecode") as! String
                        var emoji = countryDict.value(forKey: "emoji") as? String
                        if emoji == nil {
                            emoji = ""
                        }
                        
                        if id.isEmpty == false {
                            let cmvc = countryMVC(id: id, name: name, short_name: short_name, phonecode: phonecode, emoji: emoji!)
                            if var cValues = self.countryDictionary[cKey] {
                                cValues.append(cmvc)
                                self.countryDictionary[cKey] = cValues
                            } else {
                                if id == "0" {
                                    self.countryDictionary["#"] = [cmvc]
                                }
                                else {
                                    self.countryDictionary[cKey] = [cmvc]
                                }
                            }
                        }
                        
                        self.countrySectionTitles = [String](self.countryDictionary.keys)
                        self.countrySectionTitles = self.countrySectionTitles.sorted(by: { $0 < $1 })
                        self.tblCountry.reloadData()
                    }
                } else {
                    print("showCountries API:", response?.value(forKey: "msg") as Any)
                }
                
            } else {
                self.view.hideLoading()
                print("showCountries API:", response?.value(forKey: "msg") as Any)
            }
        }
    }
    
    /*func newGetCountryCodes(){
        if let path = Bundle.main.path(forResource: "countryCodeWithFlags", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String:String]] {
                    
                    for jsonObj in jsonResult{
                        print("jsonObj: ",jsonObj)
                        
                        let cKey = String((jsonObj["name"]?.prefix(1))!)
                        let code = String(jsonObj["dial_code"]!)
                        print("cKey: ",cKey)

                        if code.isEmpty == false{
                            if var cValues = countryDictionary[cKey]{
                                cValues.append(jsonObj)
                                countryDictionary[cKey] = cValues
                            }else{
                                countryDictionary[cKey] = [jsonObj]
                            }

                        }
                        
                    }
                    
                    countrySectionTitles = [String](countryDictionary.keys)
                    countrySectionTitles = countrySectionTitles.sorted(by: { $0 < $1 })
                    //                    self.arrCountry = jsonResult
                    self.tblCountry.reloadData()
                }
            } catch {
                // handle error
            }
        }
    }*/
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print(self.tfSearch.text!)
        
        if AppUtility!.isEmpty(self.tfSearch.text!){
            self.isSearching = false
            self.arrSearch.removeAll()
        }else{
            self.isSearching = true
            self.arrSearch.removeAll()
            for obj in self.arrCountry{
                let strName = obj["name"] as! String
                if strName.range(of: self.tfSearch.text!, options: .caseInsensitive) != nil{
                    self.arrSearch.append(obj)
                }
            }
        }
        
        self.tblCountry.reloadData()
    }
    //MARK:- Setup View
    func setupView() {
        self.tblCountry.rowHeight = 44
        self.tfSearch.becomeFirstResponder()
        //        self.setContainer()
    }
    
    //MARK:- Utility Methods
    func setContainer(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1334:
                print("iPhone 6/6S/7/8")
                self.constarintViewContainerTop.constant = 43
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                self.constarintViewContainerTop.constant = 100
            case 2436:
                print("iPhone X, Xs")
                self.constarintViewContainerTop.constant = 90
            case 2688:
                print("iPhone Xs Max")
                self.constarintViewContainerTop.constant = 160
            case 1792:
                print("iPhone Xr")
                self.constarintViewContainerTop.constant = 160
            default:
                print("unknown")
            }
        }
    }
    
    /*
     func getCountryCodes(){
     if let path = Bundle.main.path(forResource: "countryCodes", ofType: "json") {
     do {
     let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
     let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
     if let jsonResult = jsonResult as? [[String:Any]] {
     self.arrCountry = jsonResult
     self.tblCountry.reloadData()
     }
     } catch {
     // handle error
     }
     }
     }
     
     */
    //MARK:- Button Action
    @IBAction func btnCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: API Methods
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return countrySectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableView.backgroundColor = .white
        
        return countrySectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        tableView.tintColor = #colorLiteral(red: 0.490213871, green: 0.5138357282, blue: 0.5441090465, alpha: 1)
        
        return countrySectionTitles
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let lbl = UILabel(frame: CGRect(x: 10,y: 2,width: self.view.frame.size.width,height: 30))
        lbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        lbl.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lbl.text = countrySectionTitles[section]
        lbl.font = .boldSystemFont(ofSize: 18)
        view.addSubview(lbl)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if self.isSearching{
        //            return self.arrSearch.count
        //        }else{
        //            return self.arrCountry.count
        //        }
        
        let cKey = countrySectionTitles[section]
        if let cValues = countryDictionary[cKey] {
            return cValues.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCodeTVC", for: indexPath) as! countryCodeTableViewCell
        
        let cKey = countrySectionTitles[indexPath.section]
        if let cValues = countryDictionary[cKey] {
            
            let country = cValues[indexPath.row]
            
            if country.id.isEmpty == false {
                cell.lblCountry?.text = country.name
                cell.codeCountry.text = country.emoji
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if self.isSearching{
            NotificationCenter.default.post(name: Notification.Name("GetCountry"), object: self.arrSearch[indexPath.row])
        }else{
            NotificationCenter.default.post(name: Notification.Name("GetCountry"), object: self.arrCountry[indexPath.row])
        }
        */
        
        let cKey = countrySectionTitles[indexPath.section]
        if let cValues = countryDictionary[cKey] {
            let country = cValues[indexPath.row]

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countryDataNotification"), object: nil, userInfo: ["country": country])

            self.dismiss(animated: true, completion: nil)
        }
    }
    //MARK: Segment Control
    
    //MARK: Alert View
    
    /*
     //MARK: TextField
     @IBAction func searchEditingChangeAction(_ sender: UITextField) {
     print(self.tfSearch.text!)
     
     if AppUtility!.isEmpty(self.tfSearch.text!){
     self.isSearching = false
     self.arrSearch.removeAll()
     }else{
     self.isSearching = true
     self.arrSearch.removeAll()
     for obj in self.arrCountry{
     let strName = obj["name"] as! String
     if strName.range(of: self.tfSearch.text!, options: .caseInsensitive) != nil{
     self.arrSearch.append(obj)
     }
     }
     }
     
     self.tblCountry.reloadData()
     }
     */
    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension String {
    func imageUnicode() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
