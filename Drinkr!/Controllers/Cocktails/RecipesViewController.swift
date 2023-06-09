//
//  RecipesViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/26.
//

import UIKit
import MJRefresh
import Kingfisher
import CoreLocation

class RecipesViewController: UIViewController {
    
    var dataSource: [Drink] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    let searchVC = UISearchController(searchResultsController: CocktailResultsViewController())
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Cocktails"
        searchVC.searchBar.text = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        updateDataSource()
        
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        
        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        navigationItem.searchController?.searchBar.placeholder = "Search cocktail name"
        navigationItem.searchController = searchVC
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc func refreshData() {
        updateDataSource()
        tableView.mj_header?.endRefreshing()
    }
    
    private func updateDataSource() {
        FirebaseManager.shared.fetchAll(in: .cocktails) { (drinks: [Drink]) in
            self.dataSource = drinks
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationItem.title = nil
    }
}

// MARK: Search Controller Delegate
extension RecipesViewController: UISearchResultsUpdating, CocktailsResultsViewControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? CocktailResultsViewController
        else { return }
        resultVC.delegate = self
        
        FirebaseManager.shared.search(in: .cocktails, value: query, key: "strDrink") { (drinks: [Drink]) in
            resultVC.update(with: drinks)
        }
    }
    
    func didTapDrink(with drinkDetails: Drink, drinkName: String) {
        searchVC.searchBar.resignFirstResponder()
        // Create an instance of the destination view controller
        guard let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsViewController") as? DrinkDetailsViewController else { return }
        destinationViewController.title = drinkName
        destinationViewController.drinkDetails = drinkDetails
        // Push the destination view controller onto the navigation stack
        self.navigationController?.pushViewController(destinationViewController, animated: true)
        
    }
}

// MARK: Table View DataSource, Delegate
extension RecipesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RecipeTableViewCell", for: indexPath) as? RecipeTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        let imageUrl = URL(string: dataSource[indexPath.row].strImageSource ?? "")
        
        cell.drinkImageView.kf.setImage(with: imageUrl)
        cell.drinkNameLabel.text = dataSource[indexPath.row].strDrink
        
        if let str1 =  dataSource[indexPath.row].strIngredient1,
           let str2 = dataSource[indexPath.row].strIngredient2,
           let str3 = dataSource[indexPath.row].strIngredient3 {
            cell.detailsLabel.text = "\(str1), \(str2), \(str3)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Create an instance of the destination view controller
       guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsViewController") as? DrinkDetailsViewController else { return }
        destinationViewController.title = dataSource[indexPath.row].strDrink
        destinationViewController.drinkDetails = dataSource[indexPath.row]
        // Push the destination view controller onto the navigation stack
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
}
