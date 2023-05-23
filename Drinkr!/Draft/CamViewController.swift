//
//  CamViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/23.
//

import UIKit

class CamViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    @IBAction func openCameraButton(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // do something with the image
        }

        imagePicker.dismiss(animated: true, completion: nil)
    }

}
