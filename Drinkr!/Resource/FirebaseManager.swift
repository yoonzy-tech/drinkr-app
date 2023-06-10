//
//  FirestoreManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/31.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseStorage
import GoogleSignIn
import AuthenticationServices

enum Collection: String {
    case posts
    case scanHistories
    case googlePlaces
    case cocktailDB
    case cocktails
    case users
}

enum StoragePath: String {
    case posts = "Posts"
    case scanHistories = "ScanHistories"
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    var userUid: String?
    
    var userData: User?
    
    var currentNonce: String?
    
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
            if let error = error {
                print(error.localizedDescription)
                return
            }
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
extension FirebaseManager {
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
        database.collection(collection.rawValue)
            .whereField("userUid", isEqualTo: userUid)
            .getDocuments { querySnapshot, error in
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
    
    func fetchOne<T: Codable>(in collection: Collection, field: String, value: String, completion: (([T]) -> Void)? = nil) {
        database.collection(collection.rawValue)
            .whereField(field, isEqualTo: value)
            .getDocuments { querySnapshot, error in
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
    
    func search<T: Codable>(in collection: Collection, value: String, key field: String, completion: (([T]) -> Void)? = nil) {
        database.collection(collection.rawValue)
            .whereField(field, isGreaterThan: value)
            .whereField(field, isLessThanOrEqualTo: value + "\u{f8ff}")
            .getDocuments { querySnapshot, error in
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
    
    func checkDuplicates(in collection: Collection, field: String, value: String, completion: ((Bool, Error?)-> Void)? = nil) {
        database.collection(collection.rawValue).whereField(field, isEqualTo: value).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion?(false, error)
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                completion?(false, error)
                return
            }
            
            completion?(!querySnapshot.isEmpty, nil)
        }
    }
}

// MARK: File Storage Upload & Delete
extension FirebaseManager {
    func uploadFile(to path: StoragePath, imageData: Data, completion: ((String, String) -> Void)? = nil) {
        
        let imageRef = "\(userUid ?? "Unknown User Uid")\(Date().formatNowDate)"
        
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

// MARK: User
extension FirebaseManager {
    
    func listenUserInfo(completion: (() -> Void)? = nil) {
        guard let uid = userUid else {
            print("Hasn't get UID")
            return
        }
        database.collection(Collection.users.rawValue).whereField("uid", isEqualTo: uid)
            .addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
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

    func fetchAccountInfo(uid: String, completion: ((User) -> Void)? = nil) {
        self.database.collection(Collection.users.rawValue)
            .whereField("uid", isEqualTo: uid)
            .getDocuments { querySnapshot, error in
                
                if let error = error {
                    print("Error getting document: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No user found")
                    return
                }
                
                var dataArr = [User]()
                
                dataArr = documents.compactMap { (queryDocumentSnapshot) -> User? in
                    return try? queryDocumentSnapshot.data(as: User.self)
                }
                
                self.userData = dataArr.first
                guard let userData = dataArr.first else { return }
                completion?(userData)
            }
    }
    
    func checkUserAccountExist(uid: String, completion: @escaping (Bool, Error?) -> Void) {
        database.collection(Collection.users.rawValue)
            .whereField("uid", isEqualTo: uid).limit(to: 1)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    completion(false, nil)
                    return
                }
                completion(!querySnapshot.isEmpty, nil)
            }
    }
    
    func signInFirebase(credential: AuthCredential, name: String, completion: ((User) -> Void)? = nil) {
        Auth.auth().signIn(with: credential) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = Auth.auth().currentUser else { return }
            let uid = user.uid
            // Check if has this user info in firebase
            self.checkUserAccountExist(uid: uid) { [weak self] exists, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                if exists {
                    print("User exists in Firestore.")
                    self?.fetchAccountInfo(uid: uid) { user in
                        print("⭐️ Logged In: \(user)")
                        completion?(user)
                    }
                    
                } else {
                    print("User does not exist in Firestore.")
                    guard let email = user.email else { return }
                    
                    // Store user info to firebase
                    let user = User(
                        uid: uid,
                        name: user.displayName ?? name,
                        email: email,
                        profileImageUrl: user.photoURL?.absoluteString ?? "",
                        createdTime: Timestamp()
                    )
                    print(user)
                    self?.create(in: .users, data: user)
                    completion?(user)
                }
            }
        }
    }
    
    func signInApple(nonce: String?, appleIDCredential: ASAuthorizationAppleIDCredential, completion: ((AuthCredential?, String) -> Void)? = nil) {
        
        guard let nonce = nonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        var displayName: String = ""
        
        if let firstName = appleIDCredential.fullName?.givenName,
           let lastName = appleIDCredential.fullName?.familyName {
            displayName = "\(firstName) \(lastName)"
            print(displayName)
        }
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        // only the first time will get the name, try change profile name
        completion?(credential, Auth.auth().currentUser?.displayName ?? "Unknown Name from Firebase")
    }
    
    func signInGoogle(_ viewController: UIViewController, completion: ((AuthCredential?) -> Void)? = nil) {
        var credential: AuthCredential?
        if let clientID = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            guard error == nil else { return }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            completion?(credential)
        }
        
    }
}

/*

 FirestoreManager.shared.fetch(in: .posts) { (posts: [DPost]) in
    print(posts)
 }
 
 */
