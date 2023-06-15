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
    
    var requestDeleteAccount = false
    
    fileprivate var userGoogleToken: String = ""
    
    fileprivate var currentNonce: String?
    
    private let appleSignInButton = ASAuthorizationAppleIDButton(type: .continue, style: .white)
    
    @IBOutlet weak var appleSignInView: UIView!
    
    @IBOutlet weak var googleSignInButton: UIButton!
    
    var isSignInPage: Bool = true
    
    @IBAction func didTapGoogleSignIn(_ sender: Any) {
        FirebaseManager.shared.signInGoogle(self) { credential in
            FirebaseManager.shared.signInFirebase(credential: credential, name: "") { _ in
                self.presentAppHomeVC()
            }
        }
    }
    
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
        let nonce = AuthManager.shared.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = AuthManager.shared.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: Apple Sign In
extension SignInViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
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
            guard let appleAuthCode = appleIDCredential.authorizationCode else {
                print("Unable to fetch authorization code")
                return
            }
            
            guard String(data: appleAuthCode, encoding: .utf8) != nil else {
                print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
                return
            }
            FirebaseManager.shared.signInApple(idTokenString: idTokenString, nonce: nonce,
                appleIDCredential: appleIDCredential) { credential, username in
                    guard let credential = credential else { return }
                    FirebaseManager.shared.signInFirebase(credential: credential, name: username) { _ in
                            self.presentAppHomeVC()
                        }
                }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // Handle error.
            print("authorization error")
            guard let error = error as? ASAuthorizationError else { return }
            switch error.code {
            case .canceled:
                // user press "cancel" during the login prompt
                print("Canceled")
            case .unknown:
                // user didn't login their Apple ID on the device
                print("Unknown")
            case .invalidResponse:
                // invalid response received from the login
                print("Invalid Respone")
            case .notHandled:
                // authorization request not handled, maybe internet failure during login
                print("Not handled")
            case .failed:
                // authorization failed
                print("Failed")
            case .notInteractive:
                print("Not Interactive")
            @unknown default:
                print("Default")
            }
        }
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
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
