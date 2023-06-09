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

class FFSManager {
    static let shared = FFSManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    
    let storageRef = Storage.storage().reference()
}

// MARK: - Bar
extension FFSManager {
    func findBars(query: String, completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        self.database.collection("places")
            .whereField("name", isGreaterThan: query)
            .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No matching results in Firestore")
                    return
                }
                
                completion(documents)
            }
    }
    
    public func addBars(placeResponse: [Place]) {
        for place in placeResponse {
            let docData: [String: Any] = [
                "placeId": place.placeID as Any,
                "name": place.name as Any,
                "latitude": place.geometry?.location.lat as Any,
                "longitude": place.geometry?.location.lng as Any,
                "vicinity": place.vicinity as Any,
                "rating": place.rating ?? 0,
                "userRatingsTotal": place.userRatingsTotal as Any,
                "icon": place.icon as Any
            ]
            // print("🧤🧤🧤🧤🧤🧤🧤🧤 \(docData)")
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
    public func fetchBars(completion: (([(docId: String, placeInfo: Any)]) -> Void)? = nil) {
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
    
    // Refine version
    public func fetchAllBars(completion: (([Place]) -> Void)? = nil) {
        self.database.collection("places").getDocuments { querySnapshot, error in
            // "latitude, longitude, name, rating, vicinity" : value
            var places: [Place] = []
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    places.append(Place(from: document.data()))
                }
                completion?(places)
            }
        }
    }
    
    func checkBarExistInFirestore(placeId: String, completion: @escaping (Bool, Error?) -> Void) {
        self.database.collection("places")
            .whereField("placeId", isEqualTo: placeId)
            .limit(to: 1)
            .getDocuments { (snapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }

            guard let snapshot = snapshot else {
                completion(false, nil)
                return
            }
            completion(!snapshot.isEmpty, nil)
        }
    }
}
