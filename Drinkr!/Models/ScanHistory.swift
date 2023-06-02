//
//  ScanHistory.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DScanHistory: Codable {
    @DocumentID var id: String?
    var userUid: String
    var brandName: String
    var imageUrl: String
    var imageRef: String
    var createdTime: Timestamp?
}


struct ScanHistory {
    var userId: String
    var brandName: String
    var imageUrl: String
    var imageRefNo: String
    var time: Double
    
    // If you need to initialize with a dictionary
    init?(data: [String: Any]) {
        guard let userId = data["userId"] as? String,
              let brandName = data["brandName"] as? String,
              let imageUrl = data["imageUrl"] as? String,
              let imageRefNo = data["imageRefNo"] as? String,
              let time = data["time"] as? Double else {
            return nil
        }
        
        self.userId = userId
        self.brandName = brandName
        self.imageUrl = imageUrl
        self.imageRefNo = imageRefNo
        self.time = time
    }
}
