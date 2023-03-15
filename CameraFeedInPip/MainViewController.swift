//
//  MainViewController.swift
//  RemoteNDI
//
//  Created by Geart Otten on 20/05/2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    private let config = Config.default
    
    private lazy var localButton: UIButton = {
       var button = UIButton()
        button.setTitle("Local", for: .normal)
        button.addTarget(self, action: #selector(goToOnSiteView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var remoteButton: UIButton = {
       var button = UIButton()
        button.setTitle("Remote", for: .normal)
        button.addTarget(self, action: #selector(goToOffSiteView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var testButton: UIButton = {
       var button = UIButton()
        button.setTitle("Test PiP", for: .normal)
        button.addTarget(self, action: #selector(goToPiPTestView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var signalClient: SignalingClient
    
    init(signalClient: SignalingClient) {
        self.signalClient = signalClient
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(remoteButton)
        self.view.addSubview(localButton)
        self.view.addSubview(testButton)
        
        NSLayoutConstraint.activate([
            localButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            localButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 80),
            
            remoteButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -80),
            remoteButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            testButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -240),
            testButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        // Do any additional setup after loading the view.
    }

    @objc
    func goToOnSiteView() {
        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        
        let viewController = LocalViewController(signalClient: self.signalClient, webRTCClient: webRTCClient)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    func goToOffSiteView() {
        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        webRTCClient.createMediaSenderOffSite()
        
        let viewController = RemoteViewController(signalClient: self.signalClient, webRTCClient: webRTCClient)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    func goToPiPTestView() {
        let viewController = CameraFeedInPiPController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
