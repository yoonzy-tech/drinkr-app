//
//  UserInfoCollectionViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/7.
//

import UIKit
import FirebaseAuth

class UserInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followRequestButton: UIButton!
    @IBOutlet weak var favoriteCocktailsButton: UIButton!
    @IBOutlet weak var favoriteBarsButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    
    func prepareCell(postCount: Int) {
        postCountLabel.text = "\(postCount)"
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        favoriteCocktailsButton.layer.cornerRadius = 8
        favoriteBarsButton.layer.cornerRadius = 8
        followRequestButton.layer.cornerRadius = 8
    }
}
