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
import AuthenticationServices
import CryptoKit

class SignInViewController: UIViewController {
    
    private let appleSignInButton = ASAuthorizationAppleIDButton()
    
    fileprivate var currentNonce: String?
    
    @IBOutlet weak var appleSignInView: UIView!

    @IBAction func didTapGoogleSignIn(_ sender: Any) {
        signInGoogle()
    }
    
    var userGoogleToken: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(appleSignInButton)
        appleSignInButton.addTarget(self, action: #selector(signInApple), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appleSignInView.addSubview(appleSignInButton)
        appleSignInButton.frame = appleSignInView.bounds
    }
    
    @objc func signInApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

// MARK: Apple Sign In
extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
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
            
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                // User is signed in to Firebase with Apple.
                let firstName = appleIDCredential.fullName?.givenName
                let lastName = appleIDCredential.fullName?.familyName
                let email = appleIDCredential.email
                let uid = authResult?.user.uid
                print(firstName as Any, lastName as Any, email as Any)
                
                // Store it in firebase, check if user exist in firebase
            }
        }
    }

      func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
      }
    
    // Tells which window should present apple sign in (iPad has multi window)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: Google Sign In
extension SignInViewController {
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
                
                guard let profileImageUrl = result.user.photoURL?.absoluteString else {
                    print("User has no profile image")
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
                        // TODO: # Request User Sign In
                        FFSManager.shared.addUserInfo(
                            uid: userUid,
                            name: name,
                            email: email,
                            profileImageUrl: profileImageUrl
                        )
                    }
                }
                // If has this UID in DB, then fetch data
                // If no, then save this user data
            }
        }
    }
}
