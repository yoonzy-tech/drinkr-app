//
//  PanelTableViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/14.
//

import UIKit
import FirebaseAuth
import MJRefresh

class PanelTableViewController: UIViewController {
    
    var currentUserData: User?
    
    var tab: Tabs = .follower
    
    private var tableView: UITableView!
    
    var followerDataSource: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var followingDataSource: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var blocklistDataSource: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.bounds, style: .plain)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.register(UINib(nibName: "PanelTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PanelTableViewCell")
        view.addSubview(tableView)
        
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        fetchUserData()
    }
    
    @objc func refreshData() {
        fetchUserData()
        tableView.mj_header?.endRefreshing()
    }
    
    func fetchUserData() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        FirebaseManager.shared.fetchAccountInfo(uid: currentUserUid) { userData in
            self.currentUserData = userData
            self.followerDataSource = userData.follower
            self.followingDataSource = userData.following
            self.blocklistDataSource = userData.block
        }
    }
}

extension PanelTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tab {
        case .follower:
            return followerDataSource.count
        case .following:
            return followingDataSource.count
        case .blocklist:
            return blocklistDataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PanelTableViewCell", for: indexPath) as? PanelTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        switch tab {
        case .follower:
            FirebaseManager.shared.fetchAccountInfo(uid: followerDataSource[indexPath.row]) { userInfo in
                cell.usernameLabel.text = userInfo.name
                if userInfo.profileImageUrl != "" {
                    cell.profileImageView.kf.setImage(with: URL(string: userInfo.profileImageUrl))
                } else {
                    cell.profileImageView.image = UIImage(named: "icons8-edvard-munch")
                }
                cell.statusButton.setTitle("Remove", for: .normal)
                cell.statusButton.tag = indexPath.row
                cell.statusButton.addTarget(self, action: #selector(self.removeFollower), for: .touchUpInside)
            }
            
        case .following: // User Info refer to the person in the list, not the current user
            FirebaseManager.shared.fetchAccountInfo(uid: followingDataSource[indexPath.row]) { userInfo in
                cell.usernameLabel.text = userInfo.name
                if userInfo.profileImageUrl != "" {
                    cell.profileImageView.kf.setImage(with: URL(string: userInfo.profileImageUrl))
                } else {
                    cell.profileImageView.image = UIImage(named: "icons8-edvard-munch")
                }
                
                cell.statusButton.setTitle("Unfollow", for: .normal)
                cell.statusButton.tag = indexPath.row
                cell.statusButton.addTarget(self, action: #selector(self.unfollow), for: .touchUpInside)
            }
            
        case .blocklist:
            FirebaseManager.shared.fetchAccountInfo(uid: blocklistDataSource[indexPath.row]) { userInfo in
                
                cell.usernameLabel.text = userInfo.name
                
                if userInfo.profileImageUrl != "" {
                    cell.profileImageView.kf.setImage(with: URL(string: userInfo.profileImageUrl))
                } else {
                    cell.profileImageView.image = UIImage(named: "icons8-edvard-munch")
                }
                
                cell.statusButton.setTitle("Unblock", for: .normal)
                cell.statusButton.addTarget(self, action: #selector(self.unblock), for: .touchUpInside)
            }
        }
        return cell
    }
}

extension PanelTableViewController {
    
    @objc func removeFollower(_ sender: UIButton) {
        guard let docId = currentUserData?.id, var currentUserData = currentUserData else {
            print("Current User Doc Id Not Found")
            return
        }
        // B: Remove A in Following
        FirebaseManager.shared.fetchAccountInfo(uid: followerDataSource[sender.tag]) { otherUserData in
            var newOtherUserData = otherUserData
            newOtherUserData.following.removeAll { $0 == currentUserData.uid }
            FirebaseManager.shared.update(in: .users, docId: otherUserData.id ?? "Unknown User Doc Id", data: newOtherUserData)
            
            // A: Remove B in Follower
            currentUserData.follower.removeAll(where: { $0 == self.followerDataSource[sender.tag] })
            self.followerDataSource.remove(at: sender.tag)
            FirebaseManager.shared.update(in: .users, docId: docId, data: currentUserData)
            self.fetchUserData()
        }
    }
    
    @objc func unfollow(_ sender: UIButton) {
        guard let docId = currentUserData?.id, var currentUserData = currentUserData else {
            print("Current User Doc Id Not Found")
            return
        }
        
        // B: Remove A in Follower
        FirebaseManager.shared.fetchAccountInfo(uid: followerDataSource[sender.tag]) { otherUserData in
            var newOtherUserData = otherUserData
            newOtherUserData.follower.removeAll { $0 == currentUserData.uid }
            FirebaseManager.shared.update(in: .users, docId: otherUserData.id ?? "Unknown User Doc Id", data: newOtherUserData)
            
            // A: Remove B in Following
            currentUserData.following.removeAll(where: { $0 == self.followingDataSource[sender.tag] })
            self.followingDataSource.remove(at: sender.tag)
            FirebaseManager.shared.update(in: .users, docId: docId, data: currentUserData)
            self.fetchUserData()
        }
    }
    
    @objc func unblock(_ sender: UIButton) {
        guard let docId = currentUserData?.id, var currentUserData = currentUserData else {
            print("Current User Doc Id Not Found")
            return
        }
        // B: Remove A in BlockedBy list
        FirebaseManager.shared.fetchAccountInfo(uid: blocklistDataSource[sender.tag]) { otherUserData in
            var newOtherUserData = otherUserData
            newOtherUserData.blockedBy.removeAll { $0 == currentUserData.uid }
            FirebaseManager.shared.update(in: .users, docId: otherUserData.id ?? "Unknown User Doc Id", data: newOtherUserData)
            
            // A: Remove B in Blocklist
            currentUserData.block.removeAll(where: { $0 == self.blocklistDataSource[sender.tag] })
            self.blocklistDataSource.remove(at: sender.tag)
            FirebaseManager.shared.update(in: .users, docId: docId, data: currentUserData)
            self.fetchUserData()
        }
        
        
    }
}
