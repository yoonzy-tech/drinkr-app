//
//  CaptionTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import UIKit

class CaptionTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2
        self.userProfileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell (username: String, profileImageUrlString: String, caption: String) {
        self.usernameLabel.text = username
        let imageUrl = URL(string: profileImageUrlString)
        self.userProfileImageView.kf.setImage(with: imageUrl)
        self.userProfileImageView.image = UIImage(named: "profile")
        self.captionLabel.text = caption
    }
}
