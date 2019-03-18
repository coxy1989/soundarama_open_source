//
//  ReeptiveDiscovery.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa

class ReceptiveDiscovery {
    
    private var broadcastService: BroadcastService?
    
    private var wifiReachability: WiFiReachability?
 
    func discover(type: String, domain: String, name: String)  -> SignalProducer<ReceptiveDiscoveryEvent, ReceptiveDiscoveryError>  {
        
        var attempt = 0
        
        let bs = BroadcastService()
        
        wifiReachability = WiFiReachability()
        broadcastService = bs
        
        let retryingBroadcast = bs.broadcast(NetworkConfiguration.domain, type: NetworkConfiguration.type, name: name, port: NetworkConfiguration.port32)
            .flatMapError() { _ in bs.broadcast(NetworkConfiguration.domain, type: NetworkConfiguration.type, name: name + " \(attempt)", port: NetworkConfiguration.port32) }
            .map(broadcastEventToDiscoveryEvent)
            .mapError(broadcastErrorToDiscoveryError)
            .on(failed: { _ in attempt = attempt + 1 }).retry(10)
        
        
        let reach = wifiReachability!.reactiveReachability()
            .map(reachabilityEventToDiscoveryEvent)
            .mapError(reachabilityErrorToDiscoveryError)
        
        return SignalProducer(values: [reach, retryingBroadcast]).flatten(.Merge)
    }
    
    func stop() {
        
        broadcastService?.stop()
        wifiReachability?.stop()
    }
}

private func broadcastEventToDiscoveryEvent(event: BroadcastEvent) -> ReceptiveDiscoveryEvent {
    
    switch event {
        
        case .Up: return ReceptiveDiscoveryEvent.Up
    }
}

private func broadcastErrorToDiscoveryError(error: BroadcastError) -> ReceptiveDiscoveryError {
    
    switch error {
        
        case .BroadcastFailed: return ReceptiveDiscoveryError.BroadcastFailed
    }
}

private func reachabilityEventToDiscoveryEvent(event: WifiReachabilityEvent) -> ReceptiveDiscoveryEvent {
    
    switch event {
        
        case .Reachable: return ReceptiveDiscoveryEvent.Up
        
        case .Unreachable: return ReceptiveDiscoveryEvent.Down
    }
}

private func reachabilityErrorToDiscoveryError(error: WifiReachabilityError) -> ReceptiveDiscoveryError {
    
    switch error {
        
        case WifiReachabilityError.ReachabilityFailed: return ReceptiveDiscoveryError.ReachabilityFailed
    }
}
