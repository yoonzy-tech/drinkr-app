//
//  DPosts.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Post: Codable {
    @DocumentID var id: String?
    var userUid: String
    var caption: String?
    
    var imageUrl: String
    var imageRef: String
    
    var createdTime: Timestamp?
    
    var comments: [Comment] = []
    var likes: [String] = []
    
    var taggedFriends: [String] = []
    var location: String = ""
}

struct Comment: Codable {
    var userUid: String
    var text: String
    var createdTime: Timestamp?
}
