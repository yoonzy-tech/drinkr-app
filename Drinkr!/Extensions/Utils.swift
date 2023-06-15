//
//  Utils.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/13.
//

import Foundation
import UIKit

class Utils {
    
    private init() {}
    
    static func changeRootVCToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SignInViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .changeRootViewController(loginNavController)
    }
}
