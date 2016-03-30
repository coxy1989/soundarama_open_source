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
    
    private let compass = Compass(locationManager: LocationService.manager)
    
    private let flickometer = Flickometer(accellerometer: Accellerometer(motionManager: MotionService.manager))
    
    private let audioStemStore = AudioStemStore()
    
    private let levelStore = LevelStore()
    
    private let audioConfig: AudioConfiguration = AudioConfigurationStore.getConfiguration()
    
    private var christiansProcess: ChristiansProcess?
    
    private var christiansMap: (remote: NSTimeInterval, local: NSTimeInterval)?
    
    private var audioloop: (loop: MultiAudioLoop, paths: Set<TaggedAudioPath>)?
    
    private var t: BroadcastService!
    
    func start() {
    
        t = BroadcastService.broadcasting(NetworkConfiguration.domain, type: NetworkConfiguration.type, name: "Cocksucker", port: Int32(NetworkConfiguration.port), failure: { _ in
            
        })
        
        //endpoint.connectionDelegate = self
        //endpoint.connect()
        startInstruments()
        performerOutput.setLevel(levelStore.getLevel())
    }
}

extension PerformerInteractor: ConnectableDelegate {
    
    func didConnectToAddress(address: Address) {
        
        performerOutput.setConnectionState(.Connected)
        christiansProcess = ChristiansProcess(endpoint: endpoint)
        christiansProcess!.delegate = self
        christiansProcess!.syncronise()
    }
    
    func didDisconnectFromAddress(address: Address) {
     
        performerOutput.setConnectionState(.NotConnected)
    }
}

extension PerformerInteractor: ChristiansProcessDelegate {
    
    func christiansProcessDidSynchronise(local: NSTimeInterval, remote: NSTimeInterval) {
    
        christiansMap = (local: local, remote: remote)
        debugPrint(christiansMap)
        endpoint.readData(Serialisation.terminator)
        
        endpoint.readableDelegate = self
    }
}

extension PerformerInteractor: ReadableDelegate {
    
    func didReadData(data: NSData, address: Address) {
        
        if let msg = MessageDeserializer.deserialize(data) {
            
            handleMessage(msg)
        }
        
        endpoint.readData(Serialisation.terminator)
    }
}

extension PerformerInteractor {
    
    func handleMessage(message: Message) {
        
        switch message.type {
            
            case .Start:
                
                handleStartMessage(message as! StartMessage)
            
            case .Stop:
                
                handleStopMessage(message as! StopMessage)
            
            case .Mute:
                
                handleMuteMessage(message as! MuteMessage)
            
            case .Unmute:
                
                handleUnmuteMessage(message as! UnmuteMessage)
        }
    }
    
    func handleStartMessage(message: StartMessage) {
        
        let delay = ChristiansCalculator.calculateDelay(christiansMap!.remote, localTime: christiansMap!.local, sessionTimestamp: message.sessionTimestamp, loopLength: audioConfig.loopLength)
        let atTime = ChristiansCalculator.calculateReferenceTime(message.timestamp, referenceTimestamp: message.referenceTimestamp, length: audioConfig.audioFileLength)
        stopAudio(delay)
        startAudio(TaggedAudioPathStore.taggedAudioPaths(message.reference), afterDelay: delay, atTime: atTime + delay, muted: message.muted)
        performerOutput.setColor(audioStemStore.audioStem(message.reference)!.colour)
        controlAudioLoopVolume(compass.getHeading(), level: levelStore.getLevel())
    }
    
    func handleStopMessage(message: StopMessage) {
        
        stopAudio(0)
        performerOutput.setColor(UIColor.lightGrayColor())
    }
    
    func handleMuteMessage(message: MuteMessage) {
        
        toggleMuteAudio(true)
    }
    
    func handleUnmuteMessage(message: UnmuteMessage) {
        
        toggleMuteAudio(false)
    }
}

extension PerformerInteractor {
    
    private func startAudio(paths: Set<TaggedAudioPath>, afterDelay: NSTimeInterval, atTime: NSTimeInterval, muted: Bool) {
        
        audioloop = (MultiAudioLoop(paths: Set(paths.map({$0.path})), length: audioConfig.audioFileLength), paths)
        audioloop?.loop.start(afterDelay: afterDelay, atTime: atTime)
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
