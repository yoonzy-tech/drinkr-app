//
//  FavoriteCocktailsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/9.
//

import UIKit
import Kingfisher
import MJRefresh
import FirebaseAuth

class FavoriteCocktailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var userDocId: String = ""
    var userData: User?
    
    var favDrinksDataSource: [FavDrink] = [] {
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
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error getting Uid")
            return
        }
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            self.userDocId = userData.id ?? "Unknown User Doc Id"
            self.userData = userData
            self.favDrinksDataSource = userData.favoriteCocktails
            self.favDrinksDataSource.sort { ($0.addedTime ?? .init())
                .compare($1.addedTime ?? .init()) == .orderedDescending }
        }
    }
}

extension FavoriteCocktailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        dataSource.count
        favDrinksDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteCocktailTableViewCell", for: indexPath) as? FavoriteCocktailTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        let drinkId = favDrinksDataSource[indexPath.row].idDrink
        
        FirebaseManager.shared.fetchOne(
            in: .cocktailDB,
            field: "idDrink",
            value: drinkId) { (drinks: [Drink]) in
                guard let drinkDetail = drinks.first else {
                    print("Unable to get cell details")
                    return
                }
                cell.cocktailImageView.kf.setImage(with: URL(string: drinkDetail.strDrinkThumb ?? ""))
                cell.cocktailNameLabel.text = drinkDetail.strDrink ?? "Unknown Drink"
                cell.cocktailGlassLabel.text = drinkDetail.strGlass ?? "Not specific"
                cell.cocktailIngredientsLabel.text = drinkDetail.getIngredients()
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsViewController")
                as? DrinkDetailsViewController else { return }
        
        FirebaseManager.shared.fetchOne(
            in: .cocktailDB,
            field: "idDrink",
            value: favDrinksDataSource[indexPath.row].idDrink) { (drinkDetails: [Drink]) in
            guard let drinkDetail = drinkDetails.first else { return }
            destinationViewController.drinkDetails = drinkDetail
            self.present(destinationViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Update Firestore, remove the place id in user info
            userData?.favoriteCocktails.removeAll { $0.idDrink == favDrinksDataSource[indexPath.row].idDrink }
            // Delete local dataSource
            favDrinksDataSource.remove(at: indexPath.row)
            FirebaseManager.shared.update(
                in: .users,
                docId: userDocId,
                data: userData
            )
        }
    }
}
