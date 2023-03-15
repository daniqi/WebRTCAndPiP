//
//  PreviewView.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 06/03/2023.
//

import UIKit
import AVKit

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVSampleBufferDisplayLayer.self
    }
    
    var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer {
        layer as! AVSampleBufferDisplayLayer
    }
 
    public init() {
        super.init(frame: .zero)
        
        // TODO: Frame size is not used for PiP view when using resizeAspectFill.
//        sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        sampleBufferDisplayLayer.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
