//
//  ResolvableStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 05/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class ResolvableStore {
    
    private var resolvables: [String : Resolvable] = [ : ]
    
    func identifiers() -> [String] {
        
        let keys = resolvables.keys
        return keys.count > 0 ? Array(keys) : []
    }
    
    func addResolvable(resolvable: (String, Resolvable)) {
        
        resolvables[resolvable.0] = resolvable.1
    }
    
    func removeResolvable(resolvable: String) {
        
        resolvables.removeValueForKey(resolvable)
    }
    
    func getResolvable(identifer: String) -> Resolvable? {
        
        return resolvables[identifer]
    }
}