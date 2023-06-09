//
//  FavoriteBarsTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/9.
//

import UIKit

class FavoriteCocktailTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cocktailImageView: UIImageView!
    
    @IBOutlet weak var cocktailNameLabel: UILabel!
    
    @IBOutlet weak var cocktailGlassLabel: UILabel!
    
    @IBOutlet weak var cocktailIngredientsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cocktailImageView.layer.cornerRadius = 5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
