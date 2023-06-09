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
        FirebaseManager.shared.signInGoogle(self) { credential in
            guard let credential = credential else { return }
            FirebaseManager.shared.signInFirebase(
                credential: credential, name: "") { _ in
                self.presentAppHomeVC()
            }
        }
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
            
            FirebaseManager.shared.signInApple(
                nonce: currentNonce,
                appleIDCredential: appleIDCredential) { credential, username in
                    guard let credential = credential else { return }
                    FirebaseManager.shared.signInFirebase(credential: credential, name: username) { _ in
                        self.presentAppHomeVC()
                    }
                }
            
        } else {
            print("Error in Apple Login")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension SignInViewController {
    func presentAppHomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .changeRootViewController(mainTabBarController)
    }
}
