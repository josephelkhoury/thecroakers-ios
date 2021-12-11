//
//  dobViewController.swift
//  TIK TIK
//
//  Created by Mac on 12/10/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class dobViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryLabel: UILabel!
    
    var dob = ""
    var country_id = ""
    var phoneNo = ""
    
    var email = ""
    var pass = ""
    
    var socialEmail = ""
    var socialID = ""
    var authToken = ""
    var firstName = ""
    var lastName = ""
    var socialUserName = ""
    var socialSignUpType = ""
    
    let fromVC = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnNext.backgroundColor = #colorLiteral(red: 0.5750417709, green: 0.5841686726, blue: 0.6059108973, alpha: 1)
        btnNext.isUserInteractionEnabled = false
        
        dobSetup()
    }
    
    func dobSetup() {
        dobDatePicker.addTarget(self, action: #selector(dobDateChanged(_:)), for: .valueChanged)
        dobDatePicker.maximumDate = Date()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.countryDataNotification(_:)), name: NSNotification.Name(rawValue: "countryDataNotification"), object: nil)
        
        let countryOpt = UITapGestureRecognizer(target: self, action:  #selector(self.countryOptionsList))
        self.countryView.addGestureRecognizer(countryOpt)
    }
    
    @objc func dobDateChanged(_ sender: UIDatePicker) {
        /*
         let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
         */
        sender.datePickerMode = UIDatePicker.Mode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: sender.date)
        print("selectedDate",selectedDate)
        
        self.dob = selectedDate
        let textCount = self.dob.count
        if textCount > 0 {
            btnNext.backgroundColor = UIColor(named: "theme")
            btnNext.isUserInteractionEnabled = true
        } else {
            btnNext.backgroundColor = #colorLiteral(red: 0.5750417709, green: 0.5841686726, blue: 0.6059108973, alpha: 1)
            btnNext.isUserInteractionEnabled = false
        }
        
        NotificationCenter.default.post(name: Notification.Name("dobNoti"), object: selectedDate)
//        self.UpdatePasswordAPI()
//        dismiss(animated: true, completion: nil)
        
        print("date: ",sender.date)
    }
    
    @objc func countryOptionsList(sender : UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "countryCodeVC") as! countryCodeViewController
        present(vc, animated: true, completion: nil)
    }
    
    @objc func countryDataNotification(_ notification: NSNotification) {
        print("countryDataNotification")
        
        if let country = notification.userInfo?["country"] as? countryMVC {
            print("notification.userInfo: ", country.name )
            let name = country.name
            let flag = country.emoji
            countryLabel.text = "\(name) \(flag)"
            self.country_id = country.id
        }
    }
    
    @IBAction func btnNext(_ sender: Any) {
        if country_id.isEmpty == true {
            showToast(message: "Please select a country", font: .systemFont(ofSize: 12))
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "nameVC") as! nameViewController
            vc.dob = self.dob
            vc.country_id = self.country_id
            vc.phoneNo = self.phoneNo
            vc.email = self.email
            vc.pass = self.pass
            vc.socialEmail = self.socialEmail
            vc.firstName = self.firstName
            vc.lastName = self.lastName
            vc.authToken = self.authToken
            vc.socialUserName = self.socialUserName
            vc.socialID = self.socialID
            vc.socialSignUpType = self.socialSignUpType
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSkip(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "nameVC") as! nameViewController
        vc.dob = self.dob
        vc.country_id = self.country_id
        vc.phoneNo = self.phoneNo
        vc.email = self.email
        vc.pass = self.pass
        
        vc.socialEmail = self.socialEmail
        vc.firstName = self.firstName
        vc.lastName = self.lastName
        vc.authToken = self.authToken
        vc.socialUserName = self.socialUserName
        vc.socialID = self.socialID
        vc.socialSignUpType = self.socialSignUpType
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
