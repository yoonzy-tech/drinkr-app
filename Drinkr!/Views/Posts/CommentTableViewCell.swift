//
//  CommentTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell (username: String, profileImageUrlString: String, comment: String) {
        self.usernameLabel.text = username
        let imageUrl = URL(string: profileImageUrlString)
        self.userProfileImageView.kf.setImage(with: imageUrl)
        self.commentLabel.text = comment
    }
}
