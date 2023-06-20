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
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    let cellInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Add shadow to the cell's contentView
//        contentView.layer.masksToBounds = false
//        contentView.layer.shadowColor = UIColor.darkGray.cgColor
//        contentView.layer.shadowOpacity = 0.3
//        contentView.layer.shadowOffset = CGSize(width: 0, height: 0.8)
//        contentView.layer.shadowRadius = 4
        contentView.layer.cornerRadius = 10
        
        drinkImageView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Apply insets to the cell's content view
        contentView.frame = contentView.frame.inset(by: cellInsets)
    }
}
