//
//  ScanHistoryViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import UIKit
import MJRefresh
import FirebaseFirestore
import FirebaseAuth

class ScanHistoryViewController: UIViewController {
    
    var dataSource: [ScanHistory] = [] {
        didSet {
            self.dataSource = self.dataSource.sorted { ($0.createdTime ?? .init())
                .compare($1.createdTime ?? .init()) == .orderedDescending }
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        updateDataSource()
        
        // Add listener that the current user is following
        
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
    }
    
    @objc func refreshData() {
        updateDataSource()
        tableView.mj_header?.endRefreshing()
    }
    
    private func updateDataSource() {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseManager.shared.fetchAllByUserUid(
            in: .scanHistories,
            userUid: userUid) { (scanHistories: [ScanHistory]) in
            self.dataSource = scanHistories
        }
    }
}

extension ScanHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ScanHistoryTableViewCell", for: indexPath) as? ScanHistoryTableViewCell
        else { fatalError("Unable to generate Scan History Table View Cell") }
        
        cell.updateCell(
            label: dataSource[indexPath.row].brandName,
            image: dataSource[indexPath.row].imageUrl,
            time: dataSource[indexPath.row].createdTime ?? Timestamp()
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        if editingStyle == .delete {
            // Update Firestore
            FirebaseManager.shared.delete(in: .scanHistories, docId: dataSource[indexPath.row].id ?? "Unknown Doc Id")
            // Update Loacal Data Sourvce
            FirebaseManager.shared.fetchAllByUserUid(
                in: .scanHistories,
                userUid: userUid
            ) { (scanHistories: [ScanHistory]) in
                self.dataSource = scanHistories
            }
        }
    }
}
