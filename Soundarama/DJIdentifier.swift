//
//  DJIdentifier.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct UIDJIdentifier: Hashable {
    
    let name: String
    
    let id: Int
    
    var hashValue: Int {
        
        return id
    }
}

func == (lhs: UIDJIdentifier, rhs: UIDJIdentifier) -> Bool {
    
    return lhs.id == rhs.id
}