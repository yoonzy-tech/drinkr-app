//
//  ScannerViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/23.
//

import UIKit
import CoreML
import Photos
import PhotosUI

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    let cameraPicker = UIImagePickerController()
    var model: BarHeinModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            model = try BarHeinModel(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load model: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func camera(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        let photoPickerController = PHPickerViewController(configuration: configuration)
        photoPickerController.delegate = self
        present(photoPickerController, animated: true, completion: nil)
    }
    
}

extension ScannerViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {
            // Save the image to Photo Library only if it's from the camera
            if picker.sourceType == .camera {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: pickedImage)
                }, completionHandler: { success, error in
                    if success {
                        FFSManager.shared.uploadScanImage(image: pickedImage)
                        print("Photo saved successfully")
                    } else if let error = error {
                        print("Error saving photo: \(error)")
                    }
                })
            }
            // Get prediction
            guard let pixelBuffer = pickedImage.pixelBuffer(width: 299, height: 299),
                  let prediction = try? model?.prediction(image: pixelBuffer) else { return }
            
            imageView.image = pickedImage
            itemLabel.text = "Predicted object: \(prediction.classLabel)"
        }
        cameraPicker.dismiss(animated: true, completion: nil)
    }
}

extension ScannerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let error = error {
                    print("PHPicker loading error: \(error)")
                }
                if let image = object as? UIImage {
                    FFSManager.shared.uploadScanImage(image: image)
                    // Get prediction
                    guard let pixelBuffer = image.pixelBuffer(width: 299, height: 299),
                          let prediction = try? self.model?.prediction(image: pixelBuffer) else { return }
                    
                    // Use picked image here
                    DispatchQueue.main.async {
                        // MARK: - TODO # Add Awaiting Animation / Popup
                        // Perform UI related operations here
                        self.imageView.image = image
                        self.itemLabel.text = "Predicted object: \(prediction.classLabel)"
                    }
                }
            }
        }
    }
}
