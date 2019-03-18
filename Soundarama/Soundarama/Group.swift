//
//  Group.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

typealias GroupID = Int

struct Group: Hashable {
    
    let members: Set<Performer>
    
    func id() -> GroupID {
        
        return hashValue
    }
    
    var hashValue: Int {
        
        return members.hashValue
    }
}

func == (lhs: Group, rhs: Group) -> Bool {
    
    return lhs.id() == rhs.id()
}
