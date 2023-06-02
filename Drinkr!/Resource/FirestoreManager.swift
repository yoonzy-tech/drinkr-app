//
//  FirestoreManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

enum Collection: String {
    case posts
    case scanHistories
    case places
    case cocktails
    case users
}

enum StoragePath: String {
    case posts = "Posts"
    case scanHistories = "ScanHistories"
}

class FirestoreManager {
    static let shared = FirestoreManager()
    
    private init() {}
    
    private let database = Firestore.firestore()
    
    private let storage = Storage.storage().reference()
    
    // MARK: Create, Write
    func create<T: Codable>(in collection: Collection, data: T) {
        do {
            try database.collection(collection.rawValue).addDocument(from: data) // ignore the error here
        } catch {
            print("Error to add document: \(error.localizedDescription)")
        }
    }
    
    // MARK: Update
    func update<T: Codable>(in collection: Collection, docId: String, data: T, completion: (([T]) -> Void)? = nil) {
        do {
            try database.collection(collection.rawValue).document(docId).setData(from: data)
        } catch {
            print(error)
        }
    }
    
    // MARK: Delete
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
    
    func listen(in collection: Collection, completion: (() -> Void)? = nil) {
        database.collection(collection.rawValue).addSnapshotListener { snapshot, error in
            guard let snapshot else {
                print("Failed to get listener snapshot")
                return
            }
            
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    print("Add")
                case .modified:
                    print("Modified")
                case .removed:
                    print("removed")
                }
            }
            if completion != nil {
                completion!()
            }
        }
    }
}

// MARK: Fetch Functions
extension FirestoreManager {
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
    
    func fetchByDocId<T: Codable>(in collection: Collection, docId: String, completion: ((T) -> Void)? = nil) {
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
    
    func fetchAllByUserUid<T: Codable>(in collection: Collection, userUid: String, completion: (([T]) -> Void)? = nil) {
        database.collection(collection.rawValue).whereField("userUid", isEqualTo: userUid).getDocuments { querySnapshot, error in
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
}

// MARK: File Storage Upload & Delete
extension FirestoreManager {
    func uploadFile(to path: StoragePath, imageData: Data, completion: ((String, String) -> Void)? = nil) {
        
        let imageRef = "\(testUserInfo["uid"] ?? "Unknown User Uid")\(Date().formatNowDate)"
        
        let path = self.storage.child(path.rawValue).child(imageRef)
        
        let uploadTask = path.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            } else {
                path.downloadURL { url, error in
                    if let error = error {
                        print("Failed to get download URL: \(error.localizedDescription)")
                        
                    } else {
                        if let url = url {
                            let imageUrl = url.absoluteString
                            print("Download URL: \(imageUrl)")
                            
                            completion?(imageRef, imageUrl)
                        }
                    }
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Update progress UI
            guard let progress = snapshot.progress else {
                print("Fail to get progress")
                return
            }
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            print("Upload progress: \(percentComplete)%")
        }
    }
    
    func deleteFile(to path: StoragePath, imageRef: String) {
        
        let path = self.storage.child(path.rawValue).child(imageRef)
        
        path.delete { error in
            if let error = error {
                // Handle error
                print("Error deleting image: \(error.localizedDescription)")
                return
            }
            
            // Image deleted successfully
            print("Image deleted successfully!")
        }
    }
    
    // MARK: Rotate Image Orientation
    func rotateImageToUp(image: UIImage) -> Data? {
        
        var imageData: Data?
        
        let compressionQuality: CGFloat = 0.5
        
        if image.imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            if let jpegData = normalizedImage?.jpegData(compressionQuality: compressionQuality) {
                imageData = jpegData
            }
            
        } else {
            
            if let jpegData = image.jpegData(compressionQuality: compressionQuality) {
                imageData = jpegData
            }
        }
        return imageData
    }
}

// FirestoreManager.shared.fetch(in: .posts) { (posts: [DPost]) in
//    print(posts)
// }
