//
//  AppDelegate.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var soundarama: Soundarama!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
     
        audioSetup()
        appSetup()
        soundarama = Soundarama.start(UIWindow(frame: UIScreen.mainScreen().bounds))
        
        NSLocale.supportedLanguages = ["en", "fr"]
        
        return true
    }
}

extension AppDelegate {
    
    func audioSetup() {
        
        do { try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: []) }
        catch _ {}
      //  VolumeControl.setVolume(1.0)
    }
    
    func appSetup() {
        
        //UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
}
