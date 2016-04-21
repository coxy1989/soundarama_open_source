//
//  ConnectionStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class ConnectionStore {
    
    private var lock: NSRecursiveLock = NSRecursiveLock()
    
    private var state: (identifer: Int, connectionState: ConnectionState)?
    
    func clearConnectionState() {
        
        lock.lock()
        state = nil
        lock.unlock()
    }
    
    func setConnectionState(identifer: Int, connectionState: ConnectionState) {
        
        lock.lock()
        state = (identifer: identifer, connectionState: connectionState)
        lock.unlock()
    }
    
    func getConnectionIdentifer() -> Int? {
        
        return state?.identifer
    }
    
    func getConnectionState() -> ConnectionState {
        
        return state?.connectionState ?? .NotConnected
    }
}
