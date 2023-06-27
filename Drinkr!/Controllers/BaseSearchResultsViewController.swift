//
//  BaseSearchResultsViewController.swift
//  
//
//  Created by Ruby Chew on 2023/6/27.
//
//
//import UIKit
//import CoreLocation
//
//protocol SearchResultsViewControllerDelegate: AnyObject {
//    associatedtype T
//    func didSelectResult<T>(with result: T, name: String)
//}
//
//class SearchResultsViewController: UIViewController {
//    
//    weak var delegate: (any SearchResultsViewControllerDelegate)?
//    
//    private let tableView: UITableView = {
//        let table = UITableView()
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        return table
//    }()
//    
//    private var places: [Place] = []
//    private var drinks: [Drink] = []
//    
//    enum ResultType {
//        case bars
//        case cocktails
//    }
//    
//    private var resultType: ResultType = .bars
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(tableView)
//        view.backgroundColor = .clear
//        tableView.delegate = self
//        tableView.dataSource = self
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
//    }
//    
//    func update(with places: [Place]) {
//        self.resultType = .bars
//        self.places = places
//        tableView.reloadData()
//    }
//    
//    func update(with drinks: [Drink]) {
//        self.resultType = .cocktails
//        self.drinks = drinks
//        tableView.reloadData()
//    }
//}
//
//extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch resultType {
//        case .bars:
//            return places.count
//        case .cocktails:
//            return drinks.count
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        
//        switch resultType {
//        case .bars:
//            cell.textLabel?.text = places[indexPath.row].name
//        case .cocktails:
//            cell.textLabel?.text = drinks[indexPath.row].strDrink
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        switch resultType {
//        case .bars:
//            if let placelatitude = places[indexPath.row].geometry?.location.lat,
//               let placelongitude = places[indexPath.row].geometry?.location.lng,
//               let placeName = places[indexPath.row].name {
//                delegate?.didSelectResult(with: CLLocationCoordinate2D(latitude: placelatitude,
//                                                                      longitude: placelongitude),
//                                         name: placeName)
//            } else {
//                print("Failed to get coordinates and name for the selected place.")
//            }
//        case .cocktails:
//            let drinkDetails = drinks[indexPath.row]
//            if let drinkName = drinks[indexPath.row].strDrink {
//                delegate?.didSelectResult(with: drinkDetails, drinkName: drinkName)
//            } else {
//                print("Failed to get details for the selected drink.")
//            }
//        }
//    }
//}
