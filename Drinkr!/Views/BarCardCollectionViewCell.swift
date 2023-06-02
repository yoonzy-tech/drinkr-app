//
//  BarCardCollectionViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/29.
//

import UIKit

class BarCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeDistanceLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeRatingOpenHourLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add shadow to the cell
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0.3)
        layer.shadowRadius = 4
    }
}
