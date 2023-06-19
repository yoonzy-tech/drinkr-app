//
//  TabBarViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/1.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor(hexString: "#FFFFFF")
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.lightGray]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        self.tabBar.standardAppearance = tabBarAppearance
        self.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
}
