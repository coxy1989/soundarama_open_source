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
import PromiseK

class PerformerInteractor {
 
    weak var performerDJPickerOutput: PerformerDJPickerOutput!
    
    weak var performerInstrumentsOutput: PerformerInstrumentsOutput!
    
    private let audioStemStore = AudioStemStore()
    
    private let audioConfig: AudioConfiguration = AudioConfigurationStore.getConfiguration()
    
    private var christiansProcess: ChristiansProcess?
    
    private var audioloop: (loop: MultiAudioLoop, paths: Set<TaggedAudioPath>)?
    
    private var resolvableStore = ResolvableStore()
    
    private var connectionStore = ConnectionStore()

    private var socketConnector: SocketConnector?
    
    private var connectionState = ConnectionState.NotConnected
    
    private var compass: Compass?
    
    private var danceometer: Danceometer?
    
    private var searchService: SearchService?
    
    private var searchReachability: Reachability?
    
    private var reactiveEndpoint: ReactiveEndpoint?
    
    deinit {
        
        debugPrint("Deinit Performer Interactor")
    }
}

extension PerformerInteractor: PerformerDJPickerInput {
    
    func startDJPickerInput() {
    
        searchService = SearchService()
        SearchService.start(searchService!, type: NetworkConfiguration.type, domain: NetworkConfiguration.domain).startWithNext(processDJSearchEvent)
        
        searchReachability = try! Reachability.reachabilityForInternetConnection()
        WiFiReachability2.reachability(searchReachability!).startWithNext(processDJSearchReachability)
        
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
    
    func pickIdentifier(identifier: String) {
        
        guard let resolvable = resolvableStore.getResolvable(identifier) else {
            
            processDJConnectionEvent(identifier, event: .Failed)
            return
        }
        
        processDJConnectionEvent(identifier, event: .Started)
        
        connect(resolvable).map() { [weak self] in
            
            switch $0 {
                
            case .Success(let endpoint, let time_map):
                
                debugPrint("Successfully connected")
                self?.onConnected(endpoint, time_map: time_map)
                self?.processDJConnectionEvent(identifier, event: .Succeeded)
                
            case .Failure(let e):
                
                debugPrint("Failed to connect: \(e)")
                self?.processDJConnectionEvent(identifier, event: .Failed)
            }
        }
    }
    
    func onConnected(endpoint: Endpoint, time_map: ChristiansMap) {
        
        reactiveEndpoint = ReactiveEndpoint(endpoint: endpoint)
        
        ReactiveEndpoint.start(reactiveEndpoint!)
            .on(completed: { debugPrint("endpoint completed") })
            .map(MessageDeserializer.deserialize)
            .startWithNext() { [weak self] in
                
                switch $0 {
                
                    case .Success(let m): self?.handleMessage(m, timeMap: time_map)
                
                    case .Failure(let e): debugPrint("Failed to unarchive message: \(e)")
            }
        }
    }
}

extension PerformerInteractor: PerformerInstrumentsInput {
    
    func startPerformerInstrumentInput() {
        
        startInstruments()
    }
    
    func stopPerfromerInstrumentInput() {
        
        reactiveEndpoint?.stop()
        reactiveEndpoint = nil
        
        compass?.stop()
        compass = nil
        
        danceometer?.stop()
        danceometer = nil
    }
}

extension PerformerInteractor {
    
    func connect(resolvable: Resolvable) -> Promise<Result<(Endpoint, ChristiansMap), ConnectionError>> {
        
        let christiansProcess = ChristiansProcess()
        self.christiansProcess = christiansProcess
        
        let socketConnector = SocketConnector()
        self.socketConnector = socketConnector
        
        return resolvable.resolve()
            .flatMap(){ transformer($0, f: socketConnector.connect) }
            .flatMap(){ transformer($0, f: christiansProcess.syncronise) }
    }
}

extension PerformerInteractor {
    
    private func processDJConnectionEvent(identfier: String, event: ConnectionEvent) {
        
        switch event {
            
            case .Started: connectionStore.setConnectionState(identfier, connectionState: .Connecting)
            
            case .Succeeded: connectionStore.setConnectionState(identfier, connectionState: .Connected)
            
            case .Failed: connectionStore.clearConnectionState()
        }
        
        setPerformerDJPickerOutput()
    }
    
    private func processDJSearchEvent(event: SearchStreamEvent) {
        
        switch event {
            
            case .Found(let name, let resolvable): resolvableStore.addResolvable((name, resolvable))
            
            case .Lost(let name, _): resolvableStore.removeResolvable(name)
        }
        
        setPerformerDJPickerOutput()
    }
    
