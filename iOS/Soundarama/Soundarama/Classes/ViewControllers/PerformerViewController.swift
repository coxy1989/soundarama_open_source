//
//  PerformerViewController.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class PerformerViewController: UIViewController
{
    private var client = SoundaramaClient()
    
    private var testAudio = AudioController()
    
    private var displayLink: CADisplayLink!
    
    private var clockMap: (local: NSTimeInterval, remote: NSTimeInterval)!
    
    private lazy var connectionLabel: UILabel =
    {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "Not Connected"
        return label
    }()
    
    private lazy var timeLabel: UILabel =
    {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "Waiting for time"
        return label
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        client.delegate = self
        testAudio.setup()
        view.addSubview(connectionLabel)
        view.addSubview(timeLabel)
        view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        client.connect()
    }
    
    override func viewWillLayoutSubviews()
    {
        
        super.viewWillLayoutSubviews()
        
        connectionLabel.sizeToFit()
        connectionLabel.center = view.center
        
        timeLabel.sizeToFit()
        timeLabel.frame.origin = CGPointMake(12, 12)
    }
}

extension PerformerViewController: SoundaramaClientDelegate {
    
    func clientDidConnect()
    {
        connectionLabel.text = "Connected"
    }
    
    func clientDidDisconnect()
    {
        connectionLabel.text = "Not Connected"
    }
    
    func clientDidRecieveMessage(message: Message)
    {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.scheduleSound(message.timestamp, loopLength: message.loopLength)
        }
    }
    
    func clientDidSyncClock(local: NSTimeInterval, remote: NSTimeInterval)
    {
        print("Synced clocks \n  Remote: \(remote) Vs Local: \(local) (diff = \(abs(local - remote)))")
        clockMap = (local: local, remote: remote)
        displayLink = CADisplayLink(target: self, selector: "displayLinkDidFire")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
}

extension PerformerViewController {
    
    
    func displayLinkDidFire()
    {
        let now = NSDate().timeIntervalSince1970
        let elapsedSinceSync = now - clockMap.local
        let remoteNow = clockMap.remote + elapsedSinceSync
        timeLabel.text = String(NSString(format: "%.02f", remoteNow))
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

extension PerformerViewController {
    
    func scheduleSound(timestamp: Double, loopLength: NSTimeInterval)
    {
        testAudio.stop()
        testAudio.setup()
        
        let now = NSDate().timeIntervalSince1970
        let elapsedSinceSync = now - clockMap.local
        let remoteNow = clockMap.remote + elapsedSinceSync
        let nextStartTime = timestamp + 2
        let waitSecs = Double(nextStartTime) - Double(remoteNow)
        let waitNans = waitSecs *  Double(NSEC_PER_SEC)
        print("----- Local Tick ------")
        print("Local + wait: \(now + waitSecs)")
        print("-----------------------")
        
        let expected = now + waitSecs
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(waitNans)), dispatch_get_main_queue()) { [weak self] in
            let nownow = NSDate().timeIntervalSince1970
            print("----- Wait ------")
            print(" Expected: \(expected) \n Actual: \(nownow) \n Diff: \(nownow - expected)")
            print("-----------------")
            self?.view.backgroundColor = UIColor.yellowColor()
            self?.testAudio.start()
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * 1000000000)), dispatch_get_main_queue()) { [weak self] in
                    self?.view.backgroundColor = UIColor.blackColor()
            }
        }
        
    }
}
