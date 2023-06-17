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
import AuthenticationServices

class ProfileViewController: UIViewController {
        
    var scrollToIndex = 0
    
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
    
    var currentNonce: String?
    
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
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            self.userData = userData
            FirebaseManager.shared.fetchAllByUserUid(in: .posts, userUid: uid) { (posts: [Post]) in
                self.postDataSource = posts
                self.postDataSource.sort { ($0.createdTime ?? .init())
                    .compare($1.createdTime ?? .init()) == .orderedDescending }
            }
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
        section == 0 ? 1 : postDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "UserInfoCollectionViewCell", for: indexPath) as? UserInfoCollectionViewCell
            else { fatalError("Unable to generate User Info Collection View Cell") }
           
            cell.prepareCell(postCount: postDataSource.count,
                             follower: userData?.follower.count ?? 15,
                             following: userData?.following.count ?? 20)
            
            if let urlString = userData?.profileImageUrl, let url = URL(string: urlString) {
                cell.profileImageView.kf.setImage(with: url)
            } else {
                cell.profileImageView.image = UIImage(named: "icons8-edvard-munch")
            }
//            Auth.auth().currentUser?.displayName
            if let username = userData?.name {
                cell.usernameLabel.text = username
            } else {
                cell.usernameLabel.text = "User Not Found"
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
        return indexPath.section == 0 ?
        CGSize(width: screenWidth, height: 280) :
        CGSize(width: (screenWidth / 3.0) - 1, height: (screenWidth / 3.0) - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            scrollToIndex = indexPath.row
            performSegue(withIdentifier: "openPersonalPosts", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openPersonalPosts",
           let destinationVC = segue.destination as? PostsViewController {
            destinationVC.postIndex = scrollToIndex
            guard let uid = Auth.auth().currentUser?.uid else { return }
            FirebaseManager.shared.fetchAllByUserUid(in: .posts, userUid: uid) { (posts: [Post]) in
                destinationVC.dataSource = posts
                destinationVC.dataSource.sort { ($0.createdTime ?? .init())
                    .compare($1.createdTime ?? .init()) == .orderedDescending }
                destinationVC.collectionView.reloadData()
            }
        }
    }
}

// MARK: More Options Action Sheet
extension ProfileViewController {
    @IBAction func signOut(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet)
        let privacyPolicyAction: UIAlertAction = UIAlertAction(
            title: "Privacy Policy",
            style: .default) { [weak self] _ in
                print("View Privacy Policy")
                
                guard let privacyPolicyVC = self?.storyboard?
                .instantiateViewController(withIdentifier: "PrivacyPolicyViewController")
                        as? PrivacyPolicyViewController else { return }
                self?.navigationController?.pushViewController(privacyPolicyVC, animated: true)
            }
        let deleteAccountAction: UIAlertAction = UIAlertAction(
            title: "Delete Account",
            style: .destructive) { [weak self] _ in
                print("Delete account")
                self?.deleteAccount()
            }
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
                FirebaseManager.shared.userData = nil
                Utils.changeRootVCToSignIn()
            }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(privacyPolicyAction)
        actionSheetController.addAction(deleteAccountAction)
        actionSheetController.addAction(signOutAction)
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        self.present(actionSheetController, animated: true)
    }
    
    func deleteAccount() {
        let alertController = UIAlertController(
            title: "🚨 Alert",
            message: "Do you want to proceed? \nDelete account will require re-authentication. ",
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "Yes, Delete", style: .destructive) { (_) in
            print("Delete button clicked")
            // Account deleted.
            if let providerID = Auth.auth().currentUser?.providerData.first?.providerID, providerID == "apple.com" {
                self.deleteApple()
                print("Delete Apple Account")
            } else {
                self.deleteGoogle()
                print("Delete Google Account")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteApple() {
        let nonce = AuthManager.shared.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = AuthManager.shared.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func deleteGoogle() {
        FirebaseManager.shared.signInGoogle(self) { credential in
            FirebaseManager.shared.reauthenticateFirebase(credential: credential)
        }
    }
}

extension ProfileViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            guard let appleAuthCode = appleIDCredential.authorizationCode else {
                print("Unable to fetch authorization code")
                return
            }
            guard String(data: appleAuthCode, encoding: .utf8) != nil else {
                print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
                return
            }
            FirebaseManager.shared.reauthenticateApple(
                idTokenString: idTokenString,
                nonce: nonce,
                appleIDCredential: appleIDCredential) { credential in
                    FirebaseManager.shared.reauthenticateFirebase(credential: credential)
                }
        }
    }
}

extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
