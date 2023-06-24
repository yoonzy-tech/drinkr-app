//
//  PanelTabsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/13.
//

import UIKit
import FirebaseAuth

enum Tabs: Int {
    case follower = 0
    case following = 1
    case blocklist = 2
}

class PanelTabsViewController: UIViewController {
    
    private struct Segue {
        static let follower = "SegueFollower"
        static let following = "SegueFollowing"
        static let blocklist = "SegueBlocklist"
    }
    
    var searchResults: [User] = []
    var tapGesture: UITapGestureRecognizer?
    var resultsVC: PanelSearchResultsViewController?
    @IBOutlet weak var searchResultContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var indicatorCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet var tabBtns: [UIButton]!
    private var containerViews: [UIView] {
        return [followerContainerView, followingContainerView, blocklistContainerView]
    }
    @IBOutlet weak var followerContainerView: UIView!
    @IBOutlet weak var followingContainerView: UIView!
    @IBOutlet weak var blocklistContainerView: UIView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let panelListVC = segue.destination as? PanelTableViewController else { return }
        let identifier = segue.identifier

        guard let uid = Auth.auth().currentUser?.uid else { return }

        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            if identifier == Segue.follower {
                panelListVC.tab = .follower
                panelListVC.followerDataSource = userData.follower
            } else if identifier == Segue.following {
                panelListVC.tab = .following
                panelListVC.followingDataSource = userData.following
            } else if identifier == Segue.blocklist {
                panelListVC.tab = .blocklist
                panelListVC.blocklistDataSource = userData.block
            }
        }
    }
    
    @IBAction func onChangeTabs(_ sender: UIButton) {
        for btn in tabBtns {
            btn.isSelected = false
        }
        sender.isSelected = true
        moveIndicatorView(reference: sender)
        guard let type = Tabs(rawValue: sender.tag) else { return }
        updateContainer(type: type)
    }
    
    private func moveIndicatorView(reference: UIView) {
        indicatorCenterXConstraint.isActive = false
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: reference.centerXAnchor)
        indicatorCenterXConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    private func updateContainer(type: Tabs) {
        containerViews.forEach { $0.isHidden = true }
        switch type {
        case .follower:
            followerContainerView.isHidden = false
        case .following:
            followingContainerView.isHidden = false
        case .blocklist:
            blocklistContainerView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = "Search user name to follow"
        searchBar.searchBarStyle = .default
        followerContainerView.isHidden = false
        followingContainerView.isHidden = true
        blocklistContainerView.isHidden = true
        searchResultContainerView.isHidden = true
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        resultsVC = storyboard.instantiateViewController(withIdentifier: "PanelSearchResultsViewController")
        as? PanelSearchResultsViewController
        if let resultsVC = resultsVC {
            addChild(resultsVC)
            searchResultContainerView.addSubview(resultsVC.view)
            resultsVC.didMove(toParent: self)
        }
    }
    
    @objc func handleTap() {
        view.endEditing(true)
        searchBar.searchTextField.text = nil
        searchResultContainerView.isHidden = true
    }
}

// MARK: Search Bar Delegate
extension PanelTabsViewController: UISearchBarDelegate, UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("Clear text field")
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultContainerView.isHidden = false
        if searchText == "" {
            searchResultContainerView.isHidden = true
        }
        guard let searchText = searchBar.text,
              !searchText.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        
        FirebaseManager.shared.search(in: .users, value: searchText, key: "name") { (users: [User]) in
            // Search filter out the ones in block list and blockedby list
            guard let uid = Auth.auth().currentUser?.uid else { return }
            FirebaseManager.shared.fetchAccountInfo(uid: uid) { currentUser in
                let blocklist = currentUser.block
                let blockedBy = currentUser.blockedBy
                var filterOutUsers = blocklist + blockedBy
                filterOutUsers.append(uid)
                let searchResults = users.filter { !filterOutUsers.contains($0.uid) }
                self.searchResults = searchResults
                self.resultsVC?.update(with: searchResults)
            }
        }
    }
}
