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
    // Capture Session Var
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var flashMode = AVCaptureDevice.FlashMode.off
    var picker: PHPickerViewController!
    
    // Preview Create Post Content Var
    var currentCaption: String?
    var taggedFriends: [String]?
    var location: String?
    var image: UIImage?
    let imageView = UIImageView()
    
    var shutterButton = UIButton()
    var flashButton = UIButton()
    var closeButton = UIButton()
    var imagePickerButton = UIButton()
    
    // Preview Create Post Button Config
    lazy var captionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Add Caption", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = UIColor(hexString: AppColor.green2.rawValue, alpha: 1.0)
        button.backgroundColor = UIColor(hexString: AppColor.dark2.rawValue, alpha: 1.0)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(addCaption), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Initially hidden
        return button
    }()
    
    lazy var publishButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" Publish", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setImage(UIImage(named: "icons8-post"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor(hexString: AppColor.dark2.rawValue, alpha: 1.0)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(publishImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Initially hidden
        return button
    }()
    
    lazy var tagFriendsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Tag Friends", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        button.tintColor = UIColor(hexString: AppColor.green2.rawValue, alpha: 1.0)
        button.backgroundColor = UIColor(hexString: AppColor.dark2.rawValue, alpha: 1.0)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(tagFriends), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Initially hidden
        return button
    }()
    
    lazy var discardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icons8-bin"), for: .normal)
        button.tintColor = UIColor(hexString: AppColor.red.rawValue, alpha: 1.0)
        button.backgroundColor = UIColor(hexString: AppColor.dark2.rawValue, alpha: 1.0)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(discardPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Initially hidden
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        setupUI()
        setupPreviewPhotoUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        // Hide the tab bar
        tabBarController?.tabBar.isHidden = true
        
        startRunningCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        self.captureSession.stopRunning()
    }
}

// MARK: - User Take Photo from Camera
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            // Save the captured image to photo library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { [weak self] success, error in
                if success {
                    print("Photo saved successfully")
                } else if let error = error {
                    print("Error saving photo: \(error)")
                }
                
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    
                    self?.stopRunningCaptureSession()
                }
            })
        }
    }
}

// MARK: - User Pick Photo From PHPicker
extension CameraViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Close Photo Picker View
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let error = error { print("PHPicker loading error: \(error)") }
                
                if let image = object as? UIImage {
                    
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        
                        self.imageView.isHidden = false
                        self.captionButton.isHidden = false
                        self.publishButton.isHidden = false
                        self.tagFriendsButton.isHidden = false
                        self.discardButton.isHidden = false

                        self.shutterButton.isHidden = true
                        self.flashButton.isHidden = true
                        self.closeButton.isHidden = true
                        self.imagePickerButton.isHidden = true
                    }
                }
            }
        }
    }
}

// MARK: - AVCapture Session, Input, Output Setup
extension CameraViewController {
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
            guard let currentCamera = currentCamera else {
                print("Camera is not available")
                return
            }
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera)
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
         cameraPreviewLayer?.frame = CGRect(
            x: 0,
            y: self.view.frame.height / 6,
            width: self.view.frame.width,
            height: self.view.frame.height / 2)
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        DispatchQueue.global().async {
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                // Unhide buttons when camera resumes
                self.shutterButton.isHidden = false
                self.flashButton.isHidden = false
                self.closeButton.isHidden = false
                self.imagePickerButton.isHidden = false
                
                // Hide buttons when camera resumes
                self.captionButton.isHidden = true
                self.publishButton.isHidden = true
                self.tagFriendsButton.isHidden = true
                self.discardButton.isHidden = true
            }
        }
    }
    
    func stopRunningCaptureSession() {
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
            // Hide buttons when camera resumes
            self.shutterButton.isHidden = true
            self.flashButton.isHidden = true
            self.closeButton.isHidden = true
            self.imagePickerButton.isHidden = true
            
            // Unhide buttons when camera resumes
            self.captionButton.isHidden = false
            self.publishButton.isHidden = false
            self.tagFriendsButton.isHidden = false
            self.discardButton.isHidden = false
        }
    }
}

// MARK: - UI Components Setup on Camera
extension CameraViewController {
    func setupUI() {
        // Shutter button
        shutterButton = UIButton(frame: CGRect(
            x: view.frame.width / 2 - 75,
            y: view.frame.height - 200,
            width: 150,
            height: 150))
        shutterButton.setImage(UIImage(named: "icons8-circle-fill"), for: .normal)
        shutterButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        view.addSubview(shutterButton)
        
        // Flash button
        flashButton = UIButton(frame: CGRect(x: 10, y: 50, width: 60, height: 60))
        flashButton.setImage(UIImage(named: "icons8-flash-off"), for: .normal)
        flashButton.addTarget(self, action: #selector(toggleFlash(_:)), for: .touchUpInside)
        view.addSubview(flashButton)
        
        // Close button
        closeButton = UIButton(frame: CGRect(x: view.frame.width - 70, y: 50, width: 60, height: 60))
        closeButton.setImage(UIImage(named: "icons8-close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeCamera(_:)), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Image Picker Button
        imagePickerButton = UIButton(frame: CGRect(x: 10, y: view.frame.height - 155, width: 60, height: 60))
        imagePickerButton.setImage(UIImage(named: "icons8-photos"), for: .normal)
        imagePickerButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        view.addSubview(imagePickerButton)
        
        // Configure PHPicker
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        // Add image view to the Preview View
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 1  // You can adjust this
        imageView.isHidden = true
        
        imageView.frame = CGRect(
            x: 0,
            y: self.view.frame.height / 6,
            width: self.view.frame.width,
            height: self.view.frame.height / 2)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
    }
    
    @objc func captureImage(_ button: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput?.capturePhoto(with: settings, delegate: self)
        stopRunningCaptureSession()
    }
    
    @objc func toggleFlash(_ button: UIButton) {
        flashMode = flashMode == .on ? .off : .on
        button.setImage(flashMode == .on ?
        UIImage(named: "icons8-flash") :
        UIImage(named: "icons8-flash-off"), for: .normal)
    }
    
    @objc func closeCamera(_ button: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func openImagePicker(_ button: UIButton) {
        present(picker, animated: true)
    }
}
