//
//  PostCollectionViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import UIKit
import Kingfisher

class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var viewMoreCommentsButton: UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionUsernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var moreOptionsButton: UIButton!
    
    func updateCell(post: Post) {
        if let urlString = testUserInfo["profileImageUrl"] {
            let url = URL(string: urlString)
            self.userProfileImageView.kf.setImage(with: url)
        } else {
            print("User has no profile image")
            self.userProfileImageView.image = UIImage(systemName: "person.fill")
        }
        
        self.usernameLabel.text = testUserInfo["name"]
        self.captionUsernameLabel.text = testUserInfo["name"]
        
        if post.caption?.count == 0 {
            self.captionLabel.text = "is drinking"
        } else {
            self.captionLabel.text = post.caption
        }
        
        let imageUrl = URL(string: post.imageUrl)
        self.postImageView.kf.setImage(with: imageUrl)
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2
        self.userProfileImageView.clipsToBounds = true
        
        if post.comments.count > 0 {
            self.viewMoreCommentsButton.isHidden = false
            self.viewMoreCommentsButton.setTitle("View all \(post.comments.count) comments", for: .normal)
        } else {
            self.viewMoreCommentsButton.isHidden = true
        }
    }
}
