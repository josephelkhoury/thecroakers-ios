//
//  UpgradeViewController.swift
//  TheCroakers
//
//  Created by Joseph El Khoury on 1/3/22.
//  Copyright © 2022 Joseph El Khoury. All rights reserved.
//

import UIKit

class UpgradeViewController: UIViewController {
    
    @IBOutlet weak var croakerView: UIView!
    @IBOutlet weak var publisherView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewTapGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeBackgroundAni()
        NotificationCenter.default.post(name: Notification.Name("loginModalAppeared"), object: nil, userInfo: nil)
    }

    func changeBackgroundAni() {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)

        }, completion:nil)
    }
    
    // MARK:- view tap gesture
    func viewTapGesture() {
        let tapCroakerView = UITapGestureRecognizer(target: self, action: #selector(self.croakerTouchTapped(_:)))
        self.croakerView.addGestureRecognizer(tapCroakerView)
        
        let tapPublisherView = UITapGestureRecognizer(target: self, action: #selector(self.publisherTouchTapped(_:)))
        self.publisherView.addGestureRecognizer(tapPublisherView)
    }
    
    @objc func croakerTouchTapped(_ sender: UITapGestureRecognizer) {
        /*let userID = UserDefaults.standard.string(forKey: "userID")
        let deviceID = UserDefaults.standard.string(forKey: "deviceID")
        ApiHandler.sharedInstance.applyAsCroaker(user_id: userID!, device_id: deviceID!) { (isSuccess, response) in
            if isSuccess {
                //self.showToast(message: "Loading ...", font: .systemFont(ofSize: 12.0))
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                }
            } else {
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
            }
        }*/
        openApplicationWebView()
    }
    
    @objc func publisherTouchTapped(_ sender: UITapGestureRecognizer) {
        /*let userID = UserDefaults.standard.string(forKey: "userID")
        let deviceID = UserDefaults.standard.string(forKey: "deviceID")
        AppUtility?.startLoader(view: view)
        ApiHandler.sharedInstance.applyAsPublisher(user_id: userID!, device_id: deviceID!) { (isSuccess, response) in
            AppUtility?.stopLoader(view: self.view)
            if isSuccess {
                //self.showToast(message: "Loading ...", font: .systemFont(ofSize: 12.0))
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                }
            } else {
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
            }
        }*/
        openApplicationWebView()
    }
    
    func openApplicationWebView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "termsCondVC") as! termsCondViewController
        vc.privacyDoc = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnCross(_ sender: Any) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        dismiss(animated: true, completion: nil)
        print("dismiss vc")
    }
}
