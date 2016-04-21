//
//  AssertiveDiscovery.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa
import enum Result.NoError

class ReceptiveDiscovery {
    
    private var broadcastService: BroadcastService?
    
    private var wifiReachability: WiFiReachability?
    
    /*  Next:   .Up || .Down <- (WiFi state)
        Error:  .ReachabilityFailed || .BroadcastFailed <- (WiFi notifier failure || BroadcastService failure) */
    
    func discover(type: String, domain: String, name: String)  -> SignalProducer<ReceptiveDiscoveryEvent, ReceptiveDiscoveryError>  {
        
        let bs = BroadcastService()
        
        broadcastService = bs
        
        wifiReachability = WiFiReachability()
        
        var attempt = 1
        
        let reach = wifiReachability!.reactiveReachability().map() { $0 == true ? ReceptiveDiscoveryEvent.Up : ReceptiveDiscoveryEvent.Down }.mapError() { _ in ReceptiveDiscoveryError.ReachabilityFailed }
        
        let broadcast = broadcastService!.broadcast(NetworkConfiguration.domain, type: NetworkConfiguration.type, name: name, port: NetworkConfiguration.port32).mapError() { _ in ReceptiveDiscoveryError.BroadcastFailed }
        
        let retrybroadcast = broadcast.flatMapError() { _ in
            
            bs.broadcast(NetworkConfiguration.domain, type: NetworkConfiguration.type, name: name + " \(attempt)", port: NetworkConfiguration.port32).mapError() { _ in ReceptiveDiscoveryError.BroadcastFailed }
            }.on(failed: { _ in attempt = attempt + 1 }).retry(5)

        return SignalProducer(values: [reach, retrybroadcast]).flatten(.Merge)
    }
}

class AssertiveDiscovery {
    
    private var searchService: SearchService?
    
    private var wifiReachability: WiFiReachability?
    
    func discover(type: String, domain: String) -> SignalProducer<AssertiveDiscoveryEvent, DiscoveryError> {
        
        wifiReachability = WiFiReachability()
        
        searchService = SearchService()
        
        let search = searchService!.start(NetworkConfiguration.type, domain: NetworkConfiguration.domain).map(searchStreamEventToDiscoveryEvent).promoteErrors(DiscoveryError)
        
        let reach = wifiReachability!.reactiveReachability().map() { $0 == true ? AssertiveDiscoveryEvent.Up : AssertiveDiscoveryEvent.Down }
        
        return SignalProducer(values: [reach, search]).flatten(.Merge)
    }
    
    func stop() {
        
        searchService?.stop()
        wifiReachability?.stop()
    }
}

private func searchStreamEventToDiscoveryEvent(event: SearchStreamEvent) -> AssertiveDiscoveryEvent {
    
    switch event {
        
        case .Found(let v): return AssertiveDiscoveryEvent.Found(v)
        
        case .Lost(let v): return AssertiveDiscoveryEvent.Lost(v)
    }
}

enum AssertiveDiscoveryEvent {
    
    case Found(ResolvableEnvelope)
    
    case Lost(ResolvableEnvelope)
    
    case Up
    
    case Down
}

enum ReceptiveDiscoveryEvent {
    
    case Started
    
    case Up
    
    case Down
}

/*
 broadcast.flatMapError() { _ in
 timer(NetworkConfiguration.reconnectDelay, onScheduler: scheduler)
 .promoteErrors(BroadcastError)
 .flatMap(.Latest) { _ in broadcast}
 }.on(failed: {e in debugPrint("Failed broadcast attempt: \(e)")})
 .flatMap(.Latest) {
 
 }
 .retry(NetworkConfiguration.reconnectAttempts - 1)

 */