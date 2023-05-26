//
//  PhotoPreviewViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/23.
//

import UIKit

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
            captionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Add "Tag Friends" button
        view.addSubview(tagFriendsButton)
        NSLayoutConstraint.activate([
            tagFriendsButton.trailingAnchor.constraint(
                equalTo: captionButton.leadingAnchor, constant: -10),
            tagFriendsButton.centerYAnchor.constraint(
                equalTo: captionButton.centerYAnchor),
            tagFriendsButton.widthAnchor.constraint(equalToConstant: 120),
            tagFriendsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Add Discard button
        view.addSubview(discardButton)
        NSLayoutConstraint.activate([
            discardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            discardButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            discardButton.widthAnchor.constraint(equalToConstant: 120),
            discardButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Add Publish button
        view.addSubview(publishButton)
        NSLayoutConstraint.activate([
            publishButton.leadingAnchor.constraint(
                equalTo: captionButton.trailingAnchor, constant: 10),
            publishButton.centerYAnchor.constraint(
                equalTo: captionButton.centerYAnchor),
            publishButton.widthAnchor.constraint(equalToConstant: 120),
            publishButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func addCaption(_ button: UIButton) {
        let alertController = UIAlertController(
            title: "Add Caption",
            message: "Please enter a caption for your photo",
            preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Caption"
            textField.text = self.currentCaption  // Display the existing caption
        }
        let saveAction = UIAlertAction(
            title: "Save",
            style: .default,
            handler: { _ -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            self.currentCaption = firstTextField.text
            button.setTitle("Edit Caption", for: .normal)  // Change button title to "Edit Caption"
        })
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .default,
            handler: { _ -> Void in
            print("Cancelled")
        })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
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
        
        // Restart capture session
        startRunningCaptureSession()
    }
    
    @objc func publishImage(_ button: UIButton) {
        // Implement publishing of the image here
        // Save the ImageView image to DB
        // Get the URL and Ref of the image
        // Package the Post data
        if let image = imageView.image {
            FFSManager.shared.uploadPostImage(
                image: image
            ) { imageFileRef, imageUrl in
                
                let data: [String: Any] = [
                    "userId": FFSManager.shared.userId,
                    "caption": self.currentCaption as Any,
                    "taggedFriends": self.taggedFriends as Any,
                    "location": self.location as Any,
                    "imageUrl": imageUrl,
                    "imageFileRef": imageFileRef,
                    "time": Date().timeIntervalSince1970
                ]
                
                // Save the packaged data to Firestore
                if let post = Post(data: data) {
                    FFSManager.shared.addPost(post: post)
                } else {
                    print("Failed to add Post")
                }
            }
        }
        
        self.navigationController?.popToRootViewController(animated: false)
    }
}
