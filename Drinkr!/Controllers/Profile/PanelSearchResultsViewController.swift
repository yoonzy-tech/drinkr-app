//
//  PanelSearchResultsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/13.
//

import UIKit
import FirebaseAuth

class PanelSearchResultsViewController: UIViewController {

    var currentUser: User?
    
    var dataSource: [User] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .opaqueSeparator
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            self.currentUser = userData
        }
    }
    
    public func update(with users: [User]) {
        self.dataSource = users
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

extension PanelSearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PanelTableViewCell", for: indexPath) as? PanelTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        if dataSource[indexPath.row].profileImageUrl != "" {
            cell.profileImageView.kf.setImage(with: URL(string: dataSource[indexPath.row].profileImageUrl))
        } else {
            cell.profileImageView.image = UIImage(named: "icons8-edvard-munch")
        }
        
        cell.usernameLabel.text = dataSource[indexPath.row].name
        
        cell.statusButton.tag = indexPath.row
        cell.statusButton.setTitle("Followed", for: .disabled)
        cell.statusButton.setTitle("Follow", for: .normal)
        cell.statusButton.addTarget(self, action: #selector(follow), for: .touchUpInside)
        
        let isFollowing = currentUser?.following.contains(where: { $0 == dataSource[indexPath.row].uid })
        
        if let isFollowing = isFollowing, isFollowing {
            cell.statusButton.isHidden = true
        } else {
            cell.statusButton.isEnabled = true
            cell.statusButton.addTarget(self, action: #selector(follow), for: .touchUpInside)
        }
        return cell
    }
}

extension PanelSearchResultsViewController {
    @objc func follow(_ sender: UIButton) {
        sender.isEnabled = false
        guard var currentUserData = currentUser else { return }
        
        
        // B: Add A in Follower
        FirebaseManager.shared.fetchAccountInfo(uid: dataSource[sender.tag].uid) { otherUserData in
            var newOtherUserData = otherUserData
            newOtherUserData.follower.append(currentUserData.uid)
            FirebaseManager.shared.update(in: .users, docId: otherUserData.id ?? "Unknown User Doc Id", data: newOtherUserData)
            
            // A: Add B in Following
            currentUserData.following.append(self.dataSource[sender.tag].uid)
            FirebaseManager.shared.update(in: .users, docId: currentUserData.id ?? "Unknown User Doc Id", data: currentUserData)
        }
    }
}
