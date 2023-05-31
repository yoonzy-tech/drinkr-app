//
//  DPosts.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import Foundation
import FirebaseFirestoreSwift

struct DPost: Codable {
    var userId: String
    var caption: String?
    var taggedFriends: [String]?
    var location: String?
    var imageUrl: String
    var imageRefNo: String
    var time: Double
}
