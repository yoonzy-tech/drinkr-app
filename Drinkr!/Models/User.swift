//
//  User.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/6.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable {
    @DocumentID var id: String?
    var uid: String
    var name: String = ""
    var email: String = ""
    var profileImageUrl: String = ""
    var createdTime: Timestamp?
    var isActive: Bool = true
    
    var favoriteCocktails: [FavDrink] = []
    var favoritePlaces: [FavPlace] =  []
    var posts: [String] = []
    
    var follower: [String] = []
    var following: [String] = []
    var block: [String] = []
    var blockedBy: [String] = []
}
