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
 
    weak var performerDJPickerOutput: PerformerDJPickerOutput!
    
    weak var performerInstrumentsOutput: PerformerInstrumentsOutput!
    
    private let compass = Compass(locationManager: LocationService.manager)
    
    private let flickometer = Flickometer(accellerometer: Accellerometer(motionManager: MotionService.manager))
    
    private let audioStemStore = AudioStemStore()
    
    private let levelStore = LevelStore()
    
    private let audioConfig: AudioConfiguration = AudioConfigurationStore.getConfiguration()
    
    private var christiansProcess: ChristiansProcess?
    
    private var christiansMap: (remote: NSTimeInterval, local: NSTimeInterval)?
    
    private var audioloop: (loop: MultiAudioLoop, paths: Set<TaggedAudioPath>)?
    
    private var wifiReachability: WiFiReachability!
    
    private var searchService: SearchService?
    
    private var resolvableStore = ResolvableStore()

    private var socketConnector: SocketConnector?
    
    private var endpoint: (String, DisconnectableEndpoint)?
    
    private var connectionState = ConnectionState.NotConnected
    
    func start() {
        
    }
    
    func stop() {
        
        wifiReachability.stop()
        stopNetworkIO()
        audioloop?.loop.stop()
    }
}

extension PerformerInteractor: PerformerDJPickerInput {
    
    func startDJPickerInput() {
        
        let wifi_reachable = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.startNetworkIO()
            this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: true)
            debugPrint("WiFi available")
        }
        
        let wifi_unreachable = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            self?.stopNetworkIO()
            this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: false)
            debugPrint("WiFi unavailable")
        }
        
        let wifi_failure = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: false)
            debugPrint("WiFi monitioring failure")
            return
        }
        
        //performerOutput.setConnectionState(.NotConnected)
        wifiReachability = WiFiReachability.monitoringReachability(wifi_reachable, unreachable: wifi_unreachable, failure: wifi_failure)
    
        performerDJPickerOutput.set(endpoint?.0, state: connectionState, identifiers: availableIdentifiers(), isReachable: wifiReachability.isReachable())
    }
    
    func pickIdentifier(identifier: String) {
        
        let disconnected = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.endpoint = nil
            this.connectionState = .NotConnected
            this.performerDJPickerOutput.set(nil, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability.isReachable())
        }
        
        let connected: (String, DisconnectableEndpoint) -> () = { [weak self] i, e in
            
            guard let this = self else {
                
                return
            }
            
            this.socketConnector = nil
            this.endpoint = (i, e)
            e.onDisconnect(disconnected)
            this.christianSync(e)
        }
        
        
        let resolve_success: (String, UInt16) -> () = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            guard let connector = SocketConnector.connect(identifier, host: $0.0, port: $0.1, connected: connected) else {
                
                this.connectionState = .NotConnected
                this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability.isReachable())
                return
            }
            
            this.resolvableStore.removeResolvable(identifier)
            this.socketConnector = connector
            this.performerDJPickerOutput.set(identifier, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability.isReachable())
        }
        
        let resolve_failure: ([String : NSNumber] -> ()) = {[weak self] _ in
            
            guard let this = self else {
                
                return
            }
            
            this.resolvableStore.removeResolvable(identifier)
            this.connectionState = .NotConnected
            this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability.isReachable())
        }
        
        connectionState = .Connecting
        let resolvable = resolvableStore.getResolvable(identifier)
        resolvable?.resolveWithTimeout(5, success: resolve_success, failure: resolve_failure)
    }
}

extension PerformerInteractor: PerformerInstrumentsInput {
    
    func startPerformerInstrumentInput() {
        
        startInstruments()
        performerInstrumentsOutput.setLevel(levelStore.getLevel())
    }
}

extension PerformerInteractor {
    
