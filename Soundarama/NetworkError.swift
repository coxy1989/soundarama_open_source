//
//  NetworkError.swift
//  Soundarama
//
//  Created by Jamie Cox on 17/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Result
import PromiseK

/* Reachability */

enum WifiReachabilityError: ErrorType {
    
    case ReachabilityFailed
}

/* Discovery */

enum ReceptiveDiscoveryError: ErrorType {
    
    case BroadcastFailed
    
    case ReachabilityFailed
}

enum AssertiveDiscoveryError: ErrorType {
    
    case SearchFailed
    
    case ReachabilityFailed
}

enum BroadcastError: ErrorType {
    
    case BroadcastFailed
}

enum SearchError: ErrorType {
    
    case SearchFailed
}

/* Handshake */

enum ReceptiveHandshakeError: ErrorType {
    
    case AcceptorFailed
    
    case AcceptorDisconnected
    
    case SyncTimeout
}

enum HandshakeError: ErrorType {
    
    case ResolveFailed
    
    case ConnectFailed
    
    case SyncFailed
    
    case Cancelled
}

/* Sync */

enum ChristiansSocketHandlerError {
    
    case Timeout
    
    case ParsingError
}

/* Endpoint */

enum EndpointError: ErrorType {
    
    case Disconnected(Resolvable)
}

