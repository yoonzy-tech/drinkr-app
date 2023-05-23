//
//  FFSManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

final class FFSManager {

    static let shared = FFSManager()

    let database = Firestore.firestore()
    
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()

    // Create a storage reference from our storage service
    let storageRef = Storage.storage().reference()

    private init() {}
    
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
            self.database.collection("places").addDocument(data: docData) { error in
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
        
        let collection = "places"

        self.database.collection(collection).getDocuments { querySnapshot, error in
            
            /// "latitude, longitude, name, rating, vicinity" : value
            var places: [(docId: String, placeInfo: Any)] = []
            
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    places.append((docId: document.documentID, placeInfo: document.data()))
//                    print("🧤🧤🧤🧤🧤🧤🧤🧤🧤 \(document.data())")
                }
                completion?(places)
            }
        }
    }
    
    public func uploadScanImage(image: UIImage) {
        guard let imageData = image.pngData() else { return }
        
        let imageReferenceId = "1234567\(Date())" // UserId + Date
        let ref = storageRef.child("Scan_Images").child(imageReferenceId)
        
        ref.putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            ref.downloadURL { url, error in
                guard let url = url, error == nil else { return }
                let urlString = url.absoluteString
                // MARK: - TODO # Store URL to Somewhere
                print("Download URL: \(urlString)")
            }
        }
    }
}
