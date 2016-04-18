//
//  ResolvableStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 05/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class ResolvableStore {
    
    private let lock = NSRecursiveLock()
    
    private var resolvables: [String : Resolvable] = [ : ]
    
    func identifiers() -> [String] {
        
        let keys = resolvables.keys
        return keys.count > 0 ? Array(keys) : []
    }
    
    func addResolvable(resolvable: (String, Resolvable)) {
        
        lock.lock()
        resolvables[resolvable.0] = resolvable.1
        lock.unlock()
    }
    
    func removeResolvable(resolvable: String) {
        
        lock.lock()
        resolvables.removeValueForKey(resolvable)
        lock.unlock()
    }
    
    func removeAllResolvables() {
        
        lock.lock()
        resolvables.keys.forEach() { resolvables.removeValueForKey($0) }
        lock.unlock()
    }
    
    func getResolvable(identifer: String) -> Resolvable? {
        
        return resolvables[identifer]
    }
}