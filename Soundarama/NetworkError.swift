//
//  NetworkError.swift
//  Soundarama
//
//  Created by Jamie Cox on 17/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Result
import PromiseK

enum AssertiveDiscoveryError: ResultErrorType {
    
    case ReachabilityFailed
    
}

enum HandshakeError: ResultErrorType {
    
    case ResolveFailed
    
    case ConnectFailed
    
    case SyncFailed
    
    case Cancelled
}

enum ParsingError: ResultErrorType {
    
    case FailedToUnarchiveJSON
    
    case InvalidJSON
    
    case InvalidStartMessage
    
    case InvalidMessage
}

enum EndpointError: ResultErrorType {
    
    case Disconnected(Resolvable)
}
