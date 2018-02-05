//
//  PerformerAudioController.swift
//  Soundarama
//
//  Created by Tom Weightman on 10/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

/*
import Foundation
import AVFoundation

class PerformerStemAudioPlayer: AVAudioPlayer {
    
    deinit {
        debugPrint("PerformerStemAudioPlayer dealloc")
    }
}

class PerformerAudioController: NSObject {
    
    var volume: Float = 1.0 {
        
        didSet {
            updateForVolume()
        }
    }
    
    private var audioPlayers = [String: AVAudioPlayer]()
    
    var isPlaying: Bool {
        
        return self.audioPlayers.values.count > 0
    }
    
    
    func playAudio(audioPath: String, afterDelay: NSTimeInterval = 0.0) {
        
        
            do {
                //Stop any other players (may not be perfect timing because we're using dispatch blocks...could be improved)
                let currentAudioPlayers = Array(self.audioPlayers.values)
                self.audioPlayers.removeAll()
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(afterDelay * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                    let _ = currentAudioPlayers.map { $0.stop() }
                })
                
                //Schedule the new one
                let newPlayer = try PerformerStemAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
                let playTime = newPlayer.deviceCurrentTime + afterDelay //Calaulate before preparing to play, which may take some time
                newPlayer.playAtTime(playTime)
                newPlayer.numberOfLoops = -1
                newPlayer.delegate = self
               // self.audioPlayers[audioStem.reference] = newPlayer
                
                updateForVolume()
                
                debugPrint("playAudioStem")
            }
            catch _ as NSError
            {
                
            }
    }
    
    func stopAudioStem(audioStem: AudioStem, afterDelay: NSTimeInterval = 0.0) {
        
        debugPrint("stopAudioStem")
        if let player = self.audioPlayers[audioStem.reference] {
            
            self.audioPlayers[audioStem.reference] = nil
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(afterDelay * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                
                player.stop()
            })
        }
    }
    
    private func updateForVolume() {
        
        for (_, audioPlayer) in self.audioPlayers {
            audioPlayer.volume = self.volume
        }
    }
    
    func stopAll() {
        //Stop any other players (may not be perfect timing because we're using dispatch blocks...could be improved)
        let currentAudioPlayers = Array(self.audioPlayers.values)
        self.audioPlayers.removeAll()
        let _ = currentAudioPlayers.map { $0.stop() }
    }
}

extension PerformerAudioController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        dispatch_async(dispatch_get_main_queue()) {
            for (ref, currentPlayer) in self.audioPlayers {
                if (player == currentPlayer) {
                    self.audioPlayers[ref] = nil
                }
            }
        }
    }
}
 */