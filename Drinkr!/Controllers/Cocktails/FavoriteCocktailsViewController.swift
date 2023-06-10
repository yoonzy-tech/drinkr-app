//
//  FavoriteCocktailsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/9.
//

import UIKit
import Kingfisher
import MJRefresh

class FavoriteCocktailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var userDocId: String = ""
    var userData: User?
    
    var dataSource: [Drink] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        updateUserFavoriteCocktailData()
    }
    
    @objc func refreshData() {
        updateUserFavoriteCocktailData()
        tableView.mj_header?.endRefreshing()
    }
    
    func updateUserFavoriteCocktailData() {
        guard let uid = FirebaseManager.shared.userUid else {
            print("Error getting Uid")
            return
        }
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            self.userDocId = userData.id ?? "Unknown User Doc Id"
            self.userData = userData
            let cocktailIDs = userData.cocktailsFavorite
            var newArr: [Drink] = []
            for cocktailID in cocktailIDs {
                print(cocktailID)
                FirebaseManager.shared.fetchOne(
                    in: .cocktailDB,
                    field: "idDrink",
                    value: cocktailID) { (drinks: [Drink]) in
                    guard let drinkDetail = drinks.first else { return }
                    newArr.append(drinkDetail)
                    self.dataSource = newArr
                }
            }
        }
    }
}

extension FavoriteCocktailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteCocktailTableViewCell", for: indexPath) as? FavoriteCocktailTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        cell.cocktailImageView.kf.setImage(with: URL(string: dataSource[indexPath.row].strDrinkThumb ?? ""))
        cell.cocktailNameLabel.text = dataSource[indexPath.row].strDrink ?? "Unknown Drink"
        cell.cocktailGlassLabel.text = dataSource[indexPath.row].strGlass ?? "Not specific"
        cell.cocktailIngredientsLabel.text = dataSource[indexPath.row].getIngredients()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsViewController")
                as? DrinkDetailsViewController else { return }
        destinationViewController.drinkDetails = dataSource[indexPath.row]
        present(destinationViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Update Firestore, remove the place id in user info
            userData?.cocktailsFavorite.removeAll { $0 == dataSource[indexPath.row].idDrink }
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
