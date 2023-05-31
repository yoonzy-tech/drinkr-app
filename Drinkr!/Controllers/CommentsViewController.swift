//
//  CommentsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import UIKit
import IQKeyboardManagerSwift

class CommentsViewController: UIViewController {
    
    var dataSource: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var captionContent: Post?
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var shouldActivateTextField: Bool = false
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func postComment(_ sender: Any) {
        textField.resignFirstResponder()
        dataSource.append(textField.text ?? "Unknown")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.borderStyle = .none
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
        userProfileImageView.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
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
        dataSource.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CaptionTableViewCell", for: indexPath) as? CaptionTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            // Caption Cell
            cell.updateCell(
                username: "c.eight_rrrrr",
                profileImageUrlString: "",
                caption: captionContent?.caption ?? "")
            
            return cell
        } else {
            // Comment Cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            cell.updateCell(username: "richman",
                            profileImageUrlString: "",
                            comment: dataSource[indexPath.row - 1]
            )
            
            return cell
        }
    }
}
