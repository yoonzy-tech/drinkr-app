//
//  ScanHistory.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ScanHistory: Codable {
    @DocumentID var id: String?
    var userUid: String
    var brandName: String
    var type: String
    var origin: String
    var vol: String
    var imageUrl: String
    var imageRef: String
    var createdTime: Timestamp?
}
