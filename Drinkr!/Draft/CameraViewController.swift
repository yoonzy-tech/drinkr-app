//
//  CameraViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/22.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI

class CameraViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var image: UIImage?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var picker: PHPickerViewController!
    
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        // Hide the tab bar
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices where device.position == AVCaptureDevice.Position.back {
            backCamera = device
        }
        currentCamera = backCamera
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray(
                [AVCapturePhotoSettings(
                format: [AVVideoCodecKey: AVVideoCodecType.jpeg])],
                completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
    func setupUI() {
        // Shutter button
        let shutterButton = UIButton(frame: CGRect(
            x: view.frame.width / 2 - 30,
            y: view.frame.height - 100,
            width: 60,
            height: 60))
        shutterButton.layer.cornerRadius = shutterButton.bounds.height / 2
        shutterButton.backgroundColor = .white
        shutterButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        view.addSubview(shutterButton)
        
        // Flash button
        let flashButton = UIButton(frame: CGRect(x: 10, y: 50, width: 60, height: 60)) // Move to top-left
        flashButton.setTitle("Flash", for: .normal)
        flashButton.addTarget(self, action: #selector(toggleFlash(_:)), for: .touchUpInside)
        view.addSubview(flashButton)
        
        // Close button
        let closeButton = UIButton(frame: CGRect(x: view.frame.width - 70, y: 50, width: 60, height: 60))
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeCamera(_:)), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Image Picker Button
        let imagePickerButton = UIButton(frame: CGRect(x: 10, y: view.frame.height - 100, width: 60, height: 60))
        imagePickerButton.setTitle("Pick", for: .normal)
        imagePickerButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        view.addSubview(imagePickerButton)
        
        // Configure PHPicker
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        // Add image view to the previewView
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 1  // You can adjust this
        imageView.isHidden = true
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func captureImage(_ button: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func toggleFlash(_ button: UIButton) {
        flashMode = flashMode == .on ? .off : .on
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(flashMode == .on ? "Flash On" : "Flash Off", for: .normal)
    }
    
    @objc func closeCamera(_ button: UIButton) {
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openImagePicker(_ button: UIButton) {
        present(picker, animated: true)
    }

}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    // AVCapturePhotoCaptureDelegate method
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            // Save the captured image to photo library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                if success {
                    print("Photo saved successfully")
                } else if let error = error {
                    print("Error saving photo: \(error)")
                }
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.imageView.isHidden = false
//                    let photoPreviewViewController = PhotoPreviewViewController()
//                    photoPreviewViewController.photo = self.image
//                    self.navigationController?.pushViewController(photoPreviewViewController, animated: true)
                }
            })
        }
    }
}

extension CameraViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let error = error {
                    print("PHPicker loading error: \(error)")
                }
                self.captureSession.stopRunning()
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        self.imageView.isHidden = false
//                        let photoPreviewViewController = PhotoPreviewViewController()
//                        photoPreviewViewController.photo = image
//                        self.navigationController?.pushViewController(photoPreviewViewController, animated: true)
                        
                    }
                }
            }
        }
    }
}
