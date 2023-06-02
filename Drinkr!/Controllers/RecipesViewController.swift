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

class RecipesViewController: UIViewController, ResultsViewControllerDelegate {
    
    var dataSource: [Drink] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    let searchVC = UISearchController(searchResultsController: ResultsViewController())
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        updateDataSource()
        
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        
        searchVC.searchResultsUpdater = self
        navigationItem.searchController?.searchBar.placeholder = "Search cocktail name"
        navigationItem.searchController = searchVC
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc func refreshData() {
        updateDataSource()
        tableView.mj_header?.endRefreshing()
    }
    
    private func updateDataSource() {
        FFSManager.shared.fetchCocktails(completion: { [weak self] documents in
            
            self?.dataSource = documents.compactMap { document in
                guard let drink = Drink(data: document.data()) else {
                    print("Failed to convert document to Drink: \(document)")
                    return nil
                }
                return drink
            }
        })
    }
}

// MARK: Search Controller Delegate
extension RecipesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? ResultsViewController
        else { return }
        resultVC.delegate = self
//        FFSManager.shared.findBars(query: query) { documents in
//            let places = documents.compactMap { $0.data() }
//            DispatchQueue.main.async {
//                resultVC.update(with: places)
//            }
//        }
    }
    
    func didTapPlace(with coordinates: CLLocationCoordinate2D, name: String) {
        print()
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
        
        return cell
    }
}
