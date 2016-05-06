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
 
    /* Viper */
    
    weak var performerDJPickerOutput: PerformerDJPickerOutput!
    
    weak var performerInstrumentsOutput: PerformerInstrumentsOutput!
    
    weak var performerReconnectionOutput: PerformerReconnectionOutput!
    
    weak var performerInstructionOutput: PerformerInstructionOutput!
    
    weak var performerFlashingOutput: PerformerFlashingOutput!
    
    /* State */
    
    private let audioStemStore = AudioStemStore()
    
    private var resolvableStore = ResolvableStore()
    
    private var connectionStore = ConnectionStore()
    
    private var discoveryStore = DiscoveryStore()
    
    private var stateMessageStore = StateMessageStore()
    
    private var onboardingStore: PerformerOnboardingStore?
    
    private var compassValueStore: CompassValueStore?
    
    private var flashingStore: FlashingStore?
    
    /* Audio */
    
    private let audioConfig: AudioConfiguration = AudioConfigurationStore.getConfiguration()
    
    private var audioloop: (loop: MultiAudioLoop, paths: Set<TaggedAudioPath>)?

    /* Connection */
    
    private var discovery: AssertiveDiscovery?
    
    private var handshake: Handshake?
    
    private var reshake: Reshake?
    
    private var reactiveEndpoint: ReactiveEndpoint?
    
    /* Instruments */
    
    private var compass: Compass?
    
    private var danceometer: Danceometer?
    

    deinit {
        
        debugPrint("deinit PerformerInteractor")
    }
}

extension PerformerInteractor: PerformerDJPickerInput {
    
    func startDJPickerInput() {
    
        discovery = AssertiveDiscovery()
        
        discovery?.discover(NetworkConfiguration.type, domain: NetworkConfiguration.domain)
            
            .on(next: { [weak self] in
                debugPrint("Discovery event: \($0)")
                self?.updateDJPickerOutputWithDiscoveryEvent($0) })
            
            .on(failed: {e in
                /* TODO: UI */
                debugPrint("Discovery error: \(e)") })
            
            .on(disposed: { debugPrint("Discovery signal disposed") })
            
            .start()
        
        setPerformerDJPickerOutput()
    }
    
    func stopDJPickerInput() {
        
        discovery?.stop()
        resolvableStore.removeAllEnvelopes()
        connectionStore.clearConnectionState()
    }
}

extension PerformerInteractor: PerformerConnectionInput {
    
    func connect(identifier: Int) {
        
        guard let envelope = resolvableStore.getEnvelope(identifier) else {
            
            updateDJPickerOutputWithConnectionEvent(identifier, event: .Failed)
            return
        }
        
        updateDJPickerOutputWithConnectionEvent(identifier, event: .Started)
        
        handshake = Handshake(resolvable: envelope.resolvable)
        
        handshake!.producer()
            
            .on(next: { [weak self] in
                
                debugPrint("Handshake Succeeded")
                self?.onSuccessfulHandshake($0.0, resolvable: envelope.resolvable, time_map: $0.1)
                self?.updateDJPickerOutputWithConnectionEvent(identifier, event: .Succeeded)})
            
            .on(failed: { [weak self] e in
                
                debugPrint("Handshake Failed: \(e)")
                
                switch e {
                    
                    case .SyncFailed(let e): e.disconnect()
                    
                    default: break
                }
                
                self?.updateDJPickerOutputWithConnectionEvent(identifier, event: .Failed)})

            .start()
    }
    
    func cancelConnect() {
        
        handshake?.cancel()
    }
    
    func disconnect() {
        
        reactiveEndpoint?.stop()
        reactiveEndpoint = nil
        reshake?.cancel()
        reshake = nil
    }
}

extension PerformerInteractor: PerformerInstrumentsInput {
    
    func startPerformerInstrumentInput() {
        
        startInstruments()
        performerInstrumentsOutput.setColors(ColorStore.nullColors())
        performerInstrumentsOutput.setCurrentlyPerforming(nil)
        //performerInstrumentsOutput.setCurrentlyPerforming("Mother Fucker")
        //performerInstrumentsOutput.setColors(ColorStore.colors("Bass"))
        
        performerInstrumentsOutput.setChargeActive(false)
        performerInstrumentsOutput.setCompassActive(false)
        compassValueStore = CompassValueStore(interval: 0.5) { v in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                
                self?.performerInstrumentsOutput.setCompassActive(v > 1)
            }
        }
        
        compassValueStore?.start()
    }
    
    func stopPerfromerInstrumentInput() {
        
        compass?.stop()
        compass = nil
        
        danceometer?.stop()
        danceometer = nil
        
        compassValueStore?.stop()
        compassValueStore = nil
        
        audioloop?.loop.stop()
        audioloop = nil
    }
}

extension PerformerInteractor: PerformerInstructionInput {
    
    func startPerformerInstructionInput() {
        
        startOnboardingIfNeeded()
    }
    
