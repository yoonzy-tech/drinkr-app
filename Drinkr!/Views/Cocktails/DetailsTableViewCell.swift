//
//  DetailsTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/4.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var columnTitleLabel: UILabel!
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 15
        
        let attributedText = NSMutableAttributedString(string: detailsLabel.text ?? "")
        attributedText.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedText.length)
        )
        
        detailsLabel.attributedText = attributedText
    }
}
