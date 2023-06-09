//
//  CocktailSearchResultsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/5.
//

import UIKit

protocol CocktailsResultsViewControllerDelegate: AnyObject {
    func didTapDrink(with drinkDetails: Drink, drinkName: String)
}

class CocktailResultsViewController: UIViewController {

    weak var delegate: CocktailsResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    private var drinks: [Drink] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    public func update(with drinks: [Drink]) {
        self.tableView.isHidden = false
        self.drinks = drinks
        tableView.reloadData()
    }
}

extension CocktailResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = drinks[indexPath.row].strDrink
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        
        let drinkDetails = drinks[indexPath.row]
        if let drinkName = drinks[indexPath.row].strDrink {
            self.delegate?.didTapDrink(with: drinkDetails, drinkName: drinkName)
        } else {
            print("fail to get drink details ")
        }
    }
}
