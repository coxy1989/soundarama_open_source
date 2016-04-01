//
//  ResolvableStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/*
class ResolvableStore {
    
    private var resolvables: [String : Resolvable] = [ : ]
    
    func identifiers() -> [String] {
        
        let keys = resolvables.keys
        return keys.count > 0 ? Array(keys) : []
    }
    
    func addResolvable(resolvable: (String, Resolvable)) {
        
        resolvables[resolvable.0] = resolvable.1
    }
    
    func removeResolvable(resolvable: (String, Resolvable)) {
        
        resolvables.removeValueForKey(resolvable.0)
    }
}
*/

class BroadcastStore {
    
    private var userBroadcastIdentifier: String?
    
    private var resolvableIdentifiers: Set<String> = Set([])
    
    func getState() -> BroadcastState {
        
        return BroadcastState(userBroadcastIdentifier: userBroadcastIdentifier, resolvableIdentifiers: resolvableIdentifiers)
    }
    
    func addResolvableIdentifier(identifier: String) {
        
        resolvableIdentifiers.insert(identifier)
    }
    
    func removeResolvableIdentifier(identifier: String) {
        
        resolvableIdentifiers.remove(identifier)
    }
    
    func setUserBroadcastIdentifer(identifier: String?) {
     
        userBroadcastIdentifier = identifier
    }
}

struct BroadcastState {
    
    let userBroadcastIdentifier: String?
    
    let resolvableIdentifiers: Set<String>
}