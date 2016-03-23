//
//  PerformerInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import AVFoundation
import UIKit

class PerformerInteractor: PerformerInput {
 
    weak var performerOutput: PerformerOutput!
    
    var endpoint: Endpoint!
    
    let compass = Compass(locationManager: LocationService.manager)
    
    let flickometer = Flickometer(accellerometer: Accellerometer(motionManager: MotionService.manager))
    
    let swishometer = Swishometer(accellerometer: Accellerometer(motionManager: MotionService.manager))
    
    private var connectionAdapter: PerformerConnectionAdapter!
    
    private var messageAdapter: ReadableMessageAdapter!
    
    private var christiansProcess: ChristiansProcess?
    
    private var christiansMap: (remote: NSTimeInterval, local: NSTimeInterval)?
    
    private lazy var audioStemStore: AudioStemStore =  { AudioStemStore() } ()
    
    private var levelStore = LevelStore()
    
    private var audioloop: (loop: MultiAudioLoop, paths: Set<TaggedAudioPath>)?
    
    func start() {
    
        connectionAdapter = PerformerConnectionAdapter(connection: endpoint)
        connectionAdapter.delegate = self
        endpoint.connect()
        startInstruments()
        performerOutput.setLevel(levelStore.getLevel())
        
        startAudio(TaggedAudioPathStore.taggedAudioPaths("Bass"), afterDelay: 0.5, muted: false)
    }
}

extension PerformerInteractor: PerformerConnectionAdapterDelegate {
    
    func performerConnectionStateDidChange(state: ConnectionState) {
        
        performerOutput.setConnectionState(state)
        
        if state == .Connected {
            christiansProcess = ChristiansProcess(endpoint: endpoint)
            christiansProcess!.delegate = self
            christiansProcess!.syncronise()
        }
    }
}

extension PerformerInteractor: ChristiansProcessDelegate {
    
    func christiansProcessDidSynchronise(local: NSTimeInterval, remote: NSTimeInterval) {
    
        christiansMap = (local: local, remote: remote)
        debugPrint(christiansMap)
        messageAdapter = ReadableMessageAdapter(readable: endpoint)
        messageAdapter.delegate = self
        messageAdapter.takeMessages()
    }
}

extension PerformerInteractor: ReadableMessageAdapterDelegate {
    
    func didReceivePerformerMessage(message: PerformerMessage) {
        
        let delay = ChristiansCalculator.calculateDelay(christiansMap!.remote, localTime: christiansMap!.local, sessionTimestamp: message.sessionTimestamp, loopLength: message.loopLength)
        
        switch message.command {
            
        case .Start:
            
            stopAudio(delay)
            startAudio(TaggedAudioPathStore.taggedAudioPaths(message.reference), afterDelay: delay, muted: message.muted)
            performerOutput.setColor(audioStemStore.audioStem(message.reference)!.colour)
            controlAudioLoopVolume(compass.getHeading(), level: levelStore.getLevel())
            
        case .Stop:
            
            stopAudio(delay)
            performerOutput.setColor(UIColor.lightGrayColor())
            
        case .ToggleMute:
            
            toggleMuteAudio(message.muted)
        }
    }
}

extension PerformerInteractor {
    
    private func startAudio(paths: Set<TaggedAudioPath>, afterDelay: NSTimeInterval, muted: Bool) {
        
        audioloop = (MultiAudioLoop(paths: Set(paths.map({$0.path}))), paths)
        audioloop?.loop.start(afterDelay: afterDelay)
        audioloop?.loop.setMuted(muted)
    }
    
    private func stopAudio(afterDelay: NSTimeInterval) {
        
        audioloop?.loop.stop()
        audioloop = nil
    }
    
    private func toggleMuteAudio(isMuted: Bool) {
        
        audioloop?.loop.setMuted(isMuted)
    }
}

extension PerformerInteractor {
    
    func changeLevel(toLevel: Level) {
        
        let prestate = levelStore.getLevel()
        levelStore.setLevel(toLevel)
        let poststate = levelStore.getLevel()
        
        lockLevelStore(2)
        didChangeLevel(prestate, toLevel: poststate)
    }
    
    func didChangeLevel(fromLevel: Level, toLevel: Level) {
        
        guard fromLevel != toLevel else {
            return
        }
        
        performerOutput.setLevel(levelStore.getLevel())
    }
    
    func lockLevelStore(duration: NSTimeInterval) {
        
        levelStore.lock()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((UInt64(duration) * NSEC_PER_SEC))), dispatch_get_main_queue()) { [weak self] in
            
            self?.levelStore.unlock()
        }
    }
}

extension PerformerInteractor {
    
    private func startInstruments() {
        
        var c: Double?
        
        compass.start() { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            c = $0
            this.performerOutput.setCompassValue($0)
            this.controlAudioLoopVolume($0, level: this.levelStore.getLevel())
        }
        
        flickometer.start() { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            switch $0 {
                
                case .Up: this.changeLevel(this.levelStore.getLevel().levelUp())
                
                case .Down: this.changeLevel(this.levelStore.getLevel().levelDown())
            }
            
            this.controlAudioLoopVolume(c, level: this.levelStore.getLevel())
        }
    }
    
    func controlAudioLoopVolume(compasssValue: Double?, level: Level) {
        
        guard let c = compasssValue, al = audioloop else {
            
            return
        }
        
        let v = CompassLevelVolumeController.calculateVolume(al.paths, compassValue: c, level: level)
        v.forEach() { al.loop.setVolume($0.path, volume: $1) }
    }
}
