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
    
    // make lazy?
    var window: UIWindow?
    
    var soundarama: Soundarama!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        audioSetup()
        appSetup()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        soundarama = Soundarama(window: window!, dependencies: SoundaramaDependencies())
        soundarama.start()
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


    /*
    func setupNavigation() {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            self.window?.rootViewController = RootViewController(rootViewController: HomeViewController(nibName: nil, bundle: nil))
        }
        else {
            self.window?.rootViewController = RootViewController(rootViewController: PerformerViewController(nibName: nil, bundle: nil))
        }
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.whiteColor()
    }
    */


/*
class RootViewController: UINavigationController {
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        if let lastVC = self.viewControllers.last {
            if lastVC is HomeViewController {
                return [ UIInterfaceOrientationMask.Landscape, UIInterfaceOrientationMask.Portrait ]
            }
            else if lastVC is PerformerViewController {
                return [ UIInterfaceOrientationMask.Portrait ]
            }
            else if lastVC is DJViewController {
                return [ UIInterfaceOrientationMask.Landscape ]
            }
        }
        
        return [ UIInterfaceOrientationMask.Landscape ]
    }
}
*/
