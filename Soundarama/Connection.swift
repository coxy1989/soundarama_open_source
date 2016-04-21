//
//  ConnectionState.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

enum ConnectionState {
    
    case Connected
    
    case Connecting
    
    case NotConnected
}

enum ReconnectionEvent {
    
    case Started
    
    case EndedSucceess
    
    case EndedFailure
}

enum ConnectionEvent {
    
    case Started
    
    case Succeeded
    
    case Failed
}