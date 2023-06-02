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

        // Do any additional setup after loading the view.
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor(hexString: AppColor.blue2.rawValue)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(hexString: AppColor.light.rawValue)]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(hexString: AppColor.light.rawValue)
        self.tabBar.standardAppearance = tabBarAppearance
        self.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
}
