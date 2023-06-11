//
//  PhotoPreviewViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// Preview Create Post Related UI Setup
extension CameraViewController {
    func setupPreviewPhotoUI() {
        // Add Caption Button
        view.addSubview(captionButton)
        NSLayoutConstraint.activate([
            captionButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            captionButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -80),
            captionButton.widthAnchor.constraint(equalToConstant: 120),
            captionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add "Tag Friends" button
        view.addSubview(tagFriendsButton)
        NSLayoutConstraint.activate([
            tagFriendsButton.trailingAnchor.constraint(
                equalTo: captionButton.leadingAnchor, constant: -10),
            tagFriendsButton.centerYAnchor.constraint(
                equalTo: captionButton.centerYAnchor),
            tagFriendsButton.widthAnchor.constraint(equalToConstant: 120),
            tagFriendsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add Discard button
        view.addSubview(discardButton)
        NSLayoutConstraint.activate([
            discardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            discardButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            discardButton.widthAnchor.constraint(equalToConstant: 50),
            discardButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add Publish button
        view.addSubview(publishButton)
        NSLayoutConstraint.activate([
            publishButton.leadingAnchor.constraint(
                equalTo: captionButton.trailingAnchor, constant: 10),
            publishButton.centerYAnchor.constraint(
                equalTo: captionButton.centerYAnchor),
            publishButton.widthAnchor.constraint(equalToConstant: 120),
            publishButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func addCaption(_ button: UIButton) {
        let alertController = UIAlertController(
            title: "Add Caption",
            message: "Please enter a caption for your photo",
            preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Caption"
            if let caption = textField.text {
                self.currentCaption = caption
            }
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .default,
            handler: { _ -> Void in
                print("Cancelled")
            })
        
        let saveAction = UIAlertAction(
            title: "Save",
            style: .default,
            handler: { _ -> Void in
                let textField = alertController.textFields![0] as UITextField
                button.setTitle("Edit Caption", for: .normal)
                if let caption = textField.text {
                    self.currentCaption = caption
                }
            })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // TODO: Location / Tag Friend when posting (optional)
    @objc func tagFriends(_ button: UIButton) {
        // Implement tagging of friends here
    }
    
    @objc func discardPhoto(_ button: UIButton) {
        // Hide buttons and clear photo
        self.imageView.image = nil
        self.imageView.isHidden = true
        self.captionButton.isHidden = true
        self.publishButton.isHidden = true
        self.tagFriendsButton.isHidden = true
        self.discardButton.isHidden = true
        
        startRunningCaptureSession()
    }
    
    @objc func publishImage(_ button: UIButton) {
        if let image = imageView.image,
           let imageData = FirebaseManager.shared.rotateImageToUp(image: image) {
            
            FirebaseManager.shared.uploadFile(to: .posts, imageData: imageData) { [weak self] imageRef, imageUrl in
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let post = Post(
                    userUid: uid,
                    caption: self?.currentCaption,
                    imageUrl: imageUrl,
                    imageRef: imageRef,
                    createdTime: Timestamp(),
                    taggedFriends: self?.taggedFriends ?? ["No Friend Tagged"],
                    location: self?.location ?? "No location"
                )
                
                FirebaseManager.shared.create(in: .posts, data: post)
                // Clear whatever is in this variable after posting
                self?.currentCaption = ""
            }
            
        } else {
            print("Failed to get image data")
        }
        
        performSegue(withIdentifier: "backToPosts", sender: nil)
    }
}
