//
//  OnSiteViewController.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 14/03/2023.
//

import UIKit
import AVKit
import WebRTC

class LocalViewController: UIViewController {
    var signalClient: SignalingClient
    var webRTCClient: WebRTCClient
    
    var pipVideoCallViewController: AVPictureInPictureVideoCallViewController?
    var pipController: AVPictureInPictureController?
    
    private var startPipButton: UIButton = {
       var button = UIButton()
        button.setTitle("Start PiP", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        return button
    }()
    
    lazy private var callButton: UIButton = {
       var button = UIButton()
        button.setTitle("Call", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(call), for: .touchUpInside)
        return button
    }()
    
    private var previewView: PreviewView?
    
    init(signalClient: SignalingClient, webRTCClient: WebRTCClient) {
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        previewView = PreviewView()
        
        pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        pipVideoCallViewController?.view?.addSubview(self.previewView!)
        view.addSubview(pipVideoCallViewController!.view)
        
        setupPipController()
        
        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        self.signalClient.connect()
        
        self.setupRenderers()
        
        addStartPiPButton()
        addCallButton()
        
        // TODO: unmute
        self.webRTCClient.muteAudio()
        
    }
    
    private func setupRenderers() {
        let localRenderer = RTCMTLVideoView(frame: self.previewView!.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        
        // MARK: Render Off-site (remote) front-camera in On-site pip view.
        self.webRTCClient.renderRemoteVideo(to: localRenderer)
        
        
//        localRenderer.layer.sampleBufferDisplayLayer
//        self.previewView?.addSubview(localRenderer)
//        self.embedView(localRenderer, into: onSitePipView)
    }
     
    private func setupPipController() {
        let source = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: self.previewView!.sampleBufferDisplayLayer, playbackDelegate: self)
        
        pipController = AVPictureInPictureController(contentSource: source)
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        pipController?.delegate = self
    }
    
    @objc
    private func call() {
        self.webRTCClient.offer { (sdp) in
            self.signalClient.send(sdp: sdp)
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
    
    private func addCallButton() {
        view.addSubview(callButton)
        
        NSLayoutConstraint.activate([
            callButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            callButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -100),
        ])
    }
    
}

extension LocalViewController: AVPictureInPictureSampleBufferPlaybackDelegate {
    // Tells the delegate that the user requested to begin or pause playback.
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
//        pictureInPictureController.playerLayer.player?.play()
        print("isPlaying")
        
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

extension LocalViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip controller will start pip")
        print(pictureInPictureController)
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("error when starintg pip")
        print(error)
    }
    
}

extension LocalViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
//        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
//        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
//            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient.set(remoteCandidate: candidate) { error in
//            print("Received remote candidate")
//            self.remoteCandidateCount += 1
        }
    }
}

extension LocalViewController: WebRTCClientDelegate {
    func didCaptureFrame(frame: RTCVideoFrame) {
        print(frame)
//        let pixelBuffer = RTCCVPixelBuffer(pixelBuffer: frame.buffer as! CVPixelBuffer)
//
//        self.previewView?.sampleBufferDisplayLayer.enqueue(pixelBuffer.pixelBuffer)
//
//        print(pixelBuffer)
    }
    
    func didCaptureOutput(buffer: CMSampleBuffer) {
        //
    }
    
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
            self.signalClient.send(candidate: candidate)
        }
        
        func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
            let textColor: UIColor
            
            print("change connection ")
            switch state {
            case .connected, .completed:
                textColor = .green
            case .disconnected:
                textColor = .orange
            case .failed, .closed:
                textColor = .red
            case .new, .checking, .count:
                textColor = .black
            @unknown default:
                textColor = .black
            }
            DispatchQueue.main.async {
                print(state.description.capitalized)
            }
        }
        
        func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
            DispatchQueue.main.async {
                let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
                let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
}
