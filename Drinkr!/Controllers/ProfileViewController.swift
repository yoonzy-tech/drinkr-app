//
//  ProfileViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/6.
//

import UIKit
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController {

    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var userData: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        if let uid = Auth.auth().currentUser?.uid, !uid.isEmpty {
            FirebaseManager.shared.fetchAllByUserUid(in: .users, userUid: uid) { (userData: [User]) in
                print(userData.first)
                self.title = userData.first?.name ?? "Ruby"
                guard let profileImageUrl = userData.first?.profileImageUrl else {
                    print("User has no profile image")
                    return
                }
                self.imageView.kf.setImage(with: URL(string: profileImageUrl))
                
            }
        }
        
    }
    
    @IBAction func signOut(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAccountAction: UIAlertAction = UIAlertAction(
            title: "Delete Account",
            style: .default) { [weak self] _ in
                print("Delete account")
                self?.deleteAccount()
            }
        
        let blockUserAction: UIAlertAction = UIAlertAction(
            title: "Block User",
            style: .destructive) { [weak self] _ in
                print("Block user")
                
            }
        
        let signOutAction: UIAlertAction = UIAlertAction(
            title: "Sign Out",
            style: .destructive) { [weak self] _ in
                print("Sign Out")
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                  print("Error signing out: %@", signOutError)
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginNavController = storyboard.instantiateViewController(identifier: "SignInViewController")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
            }
        
        let cancelAction: UIAlertAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        actionSheetController.addAction(deleteAccountAction)
        actionSheetController.addAction(blockUserAction)
        actionSheetController.addAction(signOutAction)
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.popoverPresentationController?.sourceView = self.view
        self.present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
    func deleteAccount() {
        let user = Auth.auth().currentUser
        user?.delete { error in
          if let error = error {
            // An error happened.
          } else {
              // Account deleted.
              FirebaseManager.shared.delete(
                in: .users,
                docId: "")
          }
        }
    }
}
