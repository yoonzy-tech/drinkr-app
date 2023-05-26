//
//  Post.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import Foundation

struct Post {
    //    var postId: String // Firestore Generated
    var userId: String
    var caption: String?
    var taggedFriends: [String]?
    var location: String?
    var imageUrl: String
    var imageFileRef: String
    var time: Double
    
    // If you need to initialize with a dictionary
    init?(data: [String: Any]) {
        guard let userId = data["userId"] as? String,
              let imageUrl = data["imageUrl"] as? String,
              let imageFileRef = data["imageFileRef"] as? String,
              let time = data["time"] as? Double else {
            return nil
        }
        
        self.userId = userId
        self.caption = data["caption"] as? String
        self.taggedFriends = data["taggedFriends"] as? [String]
        self.location = data["location"] as? String
        self.imageUrl = imageUrl
        self.imageFileRef = imageFileRef
        self.time = time
    }
}
