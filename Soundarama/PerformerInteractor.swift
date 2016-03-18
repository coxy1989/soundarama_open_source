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
    
    private var audioloop: (loop: MultiAudioLoop, paths: Set<TaggedAudioPath>)?
    
    func start() {
    
        connectionAdapter = PerformerConnectionAdapter(connection: endpoint)
        connectionAdapter.delegate = self
        endpoint.connect()
        startInstruments()
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
            performerOutput.setAudioStem(audioStemStore.audioStem(message.reference)!)
            
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
    
    private func startInstruments() {
        
        var c: Double?
        var a: Double?
        
        compass.start() { [weak self] x in
            
            c = x
            self?.controlAudioLoopVolume(c, altitudeValue: a)
        }
        
        altimeter.start() { [weak self] y in
            
            a = y
            self?.controlAudioLoopVolume(c, altitudeValue: a)
        }
    }
    
    func controlAudioLoopVolume(compassValue: Double?, altitudeValue: Double?) {
        
        guard let a = altitudeValue, c = compassValue, al = audioloop else {
            
            return
        }
        
        let v = CompassAltitudeVolumeController.calculateVolume(al.paths, compassValue: c, altitudeValue: a)
        v.forEach() { al.loop.setVolume($0.path, volume: $1) }
    }
}
