//
//  FavoritePlacesViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/30.
//

import UIKit
import MJRefresh

class FavoriteBarsViewController: UIViewController {

    var userDocId: String = ""
    var userData: User?
    
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
            self.userData = userData
            self.userDocId = userData.id ?? "Unknown User Doc Id"
            var newArr: [Place] = []
            for placeID in placeIDs {
                print("Place: \(placeID)")
                FirebaseManager.shared.fetchOne(
                    in: .googlePlaces,
                    field: "place_id",
                    value: placeID) { (places: [Place]) in
                        guard let placeDetails = places.first else { return }
                        newArr.append(placeDetails)
                        self.dataSource = newArr
//                        tableView.reloadData()
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
        
        if let photoRef = dataSource[indexPath.row].photos?.first?.photoReference,
            let height = dataSource[indexPath.row].photos?.first?.height,
            let width = dataSource[indexPath.row].photos?.first?.width {
            let string = "https://maps.googleapis.com/maps/api/place/photo?photo_reference=\(photoRef)&maxwidth=\(width)&maxheight=\(height)&key=\(GMSPlacesAPIKey)"
            cell.barImageView.kf.setImage(with: URL(string: string))
        }
        
        cell.barNameLabel.text = dataSource[indexPath.row].name
        
        if let userRatingsTotal = dataSource[indexPath.row].userRatingsTotal,
            let priceLevel = dataSource[indexPath.row].priceLevel {
            cell.barRatingLabel.text = "\(dataSource[indexPath.row].rating ?? 0) Stars (\(userRatingsTotal)) \(String(repeating: "$", count: priceLevel))"
        }
        
        cell.barAddressLabel.text = dataSource[indexPath.row].vicinity
        cell.barOpenTimeLabel.text = dataSource[indexPath.row].openingHours?["opening_hours"] ?? false ? "Open now" : "Closed"
        // price level, open hours
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Update Firestore, remove the place id in user info
            userData?.placeFavorite.removeAll { $0 == dataSource[indexPath.row].placeID }
            // Delete local dataSource
            dataSource.remove(at: indexPath.row)
            FirebaseManager.shared.update(
                in: .users,
                docId: userDocId,
                data: userData
            )
        }
    }
}
