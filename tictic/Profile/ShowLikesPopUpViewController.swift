//
//  ShowLikesPopUpViewController.swift
//  MusicTok
//
//  Created by Mac on 29/05/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class ShowLikesPopUpViewController: UIViewController {

    @IBOutlet weak var lblLikesDescription: UILabel!
    var userData = [userMVC]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblLikesDescription.text = "\(userData[0].username) received a total of \n \(userData[0].likesCount) likes across all videos"
    }
    
    @IBAction func okPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
