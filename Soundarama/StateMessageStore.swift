//
//  StateMessageStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 04/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class StateMessageStore {
    
    private let lock = NSRecursiveLock()
    
    private var stateMessage: StateMessage?
    
    func setMessage(message: StateMessage) {
        
        lock.lock()
        self.stateMessage = message
        lock.unlock()
    }
    
    func getMessage() -> StateMessage? {
        
        return stateMessage
    }
    
    func flush() {
        
        lock.lock()
        self.stateMessage = nil
        lock.unlock()
    }
}
