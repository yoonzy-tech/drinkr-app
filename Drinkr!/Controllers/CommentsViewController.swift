//
//  CommentsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseFirestoreSwift

class CommentsViewController: UIViewController {
    
    var postDataSource: Post?
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var shouldActivateTextField: Bool = false
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func postComment(_ sender: Any) {
        if let text = textField.text {
            let comment = Comment(
                userUid: testUserInfo["uid"] ?? "Unknown Uid",
                text: text
            )
            postDataSource?.comments.append(comment)
            FirestoreManager.shared.update(
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
        textField.borderStyle = .none
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
        userProfileImageView.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                cell.updateCell(
                    username: "c.eight_rrrrr",
                    profileImageUrlString: "",
                    caption: postDataSource.caption ?? "")
            }
            return cell
            
        } else {
            // Comment Cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            if let postDataSource = postDataSource {
                cell.updateCell(
                    username: "richman",
                    profileImageUrlString: "",
                    comment: postDataSource.comments[indexPath.row - 1].text
                )
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
            FirestoreManager.shared.update(
                in: .posts,
                docId: postDataSource?.id ?? "Unknown Doc Id",
                data: postDataSource
            )
            // Update local dataSource
            FirestoreManager.shared.fetchByDocId(in: .posts, docId: postDataSource?.id ?? "Unknown Doc Id") { (data: Post) in
                self.postDataSource = data
                tableView.reloadData()
            }
            
        }
    }
}



