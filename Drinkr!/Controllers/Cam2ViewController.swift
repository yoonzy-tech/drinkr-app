//
//  Cam2ViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import UIKit
import AVFoundation
import PhotosUI

class Cam2ViewController: UIViewController, PHPickerViewControllerDelegate {
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    let cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeCamera), for: .touchUpInside)
        return button
    }()
    
    let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Flash", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        return button
    }()
    
    let pickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Picker", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
        return button
    }()
    
    let shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Shutter", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(Cam2ViewController.self, action: #selector(captureImage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }

    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(videoPreviewLayer)

        // Start Session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()

            // Size the layer to fit into the UIView frame.
            DispatchQueue.main.async {
                self?.videoPreviewLayer.frame = self?.cameraView.bounds ?? CGRect.zero
            }
        }
    }

    
    func setupUI() {
        view.addSubview(cameraView)
        view.addSubview(closeButton)
        view.addSubview(flashButton)
        view.addSubview(pickerButton)
        view.addSubview(shutterButton)
        
        NSLayoutConstraint.activate([
            cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraView.widthAnchor.constraint(equalTo: view.widthAnchor),
            cameraView.heightAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 0.75), // This is for 4:3 aspect ratio
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            flashButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            flashButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            pickerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func closeCamera() {
        // Implement closing the camera (e.g., dismiss the view controller or pop from navigation controller)
    }
    
    @objc func toggleFlash() {
        // Implement toggling the flash
    }
    
    @objc func openPicker() {
        // Implement opening PHPicker
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func captureImage() {
        // Implement capturing image with AVFoundation
    }
    
    // PHPicker delegate methods
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
    }
}

