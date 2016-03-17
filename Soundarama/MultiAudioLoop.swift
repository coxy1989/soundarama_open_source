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
    
    init(paths: Set<String>) {
        
        paths.forEach() { volume_map[$0] = 0 }
    }
    
    func start(afterDelay delay: NSTimeInterval) {
        
        let player = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: Array(volume_map.keys).head))
        let playtime = player.deviceCurrentTime + delay
        
        volume_map.forEach { p, v in
            
            let player = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: p))
            player.volume = v
            player.playAtTime(playtime)
            current_players_map[p] = player
            loop(player, path: p, playtime: playtime)
        }
    }
    
    func loop(player: AVAudioPlayer, path: String, playtime: NSTimeInterval) {
        
        let scheduledPlayer = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path))
        scheduledPlayer.volume = player.volume
        let scheduledPlaytime = playtime + 15.0
        scheduledPlayer.playAtTime(scheduledPlaytime)
        scheduled_players_map[path] = scheduledPlayer
        
        let looptime = dispatch_time(DISPATCH_TIME_NOW, Int64(15.0 * Double(NSEC_PER_SEC)))
        dispatch_after(looptime, dispatch_get_main_queue()) { [weak self] in
            
            self?.scheduled_players_map[path] = nil
            self?.current_players_map[path] = scheduledPlayer
            self?.loop(scheduledPlayer, path: path, playtime: scheduledPlaytime)
        }
    }
    
    func setVolume(path: String, volume: Float) {
        
        current_players_map[path]?.volume = volume
        scheduled_players_map[path]?.volume = volume
        volume_map[path] = volume
    }
}

/*
class MultiAudioLoop {
    
    private var pathVolumeMap: [String : Float]
    
    private var currentPlayerMap: [String : AVAudioPlayer] = [ : ]
    
    private var scheduledPlayerMap: [String : AVAudioPlayer] = [ : ]
    
    private var volume = 0
    
    init(pathVolumeMap: [String : Float]) {
        
        self.pathVolumeMap = pathVolumeMap
    }
    
    func start(afterDelay delay: NSTimeInterval) {
        
        let player = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: Array(pathVolumeMap.keys).head))
        let playtime = player.deviceCurrentTime + delay
        
        pathVolumeMap.forEach {
        
            let player = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: $0.0))
            player.volume = $0.1
            player.playAtTime(playtime)
            currentPlayerMap[$0.0] = player
            loop(player, path: $0.0, playtime: playtime)
        }
    }
    
    func loop(player: AVAudioPlayer, path: String, playtime: NSTimeInterval) {
        
        let scheduledPlayer = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path))
        scheduledPlayer.volume = player.volume
        let scheduledPlaytime = playtime + 15.0
        scheduledPlayer.playAtTime(scheduledPlaytime)
        scheduledPlayerMap[path] = scheduledPlayer
        
        let looptime = dispatch_time(DISPATCH_TIME_NOW, Int64(15.0 * Double(NSEC_PER_SEC)))
        dispatch_after(looptime, dispatch_get_main_queue()) { [weak self] in
            
            self?.scheduledPlayerMap[path] = nil
            self?.currentPlayerMap[path] = scheduledPlayer
            self?.loop(scheduledPlayer, path: path, playtime: scheduledPlaytime)
        }
    }
    
    func setVolume(path: String, volume: Float) {
        
        currentPlayerMap[path]?.volume = volume
        scheduledPlayerMap[path]?.volume = volume
        pathVolumeMap[path] = volume
    }
    
    //TODO: REMOVE THIS. YOU SHOULD NEVER QUERY THE PLAYER FOR THE VOLUME.
    
    func getVolume(path: String) -> Float {
        
        return pathVolumeMap[path]!
    }
}
*/