    func startNetworkIO() {
        
        let found: (String, Resolvable) -> () = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.resolvableStore.addResolvable($0)
            this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability.isReachable())
        }
        
        let lost: (String, Resolvable) -> () = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.resolvableStore.removeResolvable($0.0)
            this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability.isReachable())
        }
        
        let failed: () -> () = { [weak self] in
        
            guard let this = self else {
                
                return
            }
            
            this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability.isReachable())
        }
        
        searchService = SearchService.searching(NetworkConfiguration.type, domain: NetworkConfiguration.domain, found: found, lost: lost, failed: failed)
    }
    
    func stopNetworkIO() {
        
        searchService?.stop()
        endpoint?.1.disconnect()
    }
}

extension PerformerInteractor {
    
    func handleMessage(message: Message) {
        
        debugPrint(message)
        
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
    
    func remoteTime(cmap: ((remote: NSTimeInterval, local: NSTimeInterval))) -> NSTimeInterval {
        
        let local_now = NSDate().timeIntervalSince1970
        let elapsed = local_now - cmap.local
        let remote_now = cmap.remote + elapsed
        return remote_now
    }
    
    func handleStartMessage(message: StartMessage) {
        
        audioloop?.loop.stop()
        audioloop = nil
        
        let remote_now = remoteTime(christiansMap!)
        let latency = remote_now - message.timestamp
        let time_elapsed = message.timestamp - message.referenceTimestamp + latency
        let time_modulus = time_elapsed % audioConfig.audioFileLength
        
        
        
        self.startAudio(TaggedAudioPathStore.taggedAudioPaths(message.reference), afterDelay: 0, atTime: time_modulus, muted: message.muted)
        self.performerInstrumentsOutput.setColor(self.audioStemStore.audioStem(message.reference)!.colour)
        self.controlAudioLoopVolume(self.compass.getHeading(), level: self.levelStore.getLevel())
    }
    
    func handleStopMessage(message: StopMessage) {
        
        audioloop?.loop.stop()
        audioloop = nil
        
        performerInstrumentsOutput.setColor(UIColor.lightGrayColor())
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
    
    /*
    private func stopAudioLoop(loop: MultiAudioLoop, afterDelay: NSTimeInterval) {
        
        loop.stop()
        /*
        audioloop?.loop.stop()
        audioloop = nil
         */
    }
    */
    
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
        
        performerInstrumentsOutput.setLevel(levelStore.getLevel())
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
        var first_reading = true
        
        compass.start() { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            guard first_reading == false else {
                
                // The first reading is bullshit.
                first_reading = false
                return
            }
            
            c = $0
            this.performerInstrumentsOutput.setCompassValue($0)
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

extension PerformerInteractor {
    
    func christianSync(endpoint: Endpoint) {
        
        christiansProcess = ChristiansProcess(endpoint: endpoint)
        christiansProcess!.delegate = self
        christiansProcess!.syncronise()
    }
}

extension PerformerInteractor: ChristiansProcessDelegate {
    
    func christiansProcessDidSynchronise(endpoint: Endpoint, local: NSTimeInterval, remote: NSTimeInterval) {
        
        christiansMap = (local: local, remote: remote)
        endpoint.readData(Serialisation.terminator)
        endpoint.readableDelegate = self
        connectionState = .Connected
        performerDJPickerOutput.set(self.endpoint?.0, state: connectionState, identifiers: availableIdentifiers(), isReachable: wifiReachability.isReachable())
        debugPrint(christiansMap)
    }
}

extension PerformerInteractor: ReadableDelegate {
    
    
    func didReadData(data: NSData) {
        
        if let msg = MessageDeserializer.deserialize(data) {
            
            handleMessage(msg)
        }
        
        endpoint?.1.readData(Serialisation.terminator)
    }
    
}

extension PerformerInteractor {
    
    func availableIdentifiers() -> [String] {
        
        guard let connected_name = endpoint?.0 else {
            
            return resolvableStore.identifiers()
        }
        
        return  resolvableStore.identifiers().filter() { $0 != connected_name }
    }
}
