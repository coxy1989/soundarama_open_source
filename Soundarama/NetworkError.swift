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

/*
enum ReceptiveHandshakeError: ErrorType {
    
    case AcceptorFailed
    
    case AcceptorDisconnected
    
    case SyncTimeout
    
    case Cancelled
}
 */

enum SocketAcceptorError: ErrorType {
    
    case Failed
    
    case Disconnected
}

enum HandshakeError: ErrorType {
    
    case ResolveFailed
    
    case ConnectFailed
    
    case ResolveCancelled
    
    case ConnectCancelled

    case ReshakeCancelled
    
    case SyncCancelled(Endpoint)
    
    case SyncFailed(Endpoint)
}

/* Sync */

enum ChristiansTimeServerError: ErrorType {
    
    case Timeout(Endpoint)
    
    case Cancelled(Endpoint)
}

/* Endpoint */

enum EndpointError: ErrorType {
    
    case Disconnected(Resolvable)
}

