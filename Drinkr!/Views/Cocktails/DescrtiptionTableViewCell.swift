//
//  DescrtiptionTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/5.
//

import UIKit

class DescrtiptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let attributedText = NSMutableAttributedString(string: descriptionLabel.text ?? "")
        attributedText.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedText.length)
        )
        
        descriptionLabel.attributedText = attributedText
    }
}
