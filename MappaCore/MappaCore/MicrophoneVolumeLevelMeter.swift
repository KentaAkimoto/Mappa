//
//  MicrophoneVolumeLevelMeter.swift
//  MappaCore
//
//  Created by 秋元　健太 on 2015/11/05.
//  Copyright © 2015年 KentaAkimoto. All rights reserved.
//

import UIKit
import AVFoundation

class MicrophoneVolumeLevelMeter: NSObject, AVAudioRecorderDelegate {

    var recorder:AVAudioRecorder? = nil
    
    /// メータリング開始
    func start() {
        self.setupAudioSessionForRecording()
        self.setupAudioRecorder()
        
        self.recorder!.record()
        
    }
    
    /// メータリング終了
    func stop() {
        if self.recorder!.recording {
            self.recorder!.stop()
        }
    }
    
    func recording() -> Bool {
        return self.recorder!.recording
    }
    
    func update() {
        self.recorder!.updateMeters()
    }
    
    func peak() -> Float {
        return self.recorder!.peakPowerForChannel(0)
    }
    
    func average() -> Float {
        return self.recorder!.averagePowerForChannel(0)
    }
    
    func setupAudioSessionForRecording() {
        /// 録音可能カテゴリに設定する
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch  {
            // エラー処理
            fatalError("カテゴリ設定失敗")
        }
        
        // sessionのアクティブ化
        do {
            try session.setActive(true)
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }
    }
    
    func setupAudioSessionForPlay() {
        /// 再生可能カテゴリに設定する
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryAmbient)
        } catch  {
            // エラー処理
            fatalError("カテゴリ設定失敗")
        }
        
        // sessionのアクティブ化
        do {
            try session.setActive(true)
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }
    }
    
    func setupAudioRecorder() {
        
        // 録音用URLを設定
        let dirURL:NSURL = documentsDirectoryURL()
        let fileName:String = "recording.caf"
        let recordingsURL:NSURL = dirURL.URLByAppendingPathComponent(fileName)
        
        // 録音設定
        let recordSettings:[String: AnyObject] =
        [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 0,
            AVSampleRateKey: 44100.0]
        
        do {
            self.recorder = try AVAudioRecorder(URL: recordingsURL, settings: recordSettings)
            self.recorder!.delegate = self
            self.recorder!.prepareToRecord()
            self.recorder!.meteringEnabled = true
            self.recorder!.updateMeters()
            
        } catch {
            recorder = nil
        }
        
    }
    
    /// DocumentsのURLを取得
    func documentsDirectoryURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        
        if urls.isEmpty {
            //
            fatalError("URLs for directory are empty.")
        }
        
        return urls[0]
    }
    
    /// delegate
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording")
        self.setupAudioSessionForPlay()
    }
}
