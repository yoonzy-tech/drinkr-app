//
//  ImageTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/4.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
