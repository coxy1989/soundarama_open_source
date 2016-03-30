//
//  ResolvableStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class ResolvableStore {
    
    private var resolvables: [String : Resolvable] = [ : ]
    
    func identifiers() -> [String] {
        
        return Array(resolvables.keys)
    }
    
    func addResolvable(resolvable: (String, Resolvable)) {
        
        resolvables[resolvable.0] = resolvable.1
    }
    
    func removeResolvable(resolvable: (String, Resolvable)) {
        
        resolvables[resolvable.0] = nil
    }
}
