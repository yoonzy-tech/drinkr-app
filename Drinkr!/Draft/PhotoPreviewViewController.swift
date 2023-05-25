//
//  PhotoPreviewViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/23.
//

import UIKit

class PhotoPreviewViewController: UIViewController {
    
    var photo: UIImage?
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = photo
        view.addSubview(imageView)
    }
    
    
}

