//
//  AVPlayerView.swift
//  MappaCore
//
//  Created by 秋元　健太 on 2015/11/02.
//  Copyright © 2015年 KentaAkimoto. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerView: UIView {
    
    
    // AVPlayerのgetterとsetter
    var player: AVPlayer {
        get {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            return layer.player!
        }
        set(newValue) {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            layer.player = newValue
        }
    }
    // layerClassのoverride
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    func setVideoFillMode(mode: NSString) {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        layer.videoGravity = mode as String
    }
}