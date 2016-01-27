//
//  DJViewController.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit
import Darwin

class ShitDJViewController: UIViewController {
    
    weak var delegate: DJUserInterfaceDelegate!
    
    struct Layout {
        static let deviceTrayWidth: CGFloat = 240
        static let numberOfSoundRows = 3
        static let numberOfSoundColumns = 3
    }
    
    //private let server = SoundaramaServer()
    
    private var deviceTrayView: DeviceTrayView?
    private var soundZoneViews: [SoundZoneView]?
    private var selectedSoundZoneView: SoundZoneView?
    private var performerPhoneImageViews = [String: UIImageView]()
    private var currentPerformerSoundZoneViews = [String: SoundZoneView]() //So we know when we move sounds
    
    override func prefersStatusBarHidden() -> Bool {
        
        return true
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        deviceTrayView = DeviceTrayView()
        view.addSubview(self.deviceTrayView!)
        soundZoneViews = []
        
        for _ in (0..<Layout.numberOfSoundColumns * Layout.numberOfSoundRows) {
            let soundView = SoundZoneView()
          //  soundView.delegate = self
            self.view.addSubview(soundView)
            self.soundZoneViews?.append(soundView)
        }
        
        delegate.ready()
        //self.server.delegate = self
        //server.publishService()
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return [ UIInterfaceOrientationMask.Landscape ]
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        self.deviceTrayView?.frame = CGRect(x: self.view.bounds.width - Layout.deviceTrayWidth, y: 0.0, width: Layout.deviceTrayWidth, height: self.view.bounds.height)
        
        let soundViewArea = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width - Layout.deviceTrayWidth, height: self.view.bounds.height)
        let soundViewSize = CGSize(width: soundViewArea.width / CGFloat(Layout.numberOfSoundColumns), height: soundViewArea.height / CGFloat(Layout.numberOfSoundRows))
        
        for row in 0..<Layout.numberOfSoundRows
        {
            for column in 0..<Layout.numberOfSoundColumns
            {
                if let soundView = self.soundZoneViews?[column + (row * Layout.numberOfSoundColumns)]
                {
                    soundView.frame = CGRect(
                        x: CGFloat(row) * soundViewSize.width,
                        y: CGFloat(column) * soundViewSize.height,
                        width: soundViewSize.width,
                        height: soundViewSize.height
                    )
                }
            }
        }
    }
}

extension ShitDJViewController {
    
    
    func addPerformer(performer: Performer) {
        
        if performerPhoneImageViews[performer] == nil {
            /*
            let imageView = PerformerPhoneImageView(image: UIImage(named: "icn-phone"))
            imageView.alpha = 0.0
            imageView.contentMode = .Center
            imageView.performerID = performer
            
            imageView.sizeToFit()
            imageView.frame = CGRectInset(imageView.bounds, -14.0, -14.0) //extend hit area
            
            imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "didPanPerformerImageView:"))
            imageView.userInteractionEnabled = true
            
            //Random position in devices tray
            let devicesAreaRect = CGRectInset(self.deviceTrayView!.frame, 16.0, 60.0)
            imageView.center = CGPoint(
                x: CGFloat(randomInt(Int(devicesAreaRect.minX), max: Int(devicesAreaRect.maxX))),
                y: CGFloat(randomInt(Int(devicesAreaRect.minY), max: Int(devicesAreaRect.maxY)))
            )
            
            self.view.addSubview(imageView)
            
            self.performerPhoneImageViews[performer] = imageView
            
            UIView.animateWithDuration(0.3, animations: { imageView.alpha = 1.0 })
*/
        }

    }
    
    func removePerformer(performer: Performer) {
        
        if let imageView = performerPhoneImageViews[performer] {
            self.performerPhoneImageViews[performer] = nil
            UIView.animateWithDuration(0.3, animations: {
                imageView.alpha = 0.0
            }){ done in
                imageView.removeFromSuperview()
            }
        }
    }
}

extension ShitDJViewController {
    
