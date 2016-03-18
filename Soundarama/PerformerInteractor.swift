//
//  PerformerInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import AVFoundation

class PerformerInteractor: PerformerInput {
 
    weak var performerOutput: PerformerOutput!
    
    var endpoint: Endpoint!
    
    let compass = Compass(locationManager: LocationService.manager)
    
    let altimeter = Altitmeter()
    
    private var connectionAdapter: PerformerConnectionAdapter!
    
    private var messageAdapter: ReadableMessageAdapter!
    
    private var christiansProcess: ChristiansProcess?
    
    private var christiansMap: (remote: NSTimeInterval, local: NSTimeInterval)?
    
     private lazy var audioStemStore: AudioStemStore =  { AudioStemStore() } ()
    
    //private var audioloop: AudioLoop?
    
    private var audioloop: (loop: MultiAudioLoop, paths: Set<TaggedAudioPath>)?
    
    func start() {
    
        connectionAdapter = PerformerConnectionAdapter(connection: endpoint)
        connectionAdapter.delegate = self
        endpoint.connect()
        startInstruments()
        
        let paths = TaggedAudioPathStore.taggedAudioPaths("Synth")
        startAudio(paths, afterDelay: 0, muted: false)
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
            
            let audioStem = audioStemStore.audioStem(message.reference)!
            performerOutput.setAudioStem(audioStem)
            
            let paths = TaggedAudioPathStore.taggedAudioPaths(message.reference)
            startAudio(paths, afterDelay: delay, muted: message.muted)
            
            //stopAudio(delay)
            //startAudio(audioStem.audioFilePath, afterDelay: delay, muted: message.muted)
            
            //let audioStem = audioStemStore.audioStem(message.reference)!
            //stopAudio(delay)
            //startAudio(audioStem.audioFilePath, afterDelay: delay, muted: message.muted)
            //performerOutput.setAudioStem(audioStem)
            
        case .Stop:
            stopAudio(delay)
            performerOutput.setAudioStem(nil)
            
        case .ToggleMute:
            toggleMuteAudio(message.muted)
        }
    }
}


extension PerformerInteractor {
    
    private func startAudio(paths: Set<TaggedAudioPath>, afterDelay: NSTimeInterval, muted: Bool) {
        
        audioloop = (MultiAudioLoop(paths: Set(paths.map({$0.path}))), paths)
        audioloop?.loop.start(afterDelay: afterDelay)
        
        //audioloop = AudioLoop(path: path, delay: afterDelay)
        //audioloop!.start()
    }
    
    private func stopAudio(afterDelay: NSTimeInterval) {
        
        //audioloop?.stop()
        //audioloop = nil
    }
    
    private func toggleMuteAudio(isMuted: Bool) {
        
        //audioloop?.toggleMute(isMuted)
    }
}

extension PerformerInteractor {
    
    private func startInstruments() {
        
        var c: Double?
        var a: Double?
        
        compass.start() { [weak self] x in
            
            c = x
            
            guard a != nil else {
                return
            }
            
            guard self?.audioloop != nil else {
                return
            }
            
            let v = CompassAltitudeVolumeController.calculateVolume(self!.audioloop!.paths, compassValue: c!, altitudeValue: a!)
            v.forEach() { self?.audioloop?.loop.setVolume($0.path, volume: $1) }
        }
        
        altimeter.start() { [weak self] y in
            
            a = y
            guard c != nil else { return }
            
            guard self?.audioloop != nil else {
                return
            }
            
            let v = CompassAltitudeVolumeController.calculateVolume(self!.audioloop!.paths, compassValue: c!, altitudeValue: a!)
            v.forEach() { self?.audioloop?.loop.setVolume($0.path, volume: $1) }
        }
    }
}

extension PerformerInteractor {
    
    /*
    private func startAudio(path: String, afterDelay: NSTimeInterval, muted: Bool) {
        
        //audioloop = AudioLoop(path: path, delay: afterDelay)
        //audioloop!.start()
    }
    
    private func stopAudio(afterDelay: NSTimeInterval) {
        
        //audioloop?.stop()
        //audioloop = nil
    }
    
    private func toggleMuteAudio(isMuted: Bool) {
        
        //audioloop?.toggleMute(isMuted)
    }
*/
}

