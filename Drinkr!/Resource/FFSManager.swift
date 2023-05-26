//
//  FFSManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

final class FFSManager {
    
    static let shared = FFSManager()
    
    let userId: String = "12345678"
    
    let database = Firestore.firestore()
    
    // Create a storage reference from our storage service
    let storageRef = Storage.storage().reference()
    
    private init() {}
    
    // MARK: - Bar Data Manipulation
    public func addBarData(placeResponse: [Place]) {
        for place in placeResponse {
            let docData: [String: Any] = [
                "name": place.name as Any,
                "latitude": place.geometry?.location.lat as Any,
                "longitude": place.geometry?.location.lng as Any,
                "vicinity": place.vicinity as Any,
                "rating": place.rating ?? 0
            ]
            //            print("🧤🧤🧤🧤🧤🧤🧤🧤 \(docData)")
            self.database.collection("Places").addDocument(data: docData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    // Read Data for knowing where to pin on map (for now fetch all data in DB)
    public func readBarData(completion: (([(docId: String, placeInfo: Any)]) -> Void)? = nil) {
        self.database.collection("places").getDocuments { querySnapshot, error in
            // "latitude, longitude, name, rating, vicinity" : value
            var places: [(docId: String, placeInfo: Any)] = []
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    places.append((docId: document.documentID, placeInfo: document.data()))
                }
                completion?(places)
            }
        }
    }
    
    // MARK: - Scan History
    public func uploadScanImage(image: UIImage, brand: String) {
        var imageData: Data?
        
        let compressionQuality: CGFloat = 0.5
        
        if image.imageOrientation != .up {
            // Rotate the image to the default orientation
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            // Use the normalized image for storage
            if let jpegData = normalizedImage?.jpegData(compressionQuality: compressionQuality) {
                // Store the PNG data in the database
                imageData = jpegData
            }
        } else {
            // The image is already in the default orientation, so directly store it
            if let jpegData = image.jpegData(compressionQuality: compressionQuality) {
                // Store the PNG data in the database
                imageData = jpegData
            }
        }
        
        guard let imageData = imageData else { return }
        
        let imageReferenceId = "\(self.userId)\(Date().formatNowDate)" // UserId + Date
        
        let ref = storageRef.child("Scan_Images").child(imageReferenceId)
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload: \(error.localizedDescription)")
                return
            }
            
            // Get image download URL
            ref.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    
                } else if let url = url {
                    let urlString = url.absoluteString
                    print("Download URL: \(urlString)")
                    
                    // Store the record in Scan History
                    let data: [String: Any] = [
                        "userId": self.userId,
                        "brandName": brand,
                        "imageUrl": urlString,
                        "imageRefNo": imageReferenceId,
                        "time": NSDate().timeIntervalSince1970
                    ]
                    
                    // Store the scan history
                    if let scanHistory = ScanHistory(data: data) {
                        self.addScanHistory(history: scanHistory)
                    } else {
                        print("Failed to add Scan History to DB")
                    }
                }
            }
        }
    }
    
    public func addScanHistory(history: ScanHistory) {
        let docData: [String: Any] = [
            "userId": history.userId as Any,
            "brandName": history.brandName as Any,
            "imageUrl": history.imageUrl as Any,
            "imageRefNo": history.imageRefNo as Any,
            "time": history.time as Any
        ]
        print("🧤🧤🧤🧤🧤🧤🧤🧤 \(docData)")
        self.database.collection("scan_history").addDocument(data: docData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    public func readScanHistory(completion: @escaping (([QueryDocumentSnapshot]) -> Void)) {
        self.database.collection("scan_history")
            .whereField("userId", isEqualTo: self.userId)
            .getDocuments(completion: { querySnapshot, error in
            
            if let error = error {
                print("Error getting scan history: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No scan history available")
                return
            }
            completion(documents)
        })
    }
    
    public func listenScanHistory(completion: (() -> Void)? = nil) {
        self.database.collection("scan_history").addSnapshotListener { snapshot, error in
            
            if let error = error {
                print("Error listen to document change: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot else { return }
            
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    print("Added")
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
    
    // MARK: - Cocktails
    public func addCocktails(drinkList: [Drink]) {
        for drink in drinkList {
            self.database.collection("latest_cocktails").addDocument(data: drink.toDictionary()) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    // MARK: - Post Related Manipulation
    public func uploadPostImage(image: UIImage, completion: ((String, String) -> Void)? = nil) {
        var imageData: Data?
        
        let compressionQuality: CGFloat = 0.5
        
        if image.imageOrientation != .up {
            // Rotate the image to the default orientation
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            // Use the normalized image for storage
            if let jpegData = normalizedImage?.jpegData(compressionQuality: compressionQuality) {
                // Store the PNG data in the database
                imageData = jpegData
            }
        } else {
            // The image is already in the default orientation, so directly store it
            if let jpegData = image.jpegData(compressionQuality: compressionQuality) {
                // Store the PNG data in the database
                imageData = jpegData
            }
        }
        
        guard let imageData = imageData else { return }
        
        let imageReferenceId = "\(self.userId)\(Date().formatNowDate)" // UserId + Date
        
        let ref = storageRef.child("Posts").child(imageReferenceId)
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload: \(error.localizedDescription)")
                return
            }
            
            // Get image download URL
            ref.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    
                } else if let url = url {
                    let urlString = url.absoluteString
                    print("Download URL: \(urlString)")
                    
                    completion?(imageReferenceId, urlString)
                }
            }
        }
    }

    func addPost(post: Post) {
        let collectionRef = self.database.collection("posts")
        let fsGeneratedID = collectionRef.document().documentID
        let docData: [String: Any] = [
            "postId": fsGeneratedID,
            "userId": post.userId as Any,
            "caption": post.caption as Any,
            "taggedFriends": post.taggedFriends as Any,
            "location": post.location as Any,
            "imageUrl": post.imageUrl as Any,
            "imageRefNo": post.imageFileRef as Any,
            "time": NSDate().timeIntervalSince1970 as Any
        ]
        print("🧤🧤🧤🧤🧤🧤🧤🧤 \(docData)")
        collectionRef.addDocument(data: docData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    public func readPosts(completion: @escaping (([QueryDocumentSnapshot]) -> Void)) {
        self.database.collection("posts")
            .whereField("userId", isEqualTo: self.userId)
            .getDocuments(completion: { querySnapshot, error in
            
            if let error = error {
                print("Error getting post data: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No post data available")
                return
            }
            completion(documents)
        })
    }
}
