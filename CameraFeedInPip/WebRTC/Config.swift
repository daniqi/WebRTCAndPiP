//
//  Config.swift
//  RemoteNDI
//
//  Created by Danick Sikkema on 25/01/2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

// Set this to the machine's address which runs the signaling server. Do not use 'localhost' or '127.0.0.1'
fileprivate let defaultSignalingServerUrl = URL(string: "")!

// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
}

