//
//  FirestoreManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import Foundation
import Firebase
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
            try database.collection(collection.rawValue).addDocument(from: data) // ignore the error here
        } catch {
            print(error)
        }
    }
    
    func fetchAll<T: Codable>(in collection: Collection, completion: (([T]) -> Void)? = nil) {
        database.collection(collection.rawValue).getDocuments { querySnapshot, error in // ignore the error here
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
    
    func fetchOne<T: Codable>(in collection: Collection, docId: String, completion: ((T) -> Void)? = nil) {
        database.collection(collection.rawValue).document(docId).getDocument { documentSnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let data = try? documentSnapshot?.data(as: T.self) else {
                    print("No this document found")
                    return
                }
                completion?(data)
            }
        }
    }
    
    func update<T: Codable>(in collection: Collection, docId: String, data: T, completion: (([T]) -> Void)? = nil) {
        do {
            try database.collection(collection.rawValue).document(docId).setData(from: data)
        } catch {
            print(error)
        }
    }
    
    func delete(in collection: Collection, docId: String, completion: (() -> Void)? = nil) {
        database.collection(collection.rawValue).document(docId).delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                print("Document deleted successfully.")
                completion?()
            }
        }
    }
}

// FirestoreManager.shared.fetch(in: .posts) { (posts: [DPost]) in
//    print(posts)
// }
