//
//  MultiAudioLoop.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import AVFoundation

typealias Path = String

class MultiAudioLoop {
    
    private var volume_map: [Path : Float] = [ : ]
    
    private var current_players_map: [Path : AVAudioPlayer] = [ : ]
    
    private var scheduled_players_map: [Path : AVAudioPlayer] = [ : ]
    
    private var isMuted = false
    
    private let length: NSTimeInterval
    
    init(paths: Set<String>, length: NSTimeInterval) {
        
        self.length = length
        paths.forEach() { volume_map[$0] = 0 }
    }
    
    func start(afterDelay delay: NSTimeInterval, atTime: NSTimeInterval) {
        
        let player = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: Array(volume_map.keys).head))
        let playtime = player.deviceCurrentTime + delay
        player.currentTime = atTime
        player.volume = 0
        
        volume_map.forEach { p, v in
            
            let player = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: p))
            player.currentTime = atTime
            player.volume = 0
            player.playAtTime(playtime)
            current_players_map[p] = player
            loop(player, path: p, playtime: playtime, currentTime: atTime)
        }
    }
    
    func stop() {
        
        current_players_map.values.forEach() { $0.stop() }
        scheduled_players_map.values.forEach() { $0.stop() }
    }
    
    func setMuted(isMuted: Bool) {
        
        self.isMuted = isMuted
        
        if isMuted == true {
            
            current_players_map.values.forEach() { $0.volume = 0 }
            scheduled_players_map.values.forEach() { $0.volume = 0 }
        }
        
        else {
            
            volume_map.forEach() {
                
                current_players_map[$0]?.volume = $1
                scheduled_players_map[$0]?.volume = $1
            }
        }
    }
    
    func setVolume(path: String, volume: Float) {
        
        volume_map[path] = volume
        
        guard isMuted == false else {
            return
        }
        
        current_players_map[path]?.volume = volume
        scheduled_players_map[path]?.volume = volume
    }
}

extension MultiAudioLoop {
    
    private func loop(player: AVAudioPlayer, path: String, playtime: NSTimeInterval, currentTime: NSTimeInterval) {
        
        let scheduledPlayer = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path))
        let scheduledPlaytime = playtime + length - currentTime
        scheduledPlayer.volume = player.volume
        scheduledPlayer.playAtTime(scheduledPlaytime)
        scheduled_players_map[path] = scheduledPlayer
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((length - currentTime) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [weak self] in
            
            self?.scheduled_players_map[path] = nil
            self?.current_players_map[path] = scheduledPlayer
            self?.loop(scheduledPlayer, path: path, playtime: scheduledPlaytime, currentTime: 0)
        }
    }
}
