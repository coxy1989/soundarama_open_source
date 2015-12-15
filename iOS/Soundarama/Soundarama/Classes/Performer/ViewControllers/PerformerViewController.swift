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
    struct Layout
    {
        static let connectedLabelHeight: CGFloat = 60
        static let flvLogoPadding = CGPoint(x: 18, y: 29)
    }
    
    private var client = SoundaramaClient()
    
    private var audioStems = [String: AudioStem]()
    private var audioController = PerformerAudioController()
    private var connected = false
    
    private var displayLink: CADisplayLink!
    
    private var clockMap: (local: NSTimeInterval, remote: NSTimeInterval)!
    private var currentLoopLength: NSTimeInterval = 2
    private var currentSessionStartTime: Double = NSDate().timeIntervalSince1970
    private var currentBarNumber = -1
    
    private lazy var connectionLabel: UILabel =
    {
        let label = UILabel()
        label.textColor = UIColor.blackColor()
        label.text = "Not Connected"
        label.font = UIFont.soundaramaSansSerifBookFont(size: 18)
        label.textAlignment = .Center
        return label
    }()
    
    private var backgroundImageView: UIImageView?
    private lazy var backgroundImages: [UIImage] =
    {
        var images = [UIImage]()
        let numberOfImages = 4
        for i in 1...numberOfImages
        {
            let imageFileName = "glitch-\(i).jpg"
            images.append(UIImage(named: imageFileName)!)
        }
        return images
    }()
    private var backgroundImageIdx = 0
    
    private var flvLogoImageView: UIImageView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.backgroundImageView = UIImageView()
        self.backgroundImageView?.image = self.backgroundImages.first
        self.backgroundImageView?.contentMode = .ScaleAspectFill
        self.backgroundImageIdx = 0
        
        self.flvLogoImageView = UIImageView()
        self.flvLogoImageView?.image = UIImage(named: "icn-flv-logo")
        self.flvLogoImageView?.contentMode = .ScaleAspectFit
        
        let audioStems = JSON.audioStemsFromDisk()
        for audioStem in audioStems
        {
            self.audioStems[audioStem.reference] = audioStem
        }
        
        client.delegate = self
        
        view.addSubview(self.backgroundImageView!)
        view.addSubview(connectionLabel)
        view.addSubview(self.flvLogoImageView!)
        view.backgroundColor = UIColor.blackColor()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return [ UIInterfaceOrientationMask.Portrait ]
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        client.connect()
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        connectionLabel.frame = CGRect(x: 0.0, y: self.view.bounds.height - Layout.connectedLabelHeight, width: self.view.bounds.width, height: Layout.connectedLabelHeight)
        
        flvLogoImageView?.sizeToFit()
        flvLogoImageView?.frame = CGRect(x: Layout.flvLogoPadding.x, y: Layout.flvLogoPadding.y, width: self.view.bounds.width - (Layout.flvLogoPadding.x * 2.0), height: flvLogoImageView!.bounds.height)
        
        self.backgroundImageView?.frame = self.view.bounds
    }
    
    private func progressToNextBackgroundImage()
    {
        self.backgroundImageIdx++
        if (self.backgroundImageIdx > self.backgroundImages.count - 1)
        {
            self.backgroundImageIdx = 0
        }
        
        self.backgroundImageView?.image = self.backgroundImages[self.backgroundImageIdx]
    }
}

extension PerformerViewController: SoundaramaClientDelegate {
    
    func clientDidConnect()
    {
        connectionLabel.text = "Connected"
        self.connected = true
        self.currentBarNumber = -1
    }
    
    func clientDidDisconnect()
    {
        connectionLabel.text = "Not Connected"
        self.audioController.stopAll()
        self.view.backgroundColor = UIColor.blackColor()
        self.connectionLabel.textColor = UIColor.blackColor()
        self.connected = false
        self.currentBarNumber = -1
    }
    
    func clientDidRecieveAudioStemMessage(message: AudioStemMessage)
    {
        if let audioStem = self.audioStems[message.audioStemRef]
        {
            self.view.backgroundColor = audioStem.colour
            self.connectionLabel.textColor = audioStem.colour
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                
                self.scheduleSound(audioStem, timestamp: message.timestamp, sessionStamp:  message.sessionStamp, loopLength: message.loopLength, stop: (message.type == .Stop))
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

extension PerformerViewController
{
    func displayLinkDidFire()
    {
        if (self.connected)
        {
            let now = NSDate().timeIntervalSince1970
            let elapsedSinceSync = now - clockMap.local
            let remoteNow = clockMap.remote + elapsedSinceSync
            let timeElapsedInSession = remoteNow - self.currentSessionStartTime
            let barNumber = Int(timeElapsedInSession / (self.currentLoopLength / 4.0))
            
            if (barNumber != self.currentBarNumber)
            {
                self.currentBarNumber = barNumber
                
                if (self.audioController.isPlaying)
                {
                    progressToNextBackgroundImage()
                }
            }
            
        }
    }
}

extension PerformerViewController
{
    func scheduleSound(audioStem: AudioStem, timestamp: Double, sessionStamp: Double, loopLength: NSTimeInterval, stop: Bool = false)
    {
        currentLoopLength = loopLength
        currentSessionStartTime = sessionStamp
        
        let now = NSDate().timeIntervalSince1970
        
        let elapsedSinceSync = now - clockMap.local
        let remoteNow = clockMap.remote + elapsedSinceSync
    
        // Calculate `nextStartTime` as a value equal to `timestamp` plus an integer multiple of `loopLength`
        // +0.1 is to make sure the audio player has enough time to prepare for playback
        var nextStartTime = sessionStamp
        while nextStartTime < remoteNow + 0.1 {
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
