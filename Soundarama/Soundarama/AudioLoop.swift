//
//  AudioLoop.swift
//  Soundarama
//
//  Created by Jamie Cox on 17/02/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import AVFoundation

class AudioLoop {
    
    private let path: String
    private let delay: NSTimeInterval
    private var currentPlayer: AVAudioPlayer!
    private var scheduledPlayer: AVAudioPlayer!
    
    init(path: String, delay: NSTimeInterval) {
        
        self.path = path
        self.delay = delay
    }
    
    func start() {
        
        do {
            currentPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path))
        } catch {}
        
        guard let player = currentPlayer else {
            debugPrint("AudioLoop: Failed to create auidoPlayer")
            return
        }
        
        let playtime = player.deviceCurrentTime + delay
        player.playAtTime(playtime)
        loop(playtime)
    }
    
    func stop() {
        
        currentPlayer.stop()
        scheduledPlayer.stop()
    }
    
    func toggleMute(isMuted: Bool) {
        
        let v: Float = isMuted ? 0 : 1
        currentPlayer.volume = v
        scheduledPlayer.volume = v
    }
    
    func loop(playtime: NSTimeInterval) {
        
        do {
            scheduledPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path))
        } catch {}
        
        guard let player = scheduledPlayer else {
            debugPrint("AudioLoop: Failed to create auidoPlayer")
            return
        }
        
        let scheduledPlaytime = playtime + currentPlayer.duration
        player.playAtTime(scheduledPlaytime)
        
        let looptime = dispatch_time(DISPATCH_TIME_NOW, Int64(currentPlayer.duration * Double(NSEC_PER_SEC)))
        dispatch_after(looptime, dispatch_get_main_queue()) { [weak self] in
            self?.currentPlayer = self?.scheduledPlayer
            self?.loop(scheduledPlaytime)
        }
    }
}
