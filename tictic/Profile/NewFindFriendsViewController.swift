//
//  NewFindFriendsViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit

class NewFindFriendsViewController: UIViewController {

    @IBOutlet weak var tblFindFriends: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblFindFriends.delegate =  self
        tblFindFriends.dataSource = self
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension NewFindFriendsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsTVC", for: indexPath) as! FindFriendsTVC
        return cell
    }
    
}
