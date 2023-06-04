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
import FirebaseFirestore
import Lottie

class ScannerViewController: UIViewController {
    
    func startAnimation() {
        // Lottie Animation
        animationView.isHidden = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.animationView.stop()
            self.animationView.isHidden = true
        }
    }
    
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    let cameraPicker = UIImagePickerController()
    var model: BarHeinModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 10
        cameraButton.layer.cornerRadius = 5
        photoLibraryButton.layer.cornerRadius = 5
        
        do {
            model = try BarHeinModel(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load model: \(error)")
        }
        
        animationView.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.image = UIImage(named: "beer can")
        itemLabel.text = "Take a photo or choose from library to scan"
    }
    
    @IBAction func openCamera(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) { return }
        
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

// MARK: - User Take Photo
extension ScannerViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage,
           let imageData = FirestoreManager.shared.rotateImageToUp(image: pickedImage) {
            // Save the image to Photo Library
            if picker.sourceType == .camera {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: pickedImage)
                }, completionHandler: { success, error in
                    if success {
                        print("Photo saved successfully")
                    } else if let error = error {
                        print("Error saving photo: \(error)")
                    }
                })
            }
            // Get Model Prediction
            guard let pixelBuffer = pickedImage.pixelBuffer(width: 299, height: 299),
                  let prediction = try? model?.prediction(image: pixelBuffer) else { return }
            
            self.uploadCreateScanHistory(imageData: imageData, brandName: prediction.classLabel)
            
            self.startAnimation()
            
            cameraPicker.dismiss(animated: true)
                
            // Show Scanned Item & Info on UI
            imageView.image = pickedImage
            itemLabel.text = "\(prediction.classLabel)"
        }
        
    }
}

// MARK: - User Select Photo from PHPicker
extension ScannerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            DispatchQueue.main.async {
                self.startAnimation()
            }
            
            itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let error = error {
                    print("PHPicker loading error: \(error)")
                }
                if let image = object as? UIImage,
                   let imageData = FirestoreManager.shared.rotateImageToUp(image: image) {
                    
                    // Get Model Prediction
                    guard let pixelBuffer = image.pixelBuffer(width: 299, height: 299),
                          let prediction = try? self.model?.prediction(image: pixelBuffer) else { return }
                    
                    self.uploadCreateScanHistory(imageData: imageData, brandName: prediction.classLabel)

                    // Put Picked Image on ImageView
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        self.itemLabel.text = "\(prediction.classLabel)"
                    }
                }
            }
        }
    }
    
    func uploadCreateScanHistory(imageData: Data, brandName: String) {
        // Store Scan History to DB
        FirestoreManager.shared.uploadFile(to: .scanHistories, imageData: imageData) { imageRef, imageUrl in
            let scanHistory = ScanHistory(
                userUid: testUserInfo["uid"] ?? "Unknown User Uid",
                brandName: brandName,
                imageUrl: imageUrl,
                imageRef: imageRef,
                createdTime: Timestamp()
            )
            
            FirestoreManager.shared.create(in: .scanHistories, data: scanHistory)
        }
    }
}