    @objc private func didPanPerformerImageView(panGesture: UIPanGestureRecognizer)
    {
        /*
        if let performerImageView = panGesture.view as? PerformerView, performerID = performerImageView.performerID, soundZoneViews = self.soundZoneViews
        {
            //Grow phone when dragging
            if (panGesture.state == .Began)
            {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    
                    performerImageView.transform = CGAffineTransformMakeScale(1.6, 1.6)
                    
                    }, completion: { (finished) -> Void in
                        
                })
            }
            else if (panGesture.state == .Changed)
            {
                
            }
            else
            {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    
                    performerImageView.transform = CGAffineTransformIdentity
                    
                    }, completion: { (finished) -> Void in
                        
                })
            }
            
            let previouslyInSoundZone = self.currentPerformerSoundZoneViews[performerID] != nil
            let previousSoundZone = self.currentPerformerSoundZoneViews[performerID]
            
            let translation = panGesture.translationInView(self.view)
            
            performerImageView.center = CGPoint(x: performerImageView.center.x + translation.x, y: performerImageView.center.y + translation.y)
            
            var performerInSoundZone = false
            var newSoundZone: SoundZoneView?
            
            if (panGesture.state != .Began && panGesture.state != .Changed) //Only start new sounds when the user lets go
            {
                for soundZoneView in soundZoneViews
                {
                    if (CGRectContainsPoint(soundZoneView.frame, performerImageView.center))
                    {
                        if (soundZoneView.pointInsideRings(self.view.convertPoint(performerImageView.center, toView: soundZoneView)))
                        {
                            if (self.currentPerformerSoundZoneViews[performerID] != soundZoneView)
                            {
                                print("New sound zone for \(performerID)")
                                self.currentPerformerSoundZoneViews[performerID] = soundZoneView
                                
                                if let audioStem = soundZoneView.audioStem
                                {
                                    delegate.didSelectAudioStemForPerformer(audioStem, performer: performerID)
                                 //   let message = AudioStemMessage(audioStemRef: audioStemRef, timestamp: NSDate().timeIntervalSince1970, sessionStamp: server.sessionStamp, loopLength: 1.875, type: .Start)
                                   // self.server.sendMessage(message, performerAddress: performerID)
                                  //  updatePerformerVolumes()
                                }
                            }
                            
                            performerInSoundZone = true
                            newSoundZone = soundZoneView
                            
                            break
                        }
                    }
                }
            }
            
            //If the performer isn't in a sound zone (or an empty one), but was previously, send stop message
            if (!performerInSoundZone && previouslyInSoundZone) || ((performerInSoundZone && previouslyInSoundZone) && (newSoundZone!.audioStem == nil))
            {
                if let previousAudioStemRef = previousSoundZone?.audioStem?.reference
                {
                   // let message = AudioStemMessage(audioStemRef: previousAudioStemRef, timestamp: NSDate().timeIntervalSince1970, sessionStamp: server.sessionStamp, loopLength: 1.875, type: .Stop)
                  //  self.server.sendMessage(message, performerAddress: performerID)
                  //  print ("send stop message")
                  //  updatePerformerVolumes()
                }
            }
            
            if (!performerInSoundZone)
            {
                self.currentPerformerSoundZoneViews[performerID] = nil
            }
            
            panGesture.setTranslation(CGPoint.zero, inView: self.view)
        }
*/
    }

}


extension ShitDJViewController
{
    func soundZoneViewDidPressPaylistButton(soundZoneView: SoundZoneView, playlistButton: UIButton)
    {
        presentAudioStemPicker(soundZoneView, button: playlistButton)
    }
    
    func soundZoneViewDidPressMuteButton(soundZoneView: SoundZoneView, button: UIButton)
    {
        //Keep mute state on the button, because 'muted' is also used when soloing...could be improved
        let mute = !button.selected
        button.selected = mute
        
        var isAnotherSoundZoneMuted = false
        if let soundZoneViews = self.soundZoneViews
        {
            isAnotherSoundZoneMuted = soundZoneViews.filter({ $0.isSolo }).count > 0
        }
        
        //Don't want to be able to un-mute this, if a different one is mute
        if !isAnotherSoundZoneMuted
        {
      //      soundZoneView.muted = mute
        }
        
        updatePerformerVolumes()
    }
    
    func soundZoneViewDidPressSoloButton(soundZoneView: SoundZoneView, button: UIButton)
    {
        if (soundZoneView.isSolo)
        {
            //If is already solo, turn everything back up
            
            soundZoneView.isSolo = false
            
            if let soundZoneViews = self.soundZoneViews
            {
                for currentSoundZoneView in soundZoneViews where !currentSoundZoneView.muteButton.selected //Keep muted ones muted
                {
         //           currentSoundZoneView.muted = false
                }
            }
        }
        else
        {
            soundZoneView.isSolo = true
          //  soundZoneView.muted = false
            
            if let soundZoneViews = self.soundZoneViews
            {
                for currentSoundZoneView in soundZoneViews where (currentSoundZoneView.audioStem != nil) && (currentSoundZoneView != soundZoneView)
                {
                    currentSoundZoneView.isSolo = false //In case a different one was solo before
            //        currentSoundZoneView.muted = true
                }
            }
        }
        
        updatePerformerVolumes()
    }
    