    private func processDJSearchReachability(isReachable: Bool) {
        
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

extension PerformerInteractor: ReadableDelegate {
    
    func didReadData(data: NSData) {
       
        /*
        if let msg = MessageDeserializer.deserialize(data) {
            
            handleMessage(msg)
        }
        
        endpoint?.1.readData(Serialisation.terminator)
 */
    }
    
}

extension PerformerInteractor {
    
    /*
    func availableIdentifiers() -> [String] {
        
        guard let connected_name = endpoint?.0 else {
            
            return resolvableStore.identifiers()
        }
        
        return  resolvableStore.identifiers().filter() { $0 != connected_name }
    }
 */
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


/*
 func startNetworkIO() {
 
 /*
 let found: (String, Resolvable) -> () = { [weak self] in
 
 guard let this = self else {
 
 return
 }
 
 this.resolvableStore.addResolvable($0)
 this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability?.isReachable() ?? false)
 }
 
 let lost: (String, Resolvable) -> () = { [weak self] in
 
 guard let this = self else {
 
 return
 }
 
 this.resolvableStore.removeResolvable($0.0)
 this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability?.isReachable() ?? false)
 }
 
 let failed: () -> () = { [weak self] in
 
 guard let this = self else {
 
 return
 }
 
 this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.wifiReachability?.isReachable() ?? false)
 }
 */
 
 //   searchService = SearchService.searching(NetworkConfiguration.type, domain: NetworkConfiguration.domain, found: found, lost: lost, failed: failed)
 }
 
 func stopNetworkIO() {
 
 // searchService?.stop()
 //  endpoint?.1.disconnect()
 }
 */

/*
 class DJSearch {
 
 private var reachability: Reachability!
 
 private var service: SearchService!
 
 func search() -> SignalProducer<SearchStreamEvent, NoError> {
 
 let s = SearchService()
 service = s
 
 let r = try! Reachability.reachabilityForInternetConnection()
 reachability = r
 
 try! r.startNotifier()
 
 return  WiFiReachability2.reachability(r)
 .filter() { $0 == true }
 .flatMap(.Latest) { _ in SearchService.start(s, type: NetworkConfiguration.type, domain: NetworkConfiguration.domain) }
 }
 
 func stopSearching() {
 
 // service.stop()
 reachability.stopNotifier()
 }
 }
 */

//djSearch = DJSearch()
//djSearch?.search().startWithNext(processDJSearch)

//SearchService.startx(searchService, type: NetworkConfiguration.type, domain: NetworkConfiguration.domain).startWithNext() { e in debugPrint(e) }

//SearchService.startx(NetworkConfiguration.type, domain: NetworkConfiguration.domain).startWithNext() { e in debugPrint(e) }

/*
 let s = SearchService()
 searchService = s
 
 WiFiReachability2.reachability(reachability)
 .filter() { $0 == true }
 .flatMap(.Latest) { _ in SearchService.startx(s, type: NetworkConfiguration.type, domain: NetworkConfiguration.domain) }
 .startWithNext() { e in debugPrint(e) }
 
 try! reachability.startNotifier()
 */

//djPickerDisposable = WiFiReachability2.reachability()
// .flatMap(.Latest) { r in SearchService.startx(NetworkConfiguration.type, domain: NetworkConfiguration.domain) }
//  .startWithNext() { e in debugPrint(e) }

//djPickerProducer?.startWithNext() { e in debugPrint(e) }
/*
 let wifi_reachable = { [weak self] in
 
 guard let this = self else {
 
 return
 }
 
 this.startDJSearch()
 // this.startNetworkIO()
 this.performerDJPickerOutput.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: true)
 debugPrint("WiFi available")
 }
 
 let wifi_unreachable = { [weak self] in
 
 guard let this = self else {
 
 return
 }
 
 //self?.stopNetworkIO()
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
 
 wifiReachability = WiFiReachability.monitoringReachability(wifi_reachable, unreachable: wifi_unreachable, failure: wifi_failure)
 
 performerDJPickerOutput.set(endpoint?.0, state: connectionState, identifiers: availableIdentifiers(), isReachable: wifiReachability?.isReachable() ?? false)
 */


// wifiReachability?.stop()
//stopNetworkIO()
// stopDJSearch()

//audioloop?.loop.stop()
//audioloop = nil
//wifiReachability = nil

// searchService?.stop()
// reachability.stopNotifier()
//TODO: delete DJPickerStream

//  djSearch?.stopSearching()
//  djSearch = nil



/*
 let disconnected = { [weak self] in
 
 guard let this = self else {
 
 return
 }
 
 this.endpoint = nil
 this.connectionState = .NotConnected
 this.performerDJPickerOutput?.set(nil, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.searchReachability?.isReachable() ?? false)
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
 this.performerDJPickerOutput?.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.searchReachability?.isReachable() ?? false)
 return
 }
 
 this.resolvableStore.removeResolvable(identifier)
 this.socketConnector = connector
 this.performerDJPickerOutput?.set(identifier, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.searchReachability?.isReachable() ?? false)
 }
 
 let resolve_failure: ([String : NSNumber] -> ()) = {[weak self] _ in
 
 guard let this = self else {
 
 return
 }
 
 this.resolvableStore.removeResolvable(identifier)
 this.connectionState = .NotConnected
 this.performerDJPickerOutput?.set(this.endpoint?.0, state: this.connectionState, identifiers: this.availableIdentifiers(), isReachable: this.searchReachability?.isReachable() ?? false)
 }
 */

//resolvable.resolve(5).flatMap {  transformer($0, f: socketConnector.connect) } /* DANGER TODO: Ensure this cannot be called after the promise is released. */
// .flatMap() {  }


/*
 connectionState = .Connecting
 let resolvable = resolvableStore.getResolvable(identifier)
 resolvable?.resolveWithTimeout(5, success: resolve_success, failure: resolve_failure)
 */

/*
 extension PerformerInteractor {
 
 func christianSync(endpoint: Endpoint) {
 
 //christiansProcess = ChristiansProcess(endpoint: endpoint)
 //christiansProcess!.delegate = self
 // christiansProcess!.syncronise()
 }
 }
 
 // HERE -> Create a message signal from the syncronised endpoint.
 
 /*
 extension PerformerInteractor: ChristiansProcessDelegate {
 
 func christiansProcessDidSynchronise(endpoint: Endpoint, local: NSTimeInterval, remote: NSTimeInterval) {
 
 christiansMap = (local: local, remote: remote)
 endpoint.readData(Serialisation.terminator)
 endpoint.readableDelegate = self
 connectionState = .Connected
 performerDJPickerOutput?.set(self.endpoint?.0, state: connectionState, identifiers: availableIdentifiers(), isReachable: searchReachability?.isReachable() ?? false)
 debugPrint(christiansMap)
 }
 }
 */
 
 */
