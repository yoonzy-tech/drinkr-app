//
//  PostCollectionViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import UIKit
import Kingfisher

class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var likesCountLabel: UILabel!
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
        // Fetch data of this post author
        FirebaseManager.shared.fetchAccountInfo(uid: post.userUid) { userData in
            // update profile image
            if !userData.profileImageUrl.isEmpty {
                let url = URL(string: userData.profileImageUrl)
                self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2
                self.userProfileImageView.clipsToBounds = true
                self.userProfileImageView.kf.setImage(with: url)
                
            } else {
                print("User has no profile image")
                self.userProfileImageView.image = UIImage(named: "icons8-edvard-munch")
            }
            
            self.usernameLabel.text = userData.name
            self.captionUsernameLabel.text = userData.name

            if post.caption == "" || post.caption == nil {
                self.captionLabel.text = "is drinking"
            } else {
                self.captionLabel.text = post.caption
            }
            
            let imageUrl = URL(string: post.imageUrl)
            self.postImageView.kf.setImage(with: imageUrl)
            
            if post.comments.count > 0 {
                self.viewMoreCommentsButton.isHidden = false
                self.viewMoreCommentsButton.setTitle("View all \(post.comments.count) comments", for: .normal)
            } else {
                self.viewMoreCommentsButton.isHidden = true
            }
            
            if post.likes.count > 0 {
                self.likesCountLabel.text = "\(post.likes.count) Likes"
            } else {
                self.likesCountLabel.text = "Be the first to toast ~"
            }
        }
    }
}
