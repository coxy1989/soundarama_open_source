//
//  PerformerInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import AVFoundation
import UIKit
import ReactiveCocoa
import Result

class PerformerInteractor {
 
    weak var performerDJPickerOutput: PerformerDJPickerOutput!
    
    weak var performerInstrumentsOutput: PerformerInstrumentsOutput!
    
    weak var performerReconnectionOutput: PerformerReconnectionOutput!
    
    private let audioStemStore = AudioStemStore()
    
    private var resolvableStore = ResolvableStore()
    
    private var connectionStore = ConnectionStore()
    
    private let audioConfig: AudioConfiguration = AudioConfigurationStore.getConfiguration()
    
    private var handshake: Handshake?
    
    private var reshake: Reshake?
    
    private var audioloop: (loop: MultiAudioLoop, paths: Set<TaggedAudioPath>)?

    private var connectionState = ConnectionState.NotConnected
    
    private var compass: Compass?
    
    private var danceometer: Danceometer?
    
    private var searchService: SearchService?
    
    private var searchReachability: Reachability?
    
    private var reactiveEndpoint: ReactiveEndpoint?
    
    deinit {
        
        debugPrint("deinit PerformerInteractor")
    }
}

extension PerformerInteractor: PerformerConnectionInput {
    
    func connect(identifier: String) {
        
        guard let resolvable = resolvableStore.getResolvable(identifier) else {
            
            updateDJPickerOutputWithConnectionEvent(identifier, event: .Failed)
            return
        }
        
        updateDJPickerOutputWithConnectionEvent(identifier, event: .Started)
        
        handshake = Handshake(resolvable: resolvable)
        
        handshake!.producer()
            
            .on(next: { [weak self] in
            
            debugPrint("Successfully connected")
            self?.onConnected($0.0, resolvable: resolvable, time_map: $0.1)
            self?.updateDJPickerOutputWithConnectionEvent(identifier, event: .Succeeded)})
            
            .on(failed: { [weak self] e in
                
                debugPrint("Failed to connect: \(e)")
                self?.updateDJPickerOutputWithConnectionEvent(identifier, event: .Failed)})
            
            .start()
    }
    
    func cancelConnect() {
        
        handshake?.cancel()
    }
    
    func disconnect() {
        
        reactiveEndpoint?.stop()
        reactiveEndpoint = nil
        
        // kill reshake
    }
}

extension PerformerInteractor: PerformerDJPickerInput {
    
    func startDJPickerInput() {
    
        searchService = SearchService()
        SearchService.start(searchService!, type: NetworkConfiguration.type, domain: NetworkConfiguration.domain).startWithNext(updateDJPickerOutputWithDJSearchEvent)
        
        searchReachability = try! Reachability.reachabilityForInternetConnection()
        WiFiReachability2.reachability(searchReachability!).startWithNext(updateDJPickerOutpuWithReachabilityState)
        
        setPerformerDJPickerOutput()
    }
    
    func stopDJPickerInput() {
        
        searchService?.stop()
        searchService = nil
        
        searchReachability?.stopNotifier()
        searchReachability = nil
        
        resolvableStore.removeAllResolvables()
        connectionStore.clearConnectionState()
    }
}

extension PerformerInteractor: PerformerInstrumentsInput {
    
    func startPerformerInstrumentInput() {
        
        startInstruments()
    }
    
    func stopPerfromerInstrumentInput() {
        
        compass?.stop()
        compass = nil
        
        danceometer?.stop()
        danceometer = nil
    }
}

extension PerformerInteractor {
    
    func onConnected(endpoint: Endpoint, resolvable: Resolvable, time_map: ChristiansMap) {
        
        reactiveEndpoint = ReactiveEndpoint(endpoint: endpoint)
        
        ReactiveEndpoint.start(reactiveEndpoint!, resolvable: resolvable)
            .on(failed: attemptReconnect)
            .map(MessageDeserializer.deserialize)
            .startWithNext() { [weak self] in
                
                switch $0 {
                    
                    case .Success(let m): self?.handleMessage(m, timeMap: time_map)
                    
                    case .Failure(let e): debugPrint("Failed to unarchive message: \(e)")
                }
        }
    }
    
    func attemptReconnect(error: EndpointError) {
    
        performerReconnectionOutput.updateWithReconnectionEvent(.Started)
        
        switch error {
            
            case .Disconnected(let resolvable):
                
                reshake = Reshake(resolvable: resolvable)
                
                reshake?.producer()
                    
                    .on(next: { [weak self] in
                        
                        debugPrint("Successfully reconnected")
                        self?.onConnected($0.0, resolvable: resolvable, time_map: $0.1)
                        self?.performerReconnectionOutput.updateWithReconnectionEvent(.EndedSucceess)
                    })
                    
                    .on(failed: { [weak self] e in
                        
                        debugPrint("Failed to reconnect: \(e)")
                        self?.performerReconnectionOutput.updateWithReconnectionEvent(.EndedFailure)
                    })
                    
                    .start()
        }
    }
}

extension PerformerInteractor {
    
    private func updateDJPickerOutputWithConnectionEvent(identfier: String, event: ConnectionEvent) {
        
        switch event {
            
            case .Started: connectionStore.setConnectionState(identfier, connectionState: .Connecting)
            
            case .Succeeded: connectionStore.setConnectionState(identfier, connectionState: .Connected)
            
            case .Failed: connectionStore.clearConnectionState()
        }
        
        setPerformerDJPickerOutput()
    }
    