    func stopPerformerInstructionInput() {
        
        onboardingStore?.stop()
        onboardingStore = nil
    }
    
    func requestShowInstruction(instruction: PerformerInstruction) {
        
        performerInstructionOutput.showInstruction(instruction)
    }
    
    func requestHideInstruction(instruction: PerformerInstruction) {
        
        onboardingStore?.descheduleInstruction(instruction)
        onboardingStore?.scheduleNextInstruction()
        performerInstructionOutput.hideInstruction()
    }
}

extension PerformerInteractor {
    
    func handleMessage(message: Result<StateMessage, StateMessageSerializationError>, time_map: ChristiansMap) {
        
        switch message {
            
            case .Success(let m):
            
                updateAudioStem(stateMessage: m, time_map: time_map)
            
            
            case .Failure(let e):
            
                debugPrint("Got message with error: \(e)")
        }
    }
    
    func updateAudioStem(stateMessage m: StateMessage, time_map: ChristiansMap) {
        
        /* TODO: refactor this garbage! */
        
        let get_ws: Workspace -> Bool = { $0.performers.contains(m.performer) }
        let prestate = stateMessageStore.getMessage()?.suite.filter(get_ws).first
        let poststate = m.suite.filter(get_ws).first
        stateMessageStore.setMessage(m)
        
        let muteState = poststate == nil ? false : (poststate!.isAntiSolo || poststate!.isMuted)
        
        if (poststate?.isMuted != prestate?.isMuted) || (poststate?.isAntiSolo != prestate?.isAntiSolo) {
         
            debugPrint("Changed mute state: \(muteState)")
            toggleMuteAudio(muteState)
            dispatch_async(dispatch_get_main_queue()) { [weak self] in self?.performerInstrumentsOutput.setMuted(muteState) }
        }
        
        if poststate?.audioStem == prestate?.audioStem {
            
            debugPrint("Audio stem hasn't changed")
            return
        }
        
        if prestate?.audioStem == nil && poststate?.audioStem != nil {
            
            guard let ts = m.referenceTimestamps[poststate!.audioStem!] else {
                
                debugPrint("No reference timestamp, this is a logical error")
                return
            }
            
            debugPrint("Started an audio stem")
            scheduleStartAudio(poststate!.audioStem!, timeMap: time_map, timestamp: m.timestamp, referenceTimestamp: ts, muted: muteState)
            startOnboardingIfNeeded()
            startFlashingOutput(ts)
            
            
            let c = ColorStore.colors(poststate!.audioStem!)
            let n = audioStemStore.audioStem(poststate!.audioStem!)?.name
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                
                self?.performerInstrumentsOutput.setCurrentlyPerforming(n)
                self?.performerInstrumentsOutput.setColors(c)
            }
        }
        
        if prestate?.audioStem != nil  && poststate?.audioStem == nil {
            
            debugPrint("Stopped an audio stem")
            stopAudio()
            stopFlashingOutput()
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                
                self?.performerInstrumentsOutput.setCurrentlyPerforming(nil)
                self?.performerInstrumentsOutput.setColors(ColorStore.nullColors())
            }
        }
        
        if prestate?.audioStem != nil && poststate?.audioStem != nil {
            
            guard let ts = m.referenceTimestamps[poststate!.audioStem!] else {
                
                debugPrint("No reference timestamp, this is a logical error")
                return
            }
            
            debugPrint("Changed audio stem")
            stopAudio()
            scheduleStartAudio(poststate!.audioStem!, timeMap: time_map, timestamp: m.timestamp, referenceTimestamp: ts, muted: muteState)
            
            let c = ColorStore.colors(poststate!.audioStem!)
            let n = audioStemStore.audioStem(poststate!.audioStem!)?.name
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                
                self?.performerInstrumentsOutput.setCurrentlyPerforming(n)
                self?.performerInstrumentsOutput.setColors(c)
            }
        }
    }
}

extension PerformerInteractor {
    
    func onSuccessfulHandshake(endpoint: Endpoint, resolvable: Resolvable, time_map: ChristiansMap) {
        
        reactiveEndpoint = ReactiveEndpoint()
        reactiveEndpoint?.producer(endpoint, resolvable: resolvable)
            .map(StateMessageDeserializer.deserialize)
            .on(failed: handleEndpointError)
            .on(next: { [weak self] msg in  self?.handleMessage(msg, time_map: time_map)})
            .on(disposed: {debugPrint("reactive endpoint signal disposed")})
            .start()
    }
    
