//
//  ScanHistoryTableTableViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class ScanHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var scannedImageView: UIImageView!
    
    public func updateCell(label: String, image: String, time: Timestamp) {
        self.brandLabel.text = label
        self.scannedImageView.kf.setImage(with: URL(string: image))
        self.timeLabel.text = convertTimestampToString(time: time)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scannedImageView.layer.cornerRadius = 8
    }
    
    private func convertTimestampToString(time: Timestamp) -> String {
        // Convert Firestore Timestamp to Date
        let date = time.dateValue()

        // Create a DateFormatter instance
        let dateFormatter = DateFormatter()

        // Set the desired date and time format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Convert the Date to a string representation
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}
