//
//  PerformerInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class PerformerInteractor: PerformerInput {
 
    weak var performerOutput: PerformerOutput!
    
    var endpoint: Endpoint!
    
    private var connectionAdapter: PerformerConnectionAdapter!
    
    private var messageAdapter: ReadableMessageAdapter!
    
    private var christiansProcess: ChristiansProcess?
    
    private var christiansMap: (remote: NSTimeInterval, local: NSTimeInterval)?
    
    private var audioStemStore = AudioStemStore()
    
    private let audioController = PerformerAudioController()
    
    func start() {
        

        
        connectionAdapter = PerformerConnectionAdapter(connection: endpoint)
        connectionAdapter.delegate = self
        endpoint.connect()
    }
}

extension PerformerInteractor: PerformerConnectionAdapterDelegate {
    
    func performerConnectionStateDidChange(state: ConnectionState) {
        
        performerOutput.connectionStateDidChange(state)
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
        print(christiansMap)
        messageAdapter = ReadableMessageAdapter(readable: endpoint)
        messageAdapter.delegate = self
        messageAdapter.takeMessages()
    }
}

extension PerformerInteractor: ReadableMessageAdapterDelegate {
    
    func didReceivePerformerMessage(message: PerformerMessage) {
        
        guard let cmap = christiansMap, stem = audioStemStore.audioStem(message.reference) else {
            return
        }
        
        let now = NSDate().timeIntervalSince1970
        let elapsedSinceSync = now - cmap.local
        let remoteNow = cmap.remote + elapsedSinceSync
        var nextStartTime = message.sessionTimestamp
        
        while nextStartTime < remoteNow + 0.1 {
            nextStartTime += message.loopLength
        }
        
        let waitSecs = Double(nextStartTime) - Double(remoteNow)
        print("Waiting: \(waitSecs)")
        
        if message.command == .Stop {
            print("INTERACTOR: STOP")
            audioController.stopAudioStem(stem, afterDelay: waitSecs)
        }
        else if message.command == .Start {
            print("INTERACTOR: START")
            audioController.playAudioStem(stem, afterDelay: waitSecs)
        }
        
        // TODO: Mute Command
        //TODO: Mute state
        
        performerOutput.audioStemDidChange(stem)
    }
}
