//
//  AppDelegate.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/19.
//

import UIKit
import GooglePlaces
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import IQKeyboardManagerSwift

@main

// swiftlint:disable line_length
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSPlacesClient.provideAPIKey(GMSPlacesAPIKey)
        
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
        customNavigationBarStyle()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: Open Google Map App from URL
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    func customNavigationBarStyle() {
        let newNavBarAppearance = UINavigationBarAppearance()
        newNavBarAppearance.backgroundColor = UIColor(hexString: AppColor.blue.rawValue)
        newNavBarAppearance.shadowColor = .clear
        newNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        newNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        newNavBarAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(hexString: AppColor.lightGreen.rawValue)]

        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(hexString: AppColor.lightGreen.rawValue)]
        barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.lightText]
        barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.label]
        barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white]
        newNavBarAppearance.buttonAppearance = barButtonItemAppearance
        newNavBarAppearance.backButtonAppearance = barButtonItemAppearance
        newNavBarAppearance.doneButtonAppearance = barButtonItemAppearance
        
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = UIColor(hexString: AppColor.lightGreen.rawValue)
//        appearance.tintColor = UIColor.
        appearance.scrollEdgeAppearance = newNavBarAppearance
        appearance.compactAppearance = newNavBarAppearance
        appearance.standardAppearance = newNavBarAppearance
    }
}
// swiftlint:enable line_length
