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
import Lottie

class RecipesViewController: UIViewController {
    
    var dataSource: [Drink] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    @IBOutlet weak var animationView: LottieAnimationView!
    
    let searchVC = UISearchController(searchResultsController: CocktailResultsViewController())
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Cocktails"
        searchVC.searchBar.text = nil
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var startShaking = CFAbsoluteTimeGetCurrent()
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Start Shaking")
            startShaking = CFAbsoluteTimeGetCurrent()
        }
    }
    
    func startAnimation(completion: (() -> Void)? = nil) {
        // Lottie Animation
        animationView.isHidden = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.5
        animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.animationView.stop()
            self.animationView.isHidden = true
            completion?()
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            guard let destinationViewController = storyboard?
                .instantiateViewController(withIdentifier: "DrinkDetailsViewController")
                    as? DrinkDetailsViewController else { return }
            DispatchQueue.main.async {
                CocktailManager.shared.getRandomCocktail { randomDrink in
                    destinationViewController.title = randomDrink.strDrink
                    destinationViewController.drinkDetails = randomDrink
                }
                self.startAnimation {
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        updateDataSource()
        
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        
        searchVC.searchBar.sizeToFit()
        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = true
        searchVC.searchBar.scopeButtonTitles = ["All", "Whiskey", "Vodka", "Gin", "Others"]
        searchVC.searchBar.showsScopeBar = true
        searchVC.searchBar.placeholder = "Search cocktail name"
        searchVC.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.searchController = searchVC
        navigationItem.hidesSearchBarWhenScrolling = false
        
        animationView.isHidden = true
    }
    
    @objc func refreshData() {
        updateDataSource()
        tableView.mj_header?.endRefreshing()
    }
    
    private func updateDataSource() {
        FirebaseManager.shared.fetchAll(in: .cocktailDB) { (drinks: [Drink]) in
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
extension RecipesViewController: UISearchResultsUpdating, UISearchBarDelegate, CocktailsResultsViewControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? CocktailResultsViewController
        else { return }
        resultVC.delegate = self
        
        FirebaseManager.shared.search(in: .cocktailDB, value: query, key: "strDrink") { (drinks: [Drink]) in
            resultVC.update(with: drinks)
        }
    }
    
    func didTapDrink(with drinkDetails: Drink, drinkName: String) {
        searchVC.searchBar.resignFirstResponder()
        // Create an instance of the destination view controller
        guard let destinationViewController = self.storyboard?
            .instantiateViewController(withIdentifier: "DrinkDetailsViewController")
                as? DrinkDetailsViewController else { return }
        destinationViewController.title = drinkName
        destinationViewController.drinkDetails = drinkDetails
        // Push the destination view controller onto the navigation stack
        self.navigationController?.pushViewController(destinationViewController, animated: true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("New scope index is now \(selectedScope)")
        
        guard let scope = searchBar.scopeButtonTitles?[selectedScope] else { return }
        
        
        
        // fetch all the alcohol data
        // Know which scope is selected to filter the data
        // Display on the list
        // Ensure the search bar only search items under that scope data source
    }
}

// MARK: Table View DataSource, Delegate
extension RecipesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RecipeTableViewCell", for: indexPath) as? RecipeTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        if indexPath.row == 0 {
            // Show Surprise Me
            cell.drinkImageView.image = UIImage(named: "surpriseDrink")
            cell.drinkNameLabel.text = "Surprise Me 🤘🏻"
            cell.detailsLabel.text = "Shake your device to see what to get tonight!"
            return cell
        } else {
            let imageUrl = URL(string: dataSource[indexPath.row - 1].strDrinkThumb ?? "")
            
            cell.drinkImageView.kf.setImage(with: imageUrl)
            cell.drinkNameLabel.text = dataSource[indexPath.row - 1].strDrink
            
            cell.detailsLabel.text = dataSource[indexPath.row - 1].getIngredients()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let destinationViewController = storyboard?
         .instantiateViewController(withIdentifier: "DrinkDetailsViewController")
                 as? DrinkDetailsViewController else { return }
        
        if indexPath.row == 0 {
            CocktailManager.shared.getRandomCocktail { randomDrink in
                print(randomDrink)
                destinationViewController.title = randomDrink.strDrink
                destinationViewController.drinkDetails = randomDrink
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
        } else {
            destinationViewController.title = dataSource[indexPath.row].strDrink
            destinationViewController.drinkDetails = dataSource[indexPath.row]
            navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
}
