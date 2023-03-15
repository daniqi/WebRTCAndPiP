//
//  ViewController2.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 08/03/2023.
//

import UIKit
import AVFoundation
import AVKit

class ViewController2: UIViewController {
    
    let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "Capture Session Queue")
    
    var pipVideoCallViewController: AVPictureInPictureVideoCallViewController!
    var pipController: AVPictureInPictureController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let previewView = CaptureVideoPreviewView(captureSession)
        
        pipVideoCallViewController = .init(previewView,
                                           preferredContentSize: CGSize(width: 1080, height: 1920))
        
        let pipContentSource = AVPictureInPictureController.ContentSource(
                                    activeVideoCallSourceView: view,
                                    contentViewController: pipVideoCallViewController)
        
        pipController = AVPictureInPictureController(contentSource: pipContentSource)
        pipController.delegate = self
        pipController.canStartPictureInPictureAutomaticallyFromInline = true
        
        startSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !pipController.isPictureInPictureActive {
            pipController.startPictureInPicture()
        }
    }

    private func startSession() {
        captureSessionQueue.async { [unowned self] in
            
            let device = AVCaptureDevice.default(for: .video)!
            
            captureSession.addInput(try! AVCaptureDeviceInput(device: device))
            
            captureSession.sessionPreset = .hd1920x1080
            
            captureSession.isMultitaskingCameraAccessEnabled = captureSession.isMultitaskingCameraAccessSupported
                        
            captureSession.startRunning()
        }
    }

}

extension ViewController2: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print(error.localizedDescription)
    }
}


extension AVPictureInPictureVideoCallViewController {
    
    convenience init(_ previewView: CaptureVideoPreviewView, preferredContentSize: CGSize) {
        
        // Initialize.
        self.init()
        
        // Set the preferredContentSize.
        self.preferredContentSize = preferredContentSize
        
        // Configure the PreviewView.
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.frame = self.view.frame
        
        self.view.addSubview(previewView)
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: self.view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
}
