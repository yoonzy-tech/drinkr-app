//
//  RecipesViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/26.
//

import UIKit
import MJRefresh
import Kingfisher

class RecipesViewController: UIViewController {
    
    var dataSource: [Drink] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        updateDataSource()
        
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
    }
    
    @objc func refreshData() {
        updateDataSource()
        tableView.mj_header?.endRefreshing()
    }
    
    private func updateDataSource() {
        FFSManager.shared.readCocktails(completion: { [weak self] documents in
            
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
