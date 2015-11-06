//
//  GameViewController.swift
//  MappaCore
//
//  Created by 秋元　健太 on 2015/11/01.
//  Copyright (c) 2015年 KentaAkimoto. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation
//import CoreMotion

class GameViewController: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var avPlayerView: AVPlayerView!
    
    
    let videoUrl:NSURL = NSURL(string: "http://devstreaming.apple.com/videos/wwdc/2015/206v5ce46maax7s/206/hls_vod_mvp.m3u8")!
    var avPlayer:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var playerBackgroundLayer:CALayer? = nil
    var assets:AVURLAsset? = nil
    var playerItem:AVPlayerItem? = nil
    
    var microphoneVolumeLevelMeter:MicrophoneVolumeLevelMeter? = nil
    
//    var motionManager:CMMotionManager? = nil
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "status" {
            let status : AVPlayerItemStatus = self.playerItem!.status as AVPlayerItemStatus
            
            if status == .ReadyToPlay {
                // 再生準備完了
                NSLog("ReadyToPlay")
                // playerのセット
                self.avPlayer?.play()
            }
            else if status == .Failed {
                NSLog("Failed")
            }
            else if status == .Unknown {
                NSLog("Unknown")
            }
        }
        else if keyPath == "readyForDisplay" {
                        
//            self.avPlayerView = AVPlayerView(frame: CGRectMake(0,0,100,100))
            self.avPlayerView!.player = self.avPlayer!
            self.view.addSubview(self.avPlayerView!)
            self.view.sendSubviewToBack(self.avPlayerView!)
            start()

        }
            
        else {
            super.observeValueForKeyPath(keyPath,
                ofObject: object,
                change: change,
                context: context)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let displayLink: CADisplayLink = CADisplayLink(target: self, selector: "update:")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    override func awakeFromNib() {
        
        self.assets = AVURLAsset(URL: self.videoUrl) as AVURLAsset
        self.playerItem = AVPlayerItem(asset: self.assets!)
        
        // PlayerのStatusを監視するためにKVOをセットします
        self.playerItem!.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        self.avPlayer = AVPlayer(playerItem: self.playerItem!) as AVPlayer
        
        self.avPlayer!.play()
        self.playerLayer = AVPlayerLayer(player: self.avPlayer)
        self.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.playerLayer!.frame = CGRectMake(0,0,1000,1000)
        self.playerLayer?.addObserver(self, forKeyPath: "readyForDisplay", options: NSKeyValueObservingOptions.New, context: nil)
        
        self.playerBackgroundLayer = CALayer()
        self.playerBackgroundLayer!.backgroundColor = UIColor.blackColor().CGColor
        self.playerBackgroundLayer!.frame = CGRectMake(0, 0, 600, 800)
        self.playerBackgroundLayer!.addSublayer(self.playerLayer!)
        
        // CoreImage
        let filter:CIFilter = CIFilter(name: "CIPixellate")!
        filter.setDefaults()
        filter.setValue(50, forKey: "inputScale")
        self.playerLayer!.filters = [filter]
        
        //self.audioController = AudioController()
        //audioController!.start()
/*
        // 加速度センサー
        self.motionManager = CMMotionManager()
        if (self.motionManager!.accelerometerAvailable)
        {
            // センサーの更新間隔の指定
            self.motionManager!.accelerometerUpdateInterval = 1 / 10;  // 10Hz
            
            // ハンドラを指定
            let handler:CMAccelerometerHandler = { data,error in
                NSLog("%f,%f,%f", data!.acceleration.x, data!.acceleration.y, data!.acceleration.z)
            }
            
            // 加速度の取得開始
            self.motionManager!.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
*/
    }
    
        
    func start() {
        
        // create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 30, z: 15)
        // カメラ向き
        cameraNode.rotation = SCNVector4Make(1, 0, 0, -Float(M_PI_4))
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 30, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // 床
        // Make floor node
        let floorNode = SCNNode()
        let floor = SCNFloor()
        floor.firstMaterial!.diffuse.contents = UIColor.clearColor()
        floor.reflectivity = 0.25
        floorNode.geometry = floor
        // Floor Physics
        let floorShape = SCNPhysicsShape(geometry: floor, options: nil)
        let floorBody = SCNPhysicsBody(type: .Static, shape: floorShape)
        floorNode.physicsBody = floorBody;
        scene.rootNode.addChildNode(floorNode)

        // 箱
        let numBox = 300
        let camDistance:CGFloat = 55.0
        // Add box nodes to the scene
        for _ in 0..<numBox {
            let node = SCNNode()
            let rdx:CGFloat = (randomCGFloat() * camDistance - camDistance / 2)
            let rdy:CGFloat = randomCGFloat() * 300
            let rdz:CGFloat = randomCGFloat() * camDistance - camDistance / 2
            node.position = SCNVector3Make(Float(rdx), Float(rdy), Float(rdz))
            let box = SCNBox(width: randomCGFloat() * 5.0, height: randomCGFloat() * 5.0, length: randomCGFloat() * 5.0, chamferRadius: 0.0)
            node.geometry = box

            /*
            // Create and configure a material
            let material = SCNMaterial()
            material.specular.contents = UIColor.blueColor()
            material.locksAmbientWithDiffuse = true
            
            // Set shaderModifiers properties
            let snipet = "uniform float Scale = 3.0;\n" +
                "uniform float Width = 0.5;\n" +
                "uniform float Blend = 0.0;\n" +
                "vec2 position = fract(_surface.diffuseTexcoord * Scale);" +
                "float f1 = clamp(position.y / Blend, 0.0, 1.0);" +
                "float f2 = clamp((position.y - Width) / Blend, 0.0, 1.0);" +
                "f1 = f1 * (1.0 - f2);" +
                "f1 = f1 * f1 * 2.0 * (3. * 2. * f1);" +
            "_surface.diffuse = mix(vec4(1.0), vec4(0.0), f1);"
            
            material.shaderModifiers = [SCNShaderModifierEntryPointSurface: snipet]
            
            // Set the material to the 3D object geometry
            node.geometry?.firstMaterial = material
            */
            
            node.geometry?.firstMaterial?.diffuse.contents = self.imageWithString(self.randomText()) //UIColor.blueColor()
            
            let boxShape = SCNPhysicsShape(geometry: box, options: nil)
            let boxBody = SCNPhysicsBody(type: .Dynamic, shape: boxShape)
            
            node.physicsBody = boxBody;
            node.name = "box"
            scene.rootNode.addChildNode(node)
        }
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
//        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
//        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.clearColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        scnView.addGestureRecognizer(tapGesture)
        
        
        // 壁を生成
        //self.createManyBoxNode()

        /*
        // 映像を映す箱
        let planeMaterial:SCNMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.greenColor() //self.playerBackgroundLayer
        let boxGeometry:SCNBox = SCNBox(width:10,height:10,length:10,chamferRadius:0)
        boxGeometry.materials = [planeMaterial]
        let node:SCNNode = SCNNode()
        node.geometry = boxGeometry
        scnView.scene?.rootNode.addChildNode(node)
        */
        
    }
    
    func randomCGFloat() -> CGFloat {
        return CGFloat(arc4random()) /  CGFloat(UInt32.max)
    }
    
    // 壁
    func createManyBoxNode() {
        
        let startPx:Double = -22.5
        let startPy:Double =   0.0;
        let stepPx:Double  =   2.5;
        let stepPy:Double  =   1.5;
    
        for (var px:Double = 0; px < 20; px++) {
            for (var py:Double = 0 ; py < 10; py++) {
            
                let boxPx:Double = startPx + stepPx * px
                let boxPy:Double = startPy + stepPy * py
            
                self.createBoxNode(SCNVector3Make(Float(boxPx), Float(boxPy + py * 1.5), -50))
            }
        }
    
    }
    
    func createBoxNode(vecter3:SCNVector3) {
    
        let boxGeometory:SCNGeometry = SCNBox(width: 2.5,height: 1.5,length: 4.5,chamferRadius: 0.0)
        boxGeometory.firstMaterial!.diffuse.contents = UIColor(red: self.randomColorNumber(),green:self.randomColorNumber(), blue:self.randomColorNumber(),alpha:1.0)
        
        let boxGeometoryNode:SCNNode                = SCNNode(geometry: boxGeometory)
        boxGeometoryNode.position                = vecter3
        boxGeometoryNode.name                    = "boxGeometory"
        boxGeometoryNode.physicsBody             = SCNPhysicsBody()
        boxGeometoryNode.physicsBody!.mass        = 0.01
        boxGeometoryNode.physicsBody!.restitution = 0.2
        
//        let scnView:SCNView = self.view as! SCNView
        scnView.scene!.rootNode.addChildNode(boxGeometoryNode)
    
    }
    
    func randomColorNumber() -> CGFloat {
        let colorNumber:Double = Double(arc4random_uniform(100))
        return CGFloat(colorNumber / 200.0 + 0.5)
    }
    
    
    
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        //let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material:SCNMaterial = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            // タップしたら一定時間後に削除する
            let delay = 0.5 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                if result.node.geometry is SCNBox && result.node.name == "box" {
//                    result.node.removeFromParentNode()

                    // nodeを移動させる
                    // 移動方向、移動先
                    result.node.physicsBody?.applyForce(SCNVector3Make(-Float(10.0), 0, 0), atPosition: SCNVector3Make(-Float(10.0), -Float(5.0), 0), impulse: true)
                    
                    NSLog("%f,%f,%f", result.node.presentationNode.position.x, result.node.presentationNode.position.y, result.node.presentationNode.position.z)
                }
            })
            
            SCNTransaction.commit()
            
        }
    }

    func imageWithString(text:String) -> UIImage
    {
        
        // 描画する文字列の情報を指定する
        //--------------------------------------
        
        // 文字描画時に反映される影の指定
        let shadow:NSShadow = NSShadow()
        shadow.shadowOffset = CGSizeMake(0, -0.5)
        shadow.shadowColor = UIColor.darkGrayColor()
        shadow.shadowBlurRadius = 0
        
        // 文字描画に使用するフォントの指定
        let font:UIFont = UIFont.boldSystemFontOfSize(14.0)
        
        // パラグラフ関連の情報の指定
        let style:NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.Center
        style.lineBreakMode = NSLineBreakMode.ByClipping
        
        let attributes:[String:AnyObject] = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: style,
            NSShadowAttributeName: shadow,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSBackgroundColorAttributeName: UIColor.clearColor()
        ]
        
        // 文字列を描画する
        let nsString:NSString = NSString(string: text)

        var realTextSizeWidth:CGFloat = nsString.sizeWithAttributes(attributes).width
        if realTextSizeWidth <= 0 {
            realTextSizeWidth = 10
        }
        
        // 描画するサイズ
        let size:CGSize = CGSizeMake(realTextSizeWidth*2, 18) // realTextSize
        
        // ビットマップ形式のグラフィックスコンテキストの生成
        // 第2引数のopaqueを`NO`にすることで背景が透明になる
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        UIColor(red: self.randomColorNumber(),green:self.randomColorNumber(), blue:self.randomColorNumber(),alpha:1.0).setFill()
        let bounds:CGRect = CGRectMake(0, 0, size.width, size.height)
        UIRectFill(bounds)
        
        
        nsString.drawInRect(CGRectMake(0, 0, size.width, size.height), withAttributes:attributes)
        
        // 現在のグラフィックスコンテキストの画像を取得する
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 現在のグラフィックスコンテキストへの編集を終了
        // (スタックの先頭から削除する)
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    func randomText() -> String {
        let random = Int(arc4random() % 10) * 2
        return self.randomStringWithLength(random) as String
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // ゲームループ
    func update(displayLink: CADisplayLink) {
        // Game loop logic here.

        if (self.microphoneVolumeLevelMeter != nil) {
            self.microphoneVolumeLevelMeter!.update()
            print(self.microphoneVolumeLevelMeter!.average())

            // 息を吹きかけたときにboxを一気に移動させる
            // 0が最大、最小は-160
            if (self.microphoneVolumeLevelMeter!.average() > -4
                && self.microphoneVolumeLevelMeter!.average() < -1) {
                
                //self.microphoneVolumeLevelMeter!.stop()
                //self.microphoneVolumeLevelMeter = nil
                    
                // 全てのboxを一気に移動させる
                if (self.scnView.scene != nil) {
                    for targetNode in self.scnView.scene!.rootNode.childNodes {
                        if targetNode.geometry is SCNBox && targetNode.name == "box" {
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),{
                                // nodeを移動させる
                                // 移動方向、移動先
                                targetNode.physicsBody?.applyForce(SCNVector3Make(-Float(10.0), 0, 0), atPosition: SCNVector3Make(-Float(10.0), -Float(5.0), 0), impulse: true)
                                
                            })
                            
                        }
                        
                    }
                }

            }
        }

        
        // 一定量以上、左に見切れたboxは削除する
        if (self.scnView.scene != nil) {
            for targetNode in self.scnView.scene!.rootNode.childNodes {
                if targetNode.geometry is SCNBox && targetNode.name == "box" && targetNode.presentationNode.position.x <= -45.0 {
                    targetNode.removeFromParentNode()
                    NSLog("deleted %f", targetNode.presentationNode.position.x)
                }
                
            }
        }
/**/
        // 端末向きを取得する
        let orientation:UIDeviceOrientation = UIDevice.currentDevice().orientation
        switch (orientation) {
            case UIDeviceOrientation.PortraitUpsideDown:
                
                if (self.microphoneVolumeLevelMeter == nil || self.microphoneVolumeLevelMeter!.recording() == false) {
                    self.microphoneVolumeLevelMeter = MicrophoneVolumeLevelMeter()
                    self.microphoneVolumeLevelMeter!.start()
                }
                
                break
            default:
                if (self.microphoneVolumeLevelMeter != nil && self.microphoneVolumeLevelMeter!.recording() == true) {
                    
                    self.microphoneVolumeLevelMeter!.stop()
                    //self.microphoneVolumeLevelMeter = nil
                }
                break
        }
/**/
    }
    
    @IBAction func tapButton(sender: AnyObject) {
//        self.playThru = RemoteIOPlayThru()
//        self.playThru!.play()

//        self.microphoneController = MicrophoneController()
//        do {
//            try self.microphoneController!.start()
//        } catch {
//            
//        }
        
        self.microphoneVolumeLevelMeter = MicrophoneVolumeLevelMeter()
        self.microphoneVolumeLevelMeter!.start()
    }
}
