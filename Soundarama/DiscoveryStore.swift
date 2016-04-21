//
//  DiscoveryStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class DiscoveryStore {
    
    private var isUp = false
    
    private var lock: NSRecursiveLock = NSRecursiveLock()
    
    func setIsUp(value: Bool) {
        
        lock.lock()
        isUp = value
        lock.unlock()
    }
    
    func getIsUp() -> Bool {
        
        return isUp
    }
}
