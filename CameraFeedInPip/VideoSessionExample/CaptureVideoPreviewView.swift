//
//  CaptureVideoPreview.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 08/03/2023.
//

import UIKit
import AVKit

class CaptureVideoPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
 
    init(_ session: AVCaptureSession) {
        super.init(frame: .zero)
        
        previewLayer.session = session
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
