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
    
    private let appleSignInButton = ASAuthorizationAppleIDButton(type: .signUp, style: .white)
    
    fileprivate var currentNonce: String?
    
    @IBOutlet weak var appleSignInView: UIView!
    
    @IBOutlet weak var googleSignInButton: UIButton!
    
    @IBAction func didTapGoogleSignIn(_ sender: Any) {
        signInGoogle()
    }
    
    var userGoogleToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleSignInButton.layer.cornerRadius = 6
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
extension SignInViewController: ASAuthorizationControllerDelegate,
                                ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let firstName = appleIDCredential.fullName?.givenName,
                  let lastName = appleIDCredential.fullName?.familyName else {
                print("Unable to get user name")
                return
            }
            
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

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            FirebaseManager.shared.firebaseSignIn(credential: credential, username: "\(firstName) \(lastName)") {
                self.presentAppHomeVC()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: Google Sign In
extension SignInViewController {
    func signInGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
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
                
                FirebaseManager.shared.checkUserAccountExist(uid: userUid) { [weak self] exists, error in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if exists {
                        print("User exists in Firestore.")
                    } else {
                        print("User does not exist in Firestore.")
                        let user = User(uid: userUid,
                                        name: name,
                                        email: email,
                                        profileImageUrl: profileImageUrl)
                        FirebaseManager.shared.create(in: .users, data: user)
                    }
                    
                    self?.presentAppHomeVC()
                }
            }
        }
    }
}


extension SignInViewController {
    func presentAppHomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
}
