//
//  ProfileViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/6.
//

import UIKit
import FirebaseAuth
import Kingfisher
import MJRefresh

class ProfileViewController: UIViewController {
    
    var userData: User? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var postDataSource: [Post] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.mj_header = MJRefreshNormalHeader()
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        retrieveUserData()
    }
    
    @objc func refreshData() {
        retrieveUserData()
        collectionView.mj_header?.endRefreshing()
    }
    
    func retrieveUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FirebaseManager.shared.fetchAllByUserUid(in: .posts, userUid: uid) { (posts: [Post]) in
            self.postDataSource = posts
            self.postDataSource.sort { ($0.createdTime ?? .init())
                .compare($1.createdTime ?? .init()) == .orderedDescending }
        }
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            self.userData = userData
            self.navigationItem.title = self.userData?.name
            self.navigationItem.title = Auth.auth().currentUser?.displayName
        }
    }
}

// MARK: Posts Collection View
extension ProfileViewController: UICollectionViewDataSource,
                                 UICollectionViewDelegate,
                                 UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return postDataSource.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "UserInfoCollectionViewCell", for: indexPath) as? UserInfoCollectionViewCell
            else { fatalError("Unable to generate User Info Collection View Cell") }
            
            cell.prepareCell(postCount: postDataSource.count)
            
            if let urlString = userData?.profileImageUrl, let url = URL(string: urlString) {
                cell.profileImageView.kf.setImage(with: url)
            } else {
                cell.profileImageView.image = UIImage(named: "icons8-edvard-munch")
            }
            
            return cell
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PostImageCollectionViewCell", for: indexPath) as? PostImageCollectionViewCell
            else { fatalError("Unable to generate Post Image Collection View Cell") }
            
            let urlString = postDataSource[indexPath.row].imageUrl
            cell.imageView.kf.setImage(with: URL(string: urlString))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        let screenWidth = screen.size.width
        if indexPath.section == 0 {
            return CGSize(width: screenWidth, height: 280)
        } else {
            return CGSize(width: (screenWidth / 3.0) - 1, height: (screenWidth / 3.0) - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let postsVC = storyboard.instantiateViewController(identifier: "PostsViewController") as PostsViewController
            
            DispatchQueue.main.async {
                postsVC.dataSource = self.postDataSource
                postsVC.postIndex = indexPath.row
                self.navigationController?.pushViewController(postsVC, animated: true)
            }
        }
    }
}

// MARK: More Options Action Sheet
extension ProfileViewController {
    @IBAction func signOut(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet)
        
        let signOutAction: UIAlertAction = UIAlertAction(
            title: "Log Out",
            style: .default) { _ in
                print("Log Out")
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                  print("Error signing out: %@", signOutError)
                }
                FirebaseManager.shared.userUid = nil
                FirebaseManager.shared.userData = nil
                self.changeRootVCToSignIn()
            }
        
        let deleteAccountAction: UIAlertAction = UIAlertAction(
            title: "Delete Account",
            style: .destructive) { [weak self] _ in
                print("Delete account")
                self?.deleteAccount()
            }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(signOutAction)
        actionSheetController.addAction(deleteAccountAction)
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        self.present(actionSheetController, animated: true)
    }
    
    func deleteAccount() {
        let alertController = UIAlertController(
            title: "🚨 Alert",
            message: "Are you sure to delete your account?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            print("OK button clicked")
            // Perform the desired action here
            // Account deleted.
            if let docId = self.userData?.id {
                FirebaseManager.shared.delete(in: .users, docId: docId)
            }
            self.changeRootVCToSignIn()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("Cancel button clicked")
            // Perform an alternate action or simply dismiss the alert
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func changeRootVCToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SignInViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .changeRootViewController(loginNavController)
    }
}