    private func updateDJPickerOutputWithDJSearchEvent(event: SearchStreamEvent) {
        
        switch event {
            
            case .Found(let name, let resolvable): resolvableStore.addResolvable((name, resolvable))
            
            case .Lost(let name, _): resolvableStore.removeResolvable(name)
        }
        
        setPerformerDJPickerOutput()
    }
    
    private func updateDJPickerOutpuWithReachabilityState(isReachable: Bool) {
        
        setPerformerDJPickerOutput()
    }
    
    private func setPerformerDJPickerOutput() {
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            let identifier = this.connectionStore.getConnectionIdentifer()
            let state = this.connectionStore.getConnectionState()
            let identifiers = this.resolvableStore.identifiers().filter() { $0 != this.connectionStore.getConnectionIdentifer() }
            let isReachable = this.searchReachability?.isReachable() ?? false
            
            this.performerDJPickerOutput.set(identifier, state: state, identifiers: identifiers, isReachable: isReachable)
        }
    }
}


extension PerformerInteractor {
    
    func handleMessage(message: Message, timeMap: ChristiansMap) {
        
        switch message.type {
            
            case .Start:
                
                handleStartMessage(message as! StartMessage, timeMap: timeMap)
            
            case .Stop:
                
                handleStopMessage(message as! StopMessage)
            
            case .Mute:
                
                toggleMuteAudio(true)
            
            case .Unmute:
                
                toggleMuteAudio(false)
        }
    }
    
    func remoteTime(timeMap: ChristiansMap) -> NSTimeInterval {
        
        let local_now = NSDate().timeIntervalSince1970
        let elapsed = local_now - timeMap.local
        let remote_now = timeMap.remote + elapsed
        return remote_now
    }
    
    func handleStartMessage(message: StartMessage, timeMap: ChristiansMap) {
        
        /* DO NOT MOVE THESE TWO LINES OR YOU WILL BREAK THE SYNC. */
        audioloop?.loop.stop()
        audioloop = nil
        /*-------------------------------------------------------- */
        
        let remote_now = remoteTime(timeMap)
        let latency = remote_now - message.timestamp
        let time_elapsed = message.timestamp - message.referenceTimestamp + latency
        let time_modulus = time_elapsed % audioConfig.audioFileLength
        
        startAudio(TaggedAudioPathStore.taggedAudioPaths(message.reference), afterDelay: 0, atTime: time_modulus, muted: message.muted)
        performerInstrumentsOutput.setColor(self.audioStemStore.audioStem(message.reference)!.colour)
    }
    
    func handleStopMessage(message: StopMessage) {
        
        audioloop?.loop.stop()
        audioloop = nil
        
        performerInstrumentsOutput.setColor(UIColor.lightGrayColor())
    }
}

extension PerformerInteractor {
    
    private func startAudio(paths: Set<TaggedAudioPath>, afterDelay: NSTimeInterval, atTime: NSTimeInterval, muted: Bool) {
        
        audioloop = (MultiAudioLoop(paths: Set(paths.map({$0.path})), length: audioConfig.audioFileLength), paths)
        audioloop?.loop.start(afterDelay: afterDelay, atTime: atTime)
        audioloop?.loop.setMuted(muted)
    }
    
    private func toggleMuteAudio(isMuted: Bool) {
        
        audioloop?.loop.setMuted(isMuted)
    }
}

extension PerformerInteractor {
    
    private func startInstruments() {
        
        var c: Double?
        startCompass() { c = $0 }
        
        danceometer = Danceometer(accellerometer: Accellerometer(motionManager: MotionService.manager))
        danceometer!.start() { [weak self] in
            
            /* TODO: Refactor this garbage! */
            
            guard let this = self else {
                
                return
            }
            
            this.performerInstrumentsOutput.setCharge($0)
            
            guard let al = this.audioloop else {
                
                return
            }
            
            guard let com = c else {
                
                return
            }
            
            CompassChargeVolumeController.calculateVolume(al.paths, compassValue: com, charge: $0, threshold: 0.7).forEach() {
                
                al.loop.setVolume($0.path, volume: $1)
            }
        }
    }
    
    private func startCompass(handler: Double? -> ()) {
        
        var first_reading = true
        
        compass = Compass(locationManager: LocationService.manager)
        compass!.start() { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            guard first_reading == false else {
                
                // The first reading is bullshit.
                first_reading = false
                return
            }
            
            this.performerInstrumentsOutput.setCompassValue($0)
            handler($0)
        }
    }
}

class ConnectionStore {
    
    private var lock: NSRecursiveLock = NSRecursiveLock()
    
    private var state: (identifer: String, connectionState: ConnectionState)?
    
    func clearConnectionState() {
        
        lock.lock()
        state = nil
        lock.unlock()
    }
    
    func setConnectionState(identifer: String, connectionState: ConnectionState) {
        
        lock.lock()
        state = (identifer: identifer, connectionState: connectionState)
        lock.unlock()
    }
    
    func getConnectionIdentifer() -> String? {
        
        return state?.identifer
    }
    
    func getConnectionState() -> ConnectionState {
        
        return state?.connectionState ?? .NotConnected
    }
}

enum ConnectionEvent {
    
    case Started
    
    case Succeeded
    
    case Failed
}
