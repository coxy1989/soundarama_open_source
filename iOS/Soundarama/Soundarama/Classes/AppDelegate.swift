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
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        //Ignore mute switch and set to 80% volume
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
        }
        catch _
        {
            
        }
        
        VolumeControl.setVolume(0.8)
        
        //Hide status bar and don't allow device sleep
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
        {
            self.window?.rootViewController = RootViewController(rootViewController: HomeViewController(nibName: nil, bundle: nil))
        }
        else
        {
            self.window?.rootViewController = RootViewController(rootViewController: PerformerViewController(nibName: nil, bundle: nil))
        }
        
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.whiteColor()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

class RootViewController: UINavigationController
{
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        if let lastVC = self.viewControllers.last
        {
            if lastVC is HomeViewController
            {
                return [ UIInterfaceOrientationMask.Landscape, UIInterfaceOrientationMask.Portrait ]
            }
            else if lastVC is PerformerViewController
            {
                return [ UIInterfaceOrientationMask.Portrait ]
            }
            else if lastVC is DJViewController
            {
                return [ UIInterfaceOrientationMask.Landscape ]
            }
        }
        
        return [ UIInterfaceOrientationMask.Landscape ]
    }
}
