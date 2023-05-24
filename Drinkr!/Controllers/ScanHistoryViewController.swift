//
//  ScanHistoryViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import UIKit
import MJRefresh

class ScanHistoryViewController: UIViewController {
    
    var dataSource: [ScanHistory] = [] {
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
        FFSManager.shared.readScanHistory { [weak self] documents in
            
            self?.dataSource = documents.compactMap { document in
                guard let scanHistory = ScanHistory(data: document.data()) else {
                    print("Failed to convert document to Scan History: \(document)") // print any documents that can't be converted
                    return nil
                }
                return scanHistory
            }
            
            // Sort the array by time here (latest on top)
            self?.dataSource = self?.dataSource.sorted { $0.time > $1.time } ?? []
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
            image: dataSource[indexPath.row].imageUrl
        )
        
        return cell
    }
}
