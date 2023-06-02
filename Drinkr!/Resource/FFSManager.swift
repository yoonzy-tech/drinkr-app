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
    
    var userUid: String = "12345678"
    
    // "id, name, email, friends" : value
    var userInfoDocId: String = ""
    
    var userInfo: [String: Any] = testUserInfo
    
    let database = Firestore.firestore()
    
    // Create a storage reference from our storage service
    let storageRef = Storage.storage().reference()
    
    private init() {}
}

// MARK: - User
extension FFSManager {
    
    func checkUserExistsInFirestore(uid: String, completion: @escaping (Bool, Error?) -> Void) {
        self.database.collection("users")
            .whereField("uid", isEqualTo: uid)
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

    func fetchAccountInfo(uid: String, completion: (([String: Any]) -> Void)? = nil) {
        self.database.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { querySnapshot, error in
                
                if let error = error {
                    print("Error getting document: \(error)")
                } else {
                    // Only 1 document is looped here (UID is unique)
                    for document in querySnapshot!.documents {
                        self.userInfoDocId = document.documentID
                        self.userInfo = document.data()
                        print("👉 User Info ~ DocID(key): \(document.documentID), userInfo(value): \(document.data())")
                    }
                    self.userUid = uid
                    completion?(self.userInfo)
                }
            }
    }
    
    func addUserInfo(uid: String, name: String, email: String, profileImageUrl: String) {
        let docData: [String: Any] = [
            "uid": uid as Any,
            "name": name as Any,
            "email": email as Any,
            "profileImageUrl": profileImageUrl as Any
        ]
        print("🧤Adding User Info: \(docData)")
        self.database.collection("users").addDocument(data: docData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
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

// MARK: - Cocktails
extension FFSManager {
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
    
    public func fetchCocktails(completion: @escaping (([QueryDocumentSnapshot]) -> Void)) {
        self.database.collection("latest_cocktails")
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
