//
//  AudioController.swift
//  SoundaramaSkiing
//
//  Created by Joseph Thomson on 19/07/2016.
//  Copyright © 2016 Touchpress. All rights reserved.
//

import Foundation
import AVFoundation

class AudioController
{
    let goodAudioPlayer: AVAudioPlayer
    let badAudioPlayer: AVAudioPlayer
    
    var badAmmount: Float = 0
    {
        didSet
        {
            self.badAmmount = min(1.0, max(0.0, self.badAmmount))
            
            self.goodAudioPlayer.volume = 1.0 - self.badAmmount
            self.badAudioPlayer.volume = self.badAmmount / 6
        }
    }
    
    init?(goodFile: String, badFile: String)
    {
        if let goodAudioURL = NSBundle.mainBundle().URLForResource(goodFile, withExtension: "wav"),
               badAudioURL = NSBundle.mainBundle().URLForResource(badFile, withExtension: "wav"),
                goodPlayer = try? AVAudioPlayer(contentsOfURL: goodAudioURL),
                 badPlayer = try? AVAudioPlayer(contentsOfURL: badAudioURL)
        {
            self.goodAudioPlayer = goodPlayer
            self.badAudioPlayer = badPlayer
            self.goodAudioPlayer.numberOfLoops = -1
            self.badAudioPlayer.numberOfLoops = -1
            self.badAudioPlayer.volume = 0.0
        }
        else
        {
            return nil
        }
    }
    
    func play(fromStart playFromStart: Bool = false)
    {
        if playFromStart
        {
            self.goodAudioPlayer.pause()
            self.badAudioPlayer.pause()
            
            self.goodAudioPlayer.currentTime = 0.0
            self.badAudioPlayer.currentTime = 0.0
        }
        
        self.goodAudioPlayer.play()
        self.badAudioPlayer.play()
    }
    
    func pause()
    {
        self.goodAudioPlayer.pause()
        self.badAudioPlayer.pause()
    }
}
