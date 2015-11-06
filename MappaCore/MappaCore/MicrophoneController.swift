//
//  MicrophoneController.swift
//  MappaCore
//
//  Created by 秋元　健太 on 2015/11/03.
//  Copyright © 2015年 KentaAkimoto. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class MicrophoneController: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {

    let captureSession:AVCaptureSession = AVCaptureSession()
    let microphoneDevice:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
    var captureMicrophoneDeviceInput:AVCaptureDeviceInput? = nil
    let captureMicrophoneDeviceDataOutput:AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    
    func start() throws {
        try captureMicrophoneDeviceInput = AVCaptureDeviceInput(device: self.microphoneDevice)
        self.captureMicrophoneDeviceDataOutput.setSampleBufferDelegate(self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0))
        self.captureSession.addInput(self.captureMicrophoneDeviceInput)
        self.captureSession.addOutput(self.captureMicrophoneDeviceDataOutput)
        self.captureSession.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
            NSLog("aaa")
            // 音の大きさを取るにはどうすればよい？
    }
    
}
