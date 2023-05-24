//
//  PostsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import UIKit

class PostsViewController: UIViewController {

    @IBAction func openCamera(_ sender: Any) {
        performSegue(withIdentifier: "openCameraSegue", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
