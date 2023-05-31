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
    
    func updateContent(
        profileImage: UIImage?,
        username: String,
        caption: String?,
        postImageUrlString: String) {
            
        self.userProfileImageView.image = profileImage
            
        self.usernameLabel.text = username
        self.captionUsernameLabel.text = username
            
        self.captionLabel.text = caption
            
        let imageUrl = URL(string: postImageUrlString)
        self.postImageView.kf.setImage(with: imageUrl)
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2
        self.userProfileImageView.clipsToBounds = true
    }
}
