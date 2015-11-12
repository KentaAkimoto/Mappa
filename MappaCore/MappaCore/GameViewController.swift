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

class GameViewController: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var avPlayerView: AVPlayerView!
    
    
    let videoUrl:NSURL = NSURL(string: "http://devstreaming.apple.com/videos/wwdc/2015/206v5ce46maax7s/206/hls_vod_mvp.m3u8")!
    var avPlayer:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var playerBackgroundLayer:CALayer? = nil
    var assets:AVURLAsset? = nil
    var playerItem:AVPlayerItem? = nil
    var icloudTimer:NSTimer? = nil
    
    var microphoneVolumeLevelMeter:MicrophoneVolumeLevelMeter? = nil
    
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
        
        self.icloudTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "checkiCloudData", userInfo: nil, repeats: true)

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
        
    }
    
        
    func start() {
        
        // create a new scene
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
        let delay = 20.0 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),{

            let numBox = 300
            let camDistance:CGFloat = 55.0
            // Add box nodes to the scene
            for _ in 0..<numBox {
                let node = SCNNode()
                let rdx:CGFloat = (self.randomCGFloat() * camDistance - camDistance / 2)
                let rdy:CGFloat = self.randomCGFloat() * 300
                let rdz:CGFloat = self.randomCGFloat() * camDistance - camDistance / 2
                node.position = SCNVector3Make(Float(rdx), Float(rdy), Float(rdz))
                let box = SCNBox(width: self.randomCGFloat() * 5.0, height: self.randomCGFloat() * 5.0, length: self.randomCGFloat() * 5.0, chamferRadius: 0.0)
                node.geometry = box
                
                node.geometry?.firstMaterial?.diffuse.contents = self.imageWithString(self.randomText()) //UIColor.blueColor()
                
                let boxShape = SCNPhysicsShape(geometry: box, options: nil)
                let boxBody = SCNPhysicsBody(type: .Dynamic, shape: boxShape)
                
                node.physicsBody = boxBody;
                node.name = "box"
                scene.rootNode.addChildNode(node)
            }

        })
        
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        //scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.clearColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        scnView.addGestureRecognizer(tapGesture)
        
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
        
        scnView.scene!.rootNode.addChildNode(boxGeometoryNode)
    
    }
    
    func randomColorNumber() -> CGFloat {
        let colorNumber:Double = Double(arc4random_uniform(100))
        return CGFloat(colorNumber / 200.0 + 0.5)
    }
    
    
    
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        
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
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                if result.node.geometry is SCNBox && result.node.name == "box" {

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
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
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
            //print(self.microphoneVolumeLevelMeter!.average())

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
                    //NSLog("deleted %f", targetNode.presentationNode.position.x)
                }
                
            }
        }
        
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

    }
    
    @IBAction func tapButton(sender: AnyObject) {
        let storageManager:CloudKitStorageManager = CloudKitStorageManager()
        storageManager.saveRecord()
        
    }
    
    func checkiCloudData() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let storageManager:CloudKitStorageManager = CloudKitStorageManager()
            let fetchComments:[Comment] = storageManager.fetchRecord(NSDate())
            
            
            for comment:Comment in fetchComments {
                
                // 箱
                let numBox = 300
                let camDistance:CGFloat = 55.0
                // Add box nodes to the scene
                for _ in 0..<numBox {
                    let node = SCNNode()
                    let rdx:CGFloat = (self.randomCGFloat() * camDistance - camDistance / 2)
                    let rdy:CGFloat = self.randomCGFloat() * 300
                    let rdz:CGFloat = self.randomCGFloat() * camDistance - camDistance / 2
                    node.position = SCNVector3Make(Float(rdx), Float(rdy), Float(rdz))
                    let box = SCNBox(width: self.randomCGFloat() * 5.0, height: self.randomCGFloat() * 5.0, length: self.randomCGFloat() * 5.0, chamferRadius: 0.0)
                    node.geometry = box
                    node.geometry?.firstMaterial?.diffuse.contents = self.imageWithString(comment.comment)
                    
                    let boxShape = SCNPhysicsShape(geometry: box, options: nil)
                    let boxBody = SCNPhysicsBody(type: .Dynamic, shape: boxShape)
                    
                    node.physicsBody = boxBody;
                    node.name = "box"
                    self.scnView.scene!.rootNode.addChildNode(node)
                }
            }

        })
        
    }
}
