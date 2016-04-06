//
//  ResolvableStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

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