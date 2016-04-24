//
//  AssertiveDiscovery.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa

class AssertiveDiscovery {
    
    private var searchService: SearchService?
    
    private var wifiReachability: WiFiReachability?
    
    func discover(type: String, domain: String) -> SignalProducer<AssertiveDiscoveryEvent, AssertiveDiscoveryError> {
        
        wifiReachability = WiFiReachability()
        
        searchService = SearchService()
        
        let search = searchService!.start(NetworkConfiguration.type, domain: NetworkConfiguration.domain)
            .map(searchEventToDiscoveryEvent)
            .mapError(searchErrorToDiscoveryError)
        
        let reach = wifiReachability!.reactiveReachability()
            .map(reachabilityEventToDiscoveryEvent)
            .mapError(reachabilityErrorToDiscoveryError)
        
        return SignalProducer(values: [reach, search]).flatten(.Merge)
    }
    
    func stop() {
        
        searchService?.stop()
        wifiReachability?.stop()
    }
}

private func searchEventToDiscoveryEvent(event: SearchEvent) -> AssertiveDiscoveryEvent {
    
    switch event {
        
        case .Found(let v): return AssertiveDiscoveryEvent.Found(v)
        
        case .Lost(let v): return AssertiveDiscoveryEvent.Lost(v)
    }
}

private func searchErrorToDiscoveryError(error: SearchError) -> AssertiveDiscoveryError {
    
    switch error {
        
        case .SearchFailed: return AssertiveDiscoveryError.SearchFailed
    }
}

private func reachabilityEventToDiscoveryEvent(event: WifiReachabilityEvent) -> AssertiveDiscoveryEvent {
    
    switch event {
        
        case .Reachable: return AssertiveDiscoveryEvent.Up
        
        case .Unreachable: return AssertiveDiscoveryEvent.Down
    }
}

private func reachabilityErrorToDiscoveryError(error: WifiReachabilityError) -> AssertiveDiscoveryError {
    
    switch error {
        
        case WifiReachabilityError.ReachabilityFailed: return AssertiveDiscoveryError.ReachabilityFailed
    }
}
