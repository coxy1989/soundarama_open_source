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
    
    private var connectionAdapter: PerformerConnectionAdapter!
    
    private var messageAdapter: ReadableMessageAdapter!
    
    private var christiansProcess: ChristiansProcess?
    
    private var christiansMap: (remote: NSTimeInterval, local: NSTimeInterval)?
    
    private var audioStemStore = AudioStemStore()
    
    private let audioController = PerformerAudioController()
    
    private var players: [AVAudioPlayer] = []
    
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
        
        let delay = calculateDelay(message)
        
        switch message.command {
        case .Start:
            let audioStem = audioStemStore.audioStem(message.reference)!
            stopAudio(delay)
            startAudio(audioStem.audioFilePath, afterDelay: delay, muted: message.muted)
            performerOutput.audioStemDidChange(audioStem)
        case .Stop:
            stopAudio(delay)
            performerOutput.audioStemDidChange(nil)
        case .ToggleMute:
            toggleMuteAudio(message.muted)
        }
    }
}

extension PerformerInteractor {
    
    func startAudio(path: String, afterDelay: NSTimeInterval, muted: Bool) {
        
        do {
            let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path))
            let playTime = player.deviceCurrentTime + afterDelay
            player.playAtTime(playTime)
            player.numberOfLoops = -1
            player.volume = muted ? 0 : 1
            players.append(player)
        } catch {
            print("Error creating AVPlayer")
        }
    }
    
    func stopAudio(afterDelay: NSTimeInterval) {
        
        let plyrs = players
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(afterDelay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            for s in plyrs {
                s.stop()
            }
        }
    }
    
    func toggleMuteAudio(isMuted: Bool) {
        
        let plyrs = players
        for s in plyrs {
            s.volume = isMuted ? 0 : 1
        }
    }
}

extension PerformerInteractor {
    
    func calculateDelay(message: PerformerMessage) -> NSTimeInterval {
        
        let now = NSDate().timeIntervalSince1970
        let elapsed = now - christiansMap!.local
        let remoteNow = christiansMap!.remote + elapsed
        
        // Calculate `nextStartTime` as a value equal to `timestamp` plus an integer multiple of `loopLength`
        // +0.1 is to make sure the audio player has enough time to prepare for playback
        
        var nextStartTime = message.sessionTimestamp
        
        while nextStartTime < remoteNow + 0.1 {
            nextStartTime += message.loopLength
        }
        
        return Double(nextStartTime) - Double(remoteNow)
    }
}

