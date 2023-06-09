//
//  FavoritePlacesViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/30.
//

import UIKit
import MJRefresh

class FavoriteBarsViewController: UIViewController {

    var dataSource: [Place] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        updateUserFavoriteBarsData()
    }
    
    @objc func refreshData() {
        updateUserFavoriteBarsData()
        tableView.mj_header?.endRefreshing()
    }
    
    func updateUserFavoriteBarsData() {
        guard let uid = FirebaseManager.shared.userUid else {
            print("Error getting Uid")
            return
        }
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            let placeIDs = userData.placeFavorite
            var newArr: [Place] = []
            for placeID in placeIDs {
                print(placeID)
                FirebaseManager.shared.fetchOne(
                    in: .places,
                    field: "placeId",
                    value: placeID) { (places: [Place]) in
                        guard let placeDetails = places.first else { return }
                        newArr.append(placeDetails)
                        self.dataSource = newArr
                    }
            }
        }
    }
}

extension FavoriteBarsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteBarTableViewCell", for: indexPath) as? FavoriteBarTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        cell.barNameLabel.text = dataSource[indexPath.row].name
        
        if let userRatingsTotal = dataSource[indexPath.row].userRatingsTotal {
            cell.barRatingLabel.text = "\(dataSource[indexPath.row].rating ?? 0) (\(userRatingsTotal))"
        }
        
        cell.barAddressLabel.text = dataSource[indexPath.row].vicinity
//        cell.barOpenTimeLabel.text =
        // price level
        // open hours
        return cell
    }
}
