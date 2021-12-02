//
//  NewSuggestionViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit

class NewSuggestionViewController: UIViewController {
    

    @IBOutlet weak var tblSuggestion: UITableView!
    var userData = [userMVC]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblSuggestion.delegate = self
        tblSuggestion.dataSource = self
    }
}

extension NewSuggestionViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ffsTVC", for: indexPath) as! ffsTVC
        
        return cell
    }
}
