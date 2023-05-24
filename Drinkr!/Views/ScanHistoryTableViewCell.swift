//
//  ScanHistoryTableTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import UIKit
import Kingfisher

class ScanHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var scannedImageView: UIImageView!
    
    public func updateCell(label: String, image: String) {
        self.brandLabel.text = label
        self.scannedImageView.kf.setImage(with: URL(string: image))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
