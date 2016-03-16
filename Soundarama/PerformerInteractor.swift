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
    
    private var audioloop: AudioLoop?
    
    func start() {
    
        connectionAdapter = PerformerConnectionAdapter(connection: endpoint)
        connectionAdapter.delegate = self
        endpoint.connect()
        compass.start() { b in print(b) }
        altimeter.start() { a in print(a) }
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
            stopAudio(delay)
            //startAudio(audioStem.audioFilePath, afterDelay: delay, muted: message.muted)
            performerOutput.setAudioStem(audioStem)
            
        case .Stop:
            stopAudio(delay)
            performerOutput.setAudioStem(nil)
            
        case .ToggleMute:
            toggleMuteAudio(message.muted)
        }
    }
}

extension PerformerInteractor {
    
    private func startAudio(path: String, afterDelay: NSTimeInterval, muted: Bool) {
        
        audioloop = AudioLoop(path: path, delay: afterDelay)
        audioloop!.start()
    }
    
    private func stopAudio(afterDelay: NSTimeInterval) {
        
        audioloop?.stop()
        audioloop = nil
    }
    
    private func toggleMuteAudio(isMuted: Bool) {
        
        audioloop?.toggleMute(isMuted)
    }
}

