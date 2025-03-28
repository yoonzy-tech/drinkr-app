//
//  FavoritePlacesViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/30.
//

import UIKit
import MJRefresh
import FirebaseAuth

class FavoriteBarsViewController: UIViewController {
    
    var userDocId: String = ""
    var userData: User?
    
    var favoritePlacesDataSource: [FavPlace] = [] {
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
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error getting Uid")
            return
        }
        
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            self.userData = userData
            self.userDocId = userData.id ?? "Unknown User Doc Id"
            self.favoritePlacesDataSource = userData.favoritePlaces
            self.favoritePlacesDataSource.sort { ($0.addedTime ?? .init())
                .compare($1.addedTime ?? .init()) == .orderedDescending }
            self.tableView.reloadData()
            
        }
    }
}

extension FavoriteBarsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoritePlacesDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteBarTableViewCell", for: indexPath) as? FavoriteBarTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        FirebaseManager.shared.fetchOne(
            in: .googlePlaces,
            field: "place_id",
            value: favoritePlacesDataSource[indexPath.row].placeID) { (places: [Place]) in
                guard let placeDetails = places.first else { return }
                
                if let photoRef = placeDetails.photos?.first?.photoReference,
                   let height = placeDetails.photos?.first?.height,
                   let width = placeDetails.photos?.first?.width {
                    let string = "https://maps.googleapis.com/maps/api/place/photo?photo_reference=\(photoRef)&maxwidth=\(width)&maxheight=\(height)&key=\(GMSPlacesAPIKey)"
                    cell.barImageView.kf.setImage(with: URL(string: string))
                }
                
                cell.barNameLabel.text = placeDetails.name
                
                if let userRatingsTotal = placeDetails.userRatingsTotal {
                    cell.barRatingLabel.text = "\(placeDetails.rating ?? 0) Stars (\(userRatingsTotal)) \(String(repeating: "$", count: placeDetails.priceLevel ?? 0))"
                }
                
                cell.barAddressLabel.text = placeDetails.vicinity
                cell.barOpenTimeLabel.text = placeDetails.openingHours?["opening_hours"] ?? false ?
                "Open now" : "Closed"
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Update Firestore, remove the place id in user info
            userData?.favoritePlaces.removeAll { $0.placeID == favoritePlacesDataSource[indexPath.row].placeID }
            // Delete local dataSource
            favoritePlacesDataSource.remove(at: indexPath.row)
            FirebaseManager.shared.update(
                in: .users,
                docId: userDocId,
                data: userData
            )
        }
    }
}
