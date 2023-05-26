//
//  RecipeTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/26.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkImageView: UIImageView!
    
    @IBOutlet weak var drinkNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
