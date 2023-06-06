//
//  FavoritePlacesViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/30.
//

import UIKit

class FavoritePlacesViewController: UIViewController {

    var dataSource: [Place] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.dataSource = self
//        tableView.delegate = self
    }
}

//extension FavoritePlacesViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        dataSource.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: "Cell", for: indexPath) as? Cell
//        else { fatalError("Unable to generate Table View Cell") }
        
//        return cell
//    }
//}

