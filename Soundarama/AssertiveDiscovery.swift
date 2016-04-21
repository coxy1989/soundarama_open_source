//
//  AssertiveDiscovery.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa

class AssertiveDiscovery {
    
    private let searchService = SearchService()
    
    private var searchReachability = WiFiReachability()
    
    func discover(type: String, domain: String) -> SignalProducer<AssertiveDiscoveryEvent, AssertiveDiscoveryError> {
        
        let reach = searchReachability.reactiveReachability().map() { $0 == true ? AssertiveDiscoveryEvent.Up : AssertiveDiscoveryEvent.Down }
        
        let search = SearchService.start(searchService, type: NetworkConfiguration.type, domain: NetworkConfiguration.domain).map(searchStreamEventToDiscoveryEvent).promoteErrors(AssertiveDiscoveryError)
        
        return SignalProducer(values: [reach, search]).flatten(.Merge)
    }
    
    func stop() {
        
        searchService.stop()
        searchReachability.stop()
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