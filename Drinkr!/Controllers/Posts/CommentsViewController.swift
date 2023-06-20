//
//  CommentsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseFirestoreSwift
import FirebaseAuth

class CommentsViewController: UIViewController {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var postCommentButton: UIButton!
    
    var userData: User?
    var postDataSource: Post?
    var shouldActivateTextField: Bool = false
    
    let userUid = Auth.auth().currentUser?.uid
    
    @IBAction func postComment(_ sender: Any) {
        if let text = textField.text,
           let uid = userUid {
            let comment = Comment(userUid: uid, text: text)
            postDataSource?.comments.append(comment)
            FirebaseManager.shared.update(
                in: .posts,
                docId: postDataSource?.id ?? "Unknown Doc ID",
                data: postDataSource)
        }
        textField.text = .none
        tableView.reloadData()
        textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postCommentButton.layer.cornerRadius = postCommentButton.frame.width / 2
        textField.borderStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        guard let userUid = userUid else {
            print("Unable to get uid")
            return
        }
        FirebaseManager.shared.fetchAccountInfo(uid: userUid) { userData in
            self.userData = userData
            self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2
            self.userProfileImageView.clipsToBounds = true
         
            if let imageUrl = URL(string: userData.profileImageUrl) {
                self.userProfileImageView.kf.setImage(with: imageUrl)
            } else {
                self.userProfileImageView.image = UIImage(named: "icons8-edvard-munch")
            }
            
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterForeground),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func didEnterForeground() {
        if shouldActivateTextField {
            IQKeyboardManager.shared.enableAutoToolbar = false
            textField.becomeFirstResponder()
        }
    }
    
    @objc func didEnterBackground() {
        textField.resignFirstResponder()
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldActivateTextField {
            IQKeyboardManager.shared.enableAutoToolbar = false
            textField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (postDataSource?.comments.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            // Caption Cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CaptionTableViewCell", for: indexPath) as? CaptionTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            if let postDataSource = postDataSource {
                FirebaseManager.shared.fetchAccountInfo(uid: postDataSource.userUid) { authorData in
                    cell.updateCell(
                        username: authorData.name, // change to author info
                        profileImageUrlString: authorData.profileImageUrl,
                        caption: postDataSource.caption ?? "I'm drinking!")
                }
            }
            return cell
            
        } else {
            // Comment Cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            if let postDataSource = postDataSource {
                // To know which person post comments here
                let commenterUid = postDataSource.comments[indexPath.row - 1].userUid
                // Fetch that person's image and name
                FirebaseManager.shared.fetchAccountInfo(uid: commenterUid) { commentData in
                    cell.updateCell(
                        username: commentData.name, // change to author info
                        profileImageUrlString: commentData.profileImageUrl,
                        comment: postDataSource.comments[indexPath.row - 1].text) // Show comment content
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .none
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete local dataSource
            postDataSource?.comments.remove(at: indexPath.row - 1)
            // Update Firestore
            FirebaseManager.shared.update(
                in: .posts,
                docId: postDataSource?.id ?? "Unknown Doc Id",
                data: postDataSource
            )
            // Update local dataSource
            FirebaseManager.shared.fetchByDocId(in: .posts,
                                                docId: postDataSource?.id ?? "Unknown Doc Id") { (data: Post) in
                self.postDataSource = data
                tableView.reloadData()
            }
            
        }
    }
}
