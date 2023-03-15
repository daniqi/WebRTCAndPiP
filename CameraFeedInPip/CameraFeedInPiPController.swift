//
//  ViewController.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 06/03/2023.
//

import UIKit
import AVKit

class CameraFeedInPiPController: UIViewController {
    var pipVideoCallViewController: AVPictureInPictureVideoCallViewController?
    
    var pipController: AVPictureInPictureController?
    
    private var startPipButton: UIButton = {
       var button = UIButton()
        button.setTitle("Start PiP", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        return button
    }()
    
    private var previewView: PreviewView?
    
    private let videoOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupSession()
        captureCamera()
        previewView = PreviewView()
        
        pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        pipVideoCallViewController?.view?.addSubview(self.previewView!)
        
        view.addSubview(pipVideoCallViewController!.view)
        
        setupPipController()
        addStartPiPButton()
        
        // MARK: observe notifications when capture session was interrupted.
        NotificationCenter.default.addObserver(self, selector: #selector(CameraFeedInPiPController.sessionWasInterrupted(notification:)), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: captureSession)
        
    }
     
    var captureSession: AVCaptureSession?
    var frontInput: AVCaptureInput?
    
    @objc func sessionWasInterrupted(notification: Notification) {
        print(notification)
    }
    
    private func setupPipController() {
        let source = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: self.previewView!.sampleBufferDisplayLayer, playbackDelegate: self)
        
        pipController = AVPictureInPictureController(contentSource: source)
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        pipController?.delegate = self
    }
    
    private func setupSession() {
        captureSession = AVCaptureSession()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
        guard let device = deviceDiscoverySession.devices.first else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        captureSession?.addInput(input)
        
        // Enable MultitaskingCamera
        if captureSession?.isMultitaskingCameraAccessSupported == true {
            print("multitasking is supported")
            
            captureSession?.isMultitaskingCameraAccessEnabled = true
        } else {
            print("multitasking is not supported")
        }
        
        self.addVideoOutput()
    }
    
    private func addVideoOutput() {
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession?.addOutput(self.videoOutput)
    }

    private func captureCamera() {
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
        
        backgroundQueue.async {
            self.captureSession?.startRunning()
        }
    }
    
    @objc
    private func startPip() {
        if pipController!.isPictureInPictureActive {
            pipController?.stopPictureInPicture()
        } else {
            pipController?.startPictureInPicture()
        }
    }
    
    private func addStartPiPButton() {
        startPipButton.addTarget(self, action: #selector(startPip), for: .touchUpInside)
        view.addSubview(startPipButton)
        
        NSLayoutConstraint.activate([
            startPipButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            startPipButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
        ])
    }
    
}

extension CameraFeedInPiPController: AVPictureInPictureSampleBufferPlaybackDelegate {
    // Tells the delegate that the user requested to begin or pause playback.
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
//        pictureInPictureController.playerLayer.player?.play()
        print(playing)
    }
    
    // Asks the delegate for the current playable time range.
    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        return CMTimeRange(start: .negativeInfinity, duration: .positiveInfinity)
    }
    
    // Asks delegate to indicate whether the playback UI reflects a playing or paused state, regardless of the current playback rate.
    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        print(pictureInPictureController.isPictureInPicturePossible)
        return true
    }
    
    // Tells the delegate that the user has requested skipping forward or backward by the indicated time interval.
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {
        print("didTransition")
        
        print(newRenderSize)
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
        print("test")
    }
}

extension CameraFeedInPiPController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip controller will start pip")
        print(pictureInPictureController)
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("error when starintg pip")
        print(error)
    }
    
}

extension CameraFeedInPiPController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        
        // give sampleBuffer to sampleBufferDisplayLayer
        DispatchQueue.main.async {
            self.previewView!.sampleBufferDisplayLayer.enqueue(sampleBuffer)
        }
        
//        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            debugPrint("unable to get image from sample buffer")
//            return
//        }
    }
}
