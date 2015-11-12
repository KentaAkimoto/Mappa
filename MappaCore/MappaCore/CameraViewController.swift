//
//  CameraViewController.swift
//  MappaCore
//
//  Created by 秋元　健太 on 2015/11/02.
//  Copyright © 2015年 KentaAkimoto. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation


class CameraViewController: UIViewController {

    var sceneView:SCNView? = nil
    var captureDevice:AVCaptureDevice? = nil
    var captureDeviceInput:AVCaptureDeviceInput? = nil
    var captureSession:AVCaptureSession? = nil
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        
        // キャプチャーデバイスの初期化
        let error:NSError? = nil
        var deviceCamera:AVCaptureDevice? = nil
        for caputureDevice: AnyObject in AVCaptureDevice.devices() {
            // 背面カメラを取得
            if caputureDevice.position == AVCaptureDevicePosition.Back {
                deviceCamera = caputureDevice as? AVCaptureDevice
            }
            // 前面カメラを取得
            //if caputureDevice.position == AVCaptureDevicePosition.Front {
            //    camera = caputureDevice as? AVCaptureDevice
            //}
        }
        
        
        self.captureDevice = deviceCamera
        do {
            try self.captureDeviceInput = AVCaptureDeviceInput(device: self.captureDevice)
            self.captureSession = AVCaptureSession()
            self.captureSession!.canAddInput(self.captureDeviceInput)
        } catch {
            
        }
        if(self.captureDeviceInput == nil){
            NSLog("%@", error!)
        }
        
        // キャプチャーセッションの初期化
//        self.captureSession = AVCaptureSession()
        self.captureSession!.addInput(self.captureDeviceInput)
        
        // レイヤーの初期化
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.captureVideoPreviewLayer!.frame = CGRectMake(0, 0, 100, 100)
        self.captureVideoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.captureSession?.startRunning()

        // CoreImage
        let filter:CIFilter = CIFilter(name: "CIPixellate")!
        filter.setDefaults()
        filter.setValue(50, forKey:"inputScale")
        self.captureVideoPreviewLayer!.filters = [filter]
        
        // SceneKit
        let scnView = self.view as! SCNView
        
        scnView.scene = SCNScene()
        scnView.showsStatistics = true
        
        let camera:SCNCamera = SCNCamera()
        let cameraNode:SCNNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 0, 30)
        scnView.scene!.rootNode.addChildNode(cameraNode)
        
        let planeMaterial:SCNMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = self.captureVideoPreviewLayer
        let boxGeometry:SCNBox = SCNBox(width:20,height:20,length:20,chamferRadius:0)
        boxGeometry.materials = [planeMaterial]
        
        let node:SCNNode = SCNNode()
        node.geometry = boxGeometry
        
        scnView.scene!.rootNode.addChildNode(node)
        
        scnView.pointOfView = cameraNode
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
