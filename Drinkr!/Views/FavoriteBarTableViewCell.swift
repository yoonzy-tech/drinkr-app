//
//  FavoriteBarTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/9.
//

import UIKit

class FavoriteBarTableViewCell: UITableViewCell {

    @IBOutlet weak var barImageView: UIImageView!
    
    @IBOutlet weak var barNameLabel: UILabel!
    
    @IBOutlet weak var barRatingLabel: UILabel!
    
    @IBOutlet weak var barAddressLabel: UILabel!
    
    @IBOutlet weak var barOpenTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
