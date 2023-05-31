//
//  FirestoreManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum Collection: String {
    case posts
    case scanHistories
    case places
    case cocktails
    case users
}

class FirestoreManager {
    static let shared = FirestoreManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    
    func create<T: Codable>(in collection: Collection, data: T) {
        do {
            try database.collection(collection.rawValue).addDocument(from: data)
        } catch {
            print(error)
        }
    }
    
    func updatePost() {
        
    }
    
    func fetch<T: Codable>(in collection: Collection, completion: (([T]) -> Void)? = nil) {
        self.database.collection(collection.rawValue).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                var dataArr = [T]()
                
                dataArr = documents.compactMap { (queryDocumentSnapshot) -> T? in
                    return try? queryDocumentSnapshot.data(as: T.self)
                }
                completion?(dataArr)
            }
        }
    }
    
    func deletePost() {
        
    }
}