    private func updatePerformerVolumes()
    {
        for (performerID, _) in self.performerPhoneImageViews
        {
            var volume: Float = 0.0
            
            if let soundZone = self.currentPerformerSoundZoneViews[performerID]
            {
          //      volume = soundZone.muted ? 0.0 : 1.0
            }
            
            //let message = VolumeChangeMessage(volume: volume, timestamp: NSDate().timeIntervalSince1970)
            //self.server.sendMessage(message, performerAddress: performerID)
        }
    }
    
    func soundZoneViewDidPressAddNewStemButton(soundZoneView: SoundZoneView, button: UIButton)
    {
        presentAudioStemPicker(soundZoneView, button: button)
    }
    
    private func presentAudioStemPicker(soundZoneView: SoundZoneView, button: UIButton)
    {
        self.selectedSoundZoneView = soundZoneView
        
        let buttonRectInThisView = self.view.convertRect(button.frame, fromView: button.superview!)
        
        let audioStemsVC = AudioStemsViewController(nibName: nil, bundle: nil)
        audioStemsVC.modalPresentationStyle = .Popover
        audioStemsVC.popoverPresentationController?.sourceRect = buttonRectInThisView
        audioStemsVC.popoverPresentationController?.sourceView = self.view
        audioStemsVC.delegate = self
        self.presentViewController(audioStemsVC, animated: true, completion: nil)
    }

}

extension ShitDJViewController: AudioStemsViewControllerDelegate
{
    func audioStemsViewControllerDidSelectStem(audioStemsVC: AudioStemsViewController, audioStem: AudioStem)
    {
        audioStemsVC.dismissViewControllerAnimated(true, completion: nil)
        
        //Send messages to any performers already in this zone
        if let selectedSoundZoneView = self.selectedSoundZoneView
        {
            selectedSoundZoneView.audioStem = audioStem
            
            if let audioStemRef = selectedSoundZoneView.audioStem?.reference
            {
            //    for (address, soundZone) in self.currentPerformerSoundZoneViews where soundZone == selectedSoundZoneView
              //  {
                   // let message = AudioStemMessage(audioStemRef: audioStemRef, timestamp: NSDate().timeIntervalSince1970, sessionStamp: server.sessionStamp, loopLength: 1.875, type: .Start)
                   // self.server.sendMessage(message, performerAddress: address)
                 //   updatePerformerVolumes()
               // }
            }
        }
    }
}

extension ShitDJViewController: SoundaramaServerDelegate
{
    func soundaramaServerDidConnectToPerformer(soundaramaServer: SoundaramaServer, address: String)
    {
        if performerPhoneImageViews[address] == nil
        {
            /*
            let imageView = PerformerPhoneImageView(image: UIImage(named: "icn-phone"))
            imageView.alpha = 0.0
            imageView.contentMode = .Center
            imageView.performerID = address
            
            imageView.sizeToFit()
            imageView.frame = CGRectInset(imageView.bounds, -14.0, -14.0) //extend hit area
            
            imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "didPanPerformerImageView:"))
            imageView.userInteractionEnabled = true
            
            //Random position in devices tray
            let devicesAreaRect = CGRectInset(self.deviceTrayView!.frame, 16.0, 60.0)
            imageView.center = CGPoint(
                x: CGFloat(randomInt(Int(devicesAreaRect.minX), max: Int(devicesAreaRect.maxX))),
                y: CGFloat(randomInt(Int(devicesAreaRect.minY), max: Int(devicesAreaRect.maxY)))
            )
            
            self.view.addSubview(imageView)
            
            self.performerPhoneImageViews[address] = imageView
            
            UIView.animateWithDuration(0.3, animations: { imageView.alpha = 1.0 })
            */
        }
    }
    
    func soundaramaServerDidDisconnectFromPerformer(soundaramaServer: SoundaramaServer, address: String)
    {
        print("Disconnect \(address)")
        
        if let imageView = performerPhoneImageViews[address]
        {
            self.performerPhoneImageViews[address] = nil
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                imageView.alpha = 0.0
                
                }, completion: { (finished) -> Void in
                    
                    imageView.removeFromSuperview()
                    
            })
        }
    }
}

/*
func randomInt(min: Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}
*/