    func handleEndpointError(error: EndpointError) {
    
        stopAudio()
        stopFlashingOutput()
        stateMessageStore.flush()
        performerInstrumentsOutput.setColors(ColorStore.nullColors())
        performerInstrumentsOutput.setCurrentlyPerforming(nil)
        performerReconnectionOutput.updateWithReconnectionEvent(.Started)
        
        switch error {
            
            case .Disconnected(let resolvable):
                
                reshake = Reshake(resolvable: resolvable)
                
                reshake?.producer()
                    
                    .on(next: { [weak self] in
                        
                        debugPrint("Successfully reconnected")
                        self?.onSuccessfulHandshake($0.0, resolvable: resolvable, time_map: $0.1)
                        self?.performerReconnectionOutput.updateWithReconnectionEvent(.EndedSucceess)
                    })
                    
                    .on(failed: { [weak self] e in
                        
                        debugPrint("Failed to reconnect: \(e)")
                        self?.performerReconnectionOutput.updateWithReconnectionEvent(.EndedFailure)
                    })
                    
                    .on(disposed: {debugPrint("reshake signal disposed")})
                    
                    .start()
        }
    }
}

extension PerformerInteractor {
    
    private func updateDJPickerOutputWithConnectionEvent(identfier: Int, event: ConnectionEvent) {
        
        switch event {
            
            case .Started: connectionStore.setConnectionState(identfier, connectionState: .Connecting)
            
            case .Succeeded: connectionStore.setConnectionState(identfier, connectionState: .Connected)
            
            case .Failed: connectionStore.clearConnectionState()
        }
        
        setPerformerDJPickerOutput()
    }
    
    private func updateDJPickerOutputWithDiscoveryEvent(event: AssertiveDiscoveryEvent) {
        
        switch event {
            
            case .Found(let envelope): resolvableStore.addEnvelope(envelope)
            
            case .Lost(let envelope): resolvableStore.removeEnvelope(envelope.id)
            
            case .Up: discoveryStore.setIsUp(true)
            
            case .Down: discoveryStore.setIsUp(false)
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
            
            let identifier = this.connectionStore.getConnectionIdentifer().flatMap() { this.resolvableStore.getEnvelope($0)}.flatMap() { UIDJIdentifier(name: $0.name, id: $0.id) }
            let state = this.connectionStore.getConnectionState()
            let identifiers = this.resolvableStore.getEnvelopes().filter() { $0.id != this.connectionStore.getConnectionIdentifer() }.map() { UIDJIdentifier(name: $0.name, id: $0.id) }
            let isReachable = this.discoveryStore.getIsUp()
            
            this.performerDJPickerOutput.set(identifier, state: state, identifiers: identifiers, isReachable: isReachable)
        }
    }
}

extension PerformerInteractor {
    
    
    private func startOnboardingIfNeeded() {
        
        guard onboardingStore == nil else {
            
            return
        }
        
        onboardingStore = PerformerOnboardingStore() { [weak self] in self?.performerInstructionOutput.showInstruction($0) }
        onboardingStore?.scheduleNextInstruction()
    }
}

extension PerformerInteractor {
    
    private func startFlashingOutput(referenceTime: NSTimeInterval) {
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in self?.performerFlashingOutput.startFlashing() }
        
        flashingStore = FlashingStore(referenceTime: referenceTime) { [weak self] opac, dur in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in self?.performerFlashingOutput.flash(opac, duration: dur) }
        }
        
        flashingStore?.start()
    }
    
    private func stopFlashingOutput() {
        
        flashingStore?.stop()
        flashingStore = nil
        performerFlashingOutput.stopFlashing()
    }
}

extension PerformerInteractor {
    
    private func scheduleStartAudio(reference: String, timeMap: ChristiansMap, timestamp: NSTimeInterval, referenceTimestamp: NSTimeInterval, muted: Bool) {
    
        func remoteTime(timeMap: ChristiansMap) -> NSTimeInterval {
            
            let local_now = NSDate().timeIntervalSince1970
            let elapsed = local_now - timeMap.local
            let remote_now = timeMap.remote + elapsed
            return remote_now
        }
        
        let remote_now = remoteTime(timeMap)
        let latency = remote_now - timestamp
        let time_elapsed = timestamp - referenceTimestamp + latency
        let time_modulus = time_elapsed % audioConfig.audioFileLength
        
        startAudio(TaggedAudioPathStore.taggedAudioPaths(reference), afterDelay: 0, atTime: time_modulus, muted: muted)
    }
    
    private func startAudio(paths: Set<TaggedAudioPath>, afterDelay: NSTimeInterval, atTime: NSTimeInterval, muted: Bool) {
        
        audioloop = (MultiAudioLoop(paths: Set(paths.map({$0.path})), length: audioConfig.audioFileLength), paths)
        audioloop?.loop.start(afterDelay: afterDelay, atTime: atTime)
        audioloop?.loop.setMuted(muted)
    }
    
    private func toggleMuteAudio(isMuted: Bool) {
        
        audioloop?.loop.setMuted(isMuted)
    }
    
    func stopAudio() {
        
        audioloop?.loop.stop()
        audioloop = nil
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
            this.compassValueStore?.addValue($0)
            handler($0)
        }
    }
}
