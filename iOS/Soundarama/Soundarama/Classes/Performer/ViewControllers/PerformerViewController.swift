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
    
    private var backgroundGradientLayer: CAGradientLayer?
    
    private var audioStems = [String: AudioStem]()
    private var audioController = PerformerAudioController()
    
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
        
        self.backgroundGradientLayer = CAGradientLayer()
        self.backgroundGradientLayer?.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.backgroundGradientLayer?.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.addSublayer(self.backgroundGradientLayer!)
        
        let audioStems = JSON.audioStemsFromDisk()
        for audioStem in audioStems
        {
            self.audioStems[audioStem.reference] = audioStem
        }
        
        client.delegate = self
        
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
        
        self.backgroundGradientLayer?.frame = self.view.bounds
        
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
    
    func clientDidRecieveAudioStemMessage(message: AudioStemMessage)
    {
        if let audioStem = self.audioStems[message.audioStemRef]
        {
            self.backgroundGradientLayer?.colors = [ audioStem.colour.CGColor, audioStem.colour.colorWithAlphaComponent(0.4).CGColor ]
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                
                self.scheduleSound(audioStem, timestamp: message.timestamp, loopLength: message.loopLength, stop: (message.type == .Stop))
            }
        }
    }
    
    func clientDidRecieveVolumeChangeMessage(message: VolumeChangeMessage)
    {
        self.audioController.volume = message.volume
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

extension PerformerViewController
{
    func scheduleSound(audioStem: AudioStem, timestamp: Double, loopLength: NSTimeInterval, stop: Bool = false)
    {
        let now = NSDate().timeIntervalSince1970
        
        let elapsedSinceSync = now - clockMap.local
        let remoteNow = clockMap.remote + elapsedSinceSync
    
        // Calculate `nextStartTime` as a value equal to `timestamp` plus an integer multiple of `loopLength`
        var nextStartTime = timestamp
        while nextStartTime < remoteNow {
            nextStartTime += loopLength
        }
        
        let waitSecs = Double(nextStartTime) - Double(remoteNow)
        
        if (stop)
        {
            self.audioController.stopAudioStem(audioStem, afterDelay: waitSecs)
        }
        else
        {
            self.audioController.playAudioStem(audioStem, afterDelay: waitSecs)
        }
    }
}
