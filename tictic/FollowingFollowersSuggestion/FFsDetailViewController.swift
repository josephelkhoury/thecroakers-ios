//
//  FFsDetailViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import XLPagerTabStrip

class FFsDetailViewController: UIViewController,IndicatorInfoProvider {

    //MARK:- Outlets
    
    @IBOutlet weak var viewFollowing: UIView!
    @IBOutlet weak var viewFollowers: UIView!
    @IBOutlet weak var viewSuggestion: UIView!
    var itemInfo:IndicatorInfo = "View"
    var selectedIndex =  1
    var userData = [userMVC]()
    
    //MARK:- API Handler
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK:-ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        if itemInfo.title == "Following" {
            viewFollowing.isHidden = false
            viewFollowers.isHidden = true
            viewSuggestion.isHidden =  true
        } else if itemInfo.title == "Followers" {
            viewFollowing.isHidden = true
            viewFollowers.isHidden = false
            viewSuggestion.isHidden =  true
        } else if itemInfo.title == "Suggestions" {
            viewFollowing.isHidden = true
            viewFollowers.isHidden = true
            viewSuggestion.isHidden =  false
        }
    }
   
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NewFollowingViewController,
            segue.identifier == "FollowingVCSegue" {
            vc.userData = userData
        }

        if let vc = segue.destination as? NewFollowersViewController,
            segue.identifier == "FollowersVCSegue" {
            vc.userData = userData
        }

        if let vc = segue.destination as? NewSuggestionViewController,
            segue.identifier == "SuggestionsVCSegue" {
            vc.userData = userData
        }
    }
}
