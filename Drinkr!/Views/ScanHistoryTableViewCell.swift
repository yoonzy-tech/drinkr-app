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

    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var scannedImageView: UIImageView!
    
    func updateCell(data: ScanHistory) {
        self.brandLabel.text = data.brandName
        
        let imageUrl = URL(string: data.imageUrl)
        self.scannedImageView.kf.setImage(with: imageUrl)
        
        let createdTime = data.createdTime ?? Timestamp()
        self.timeLabel.text = "Added on: \(convertTimestampToString(time: createdTime))"
        
        self.originLabel.text = "Origin: \(data.origin)"
        self.volumeLabel.text = "\(data.type), \(data.vol) vol"
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
