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
    
    private var audioController = AudioController()
    
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
        audioController.setup()
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
    
    func clientDidRecieveAudioStemStartMessage(message: AudioStemStartMessage)
    {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.scheduleSound(message.timestamp, loopLength: message.loopLength)
        }
    }
    
    func clientDidReceiveAudioStemStopMessage(message: AudioStemStopMessage)
    {
        self.audioController.stop()
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
        audioController.stop()
        audioController.setup()
        
        let now = NSDate().timeIntervalSince1970
        let elapsedSinceSync = now - clockMap.local
        let remoteNow = clockMap.remote + elapsedSinceSync
    
        // Calculate `nextStartTime` as a value equal to `timestamp` plus an integer multiple of `loopLength`
        var nextStartTime = timestamp
        while nextStartTime < remoteNow {
            nextStartTime += loopLength
        }
        
        let waitSecs = Double(nextStartTime) - Double(remoteNow)
        let expected = now + waitSecs
        
        
        // dispatch_time doesn't seem to agree with the system clock so doing this instead.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            while NSDate().timeIntervalSince1970 < expected { /* wait */ }
            dispatch_async(dispatch_get_main_queue()) {
                self.audioController.start()
            }
        }
        
    }
}
