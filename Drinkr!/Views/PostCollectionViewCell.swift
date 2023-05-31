//
//  PostCollectionViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBAction func openMoreOptions(_ sender: Any) {
        // User Own Post: Edit, Delete
        // Others Post: Report, Share
        
    }
}
