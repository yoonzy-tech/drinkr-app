//
//  SignInViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/28.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class SignInViewController: UIViewController {
    
    @IBAction func signInGoogle(_ sender: Any) {
        signInGoogle()
    }
    
    var userGoogleToken: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func signInGoogle() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        print("🧤 ➡️ Firebase Client ID: \(clientID)")
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else { return }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
  
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    print("Unable to sign with Google")
                    return
                }
                // Fetch Account Info
                guard let result = result else { return }
                
                let userUid = result.user.uid
                
                guard let name = result.user.displayName else {
                    print("User has no display name")
                    return
                }
                
                guard let email = result.user.email else {
                    print("User has no email")
                    return
                }
                
                FFSManager.shared.checkUserExistsInFirestore(uid: userUid) { exists, error in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if exists {
                        print("User exists in Firestore.")
                        FFSManager.shared.fetchAccountInfo(uid: userUid)
                    } else {
                        print("User does not exist in Firestore.")
                        FFSManager.shared.addUserInfo(
                            uid: userUid,
                            name: name,
                            email: email)
                    }
                }
                // If has this UID in DB, then fetch data
                // If no, then save this user data
            }
        }
    }
}
