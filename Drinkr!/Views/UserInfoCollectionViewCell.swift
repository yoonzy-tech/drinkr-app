//
//  UserInfoCollectionViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/7.
//

import UIKit
import FirebaseAuth

class UserInfoCollectionViewCell: UICollectionViewCell {
    
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
        followRequestButton.layer.cornerRadius = followRequestButton.frame.width / 2
        
//        favoriteBarsButton.layer.masksToBounds = false
//        favoriteBarsButton.layer.shadowColor = UIColor.darkGray.cgColor
//        favoriteBarsButton.layer.shadowOpacity = 0.5
//        favoriteBarsButton.layer.shadowOffset = CGSize(width: 1, height: 0.5)
//        favoriteBarsButton.layer.shadowRadius = 3
//
//        favoriteCocktailsButton.layer.masksToBounds = false
//        favoriteCocktailsButton.layer.shadowColor = UIColor.darkGray.cgColor
//        favoriteCocktailsButton.layer.shadowOpacity = 0.5
//        favoriteCocktailsButton.layer.shadowOffset = CGSize(width: 1, height: 0.5)
//        favoriteCocktailsButton.layer.shadowRadius = 4
        
//        followRequestButton.layer.masksToBounds = false
//        followRequestButton.layer.shadowColor = UIColor.darkGray.cgColor
//        followRequestButton.layer.shadowOpacity = 0.3
//        followRequestButton.layer.shadowOffset = CGSize(width: 1, height: 0.5)
//        followRequestButton.layer.shadowRadius = 5
    }
}
