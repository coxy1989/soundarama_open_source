//
//  NetworkEvent.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Assertive Discovery */

struct ResolvableEnvelope {
    
    let resolvable: Resolvable
    
    let name: String
    
    let id: Int
}

enum AssertiveDiscoveryEvent {
    
    case Found(ResolvableEnvelope)
    
    case Lost(ResolvableEnvelope)
    
    case Up
    
    case Down
}

enum SearchEvent {
    
    case Found (ResolvableEnvelope)
    
    case Lost (ResolvableEnvelope)
}

/* Receptive Discovery */

enum ReceptiveDiscoveryEvent {
    
    case Up
    
    case Down
}

enum BroadcastEvent {
    
    case Up
}
