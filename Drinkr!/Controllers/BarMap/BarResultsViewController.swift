//
//  ResultsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/20.
//

import UIKit
import CoreLocation

protocol BarResultsViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinates: CLLocationCoordinate2D, name: String)
}

class BarResultsViewController: UIViewController {
        
    weak var delegate: BarResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    private var places: [Place] = []
    
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
    
    public func update(with places: [Place]) {
        self.tableView.isHidden = false
        self.places = places
        tableView.reloadData()
    }
}

extension BarResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        if let placelatitude = places[indexPath.row].geometry?.location.lat,
           let placelongitude = places[indexPath.row].geometry?.location.lng,
           let placeName = places[indexPath.row].name {
            self.delegate?.didTapPlace(with: CLLocationCoordinate2D(latitude: placelatitude,
                                                                    longitude: placelongitude),
                                       name: placeName)
        } else {
            print("fail to get lat and long ")
        }
    }
}
