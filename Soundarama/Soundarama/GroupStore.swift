//
//  GroupStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

// Will need to know about workspaces to enforce rules

class GroupStore {
    
    var groups: Set<Group> = Set()
    
    func createGroup(performers p: Set<Performer>, groups g: Set<Group>) {
        
        if p.count > 0 && g.count > 0 {
            groups = Set(groups.filter({ x in !g.contains(x) }))
            let members = Set(g.reduce(Set()) { i, n in  i.union(n.members) }).union(p)
            groups.insert(Group(members: members))
        }
        
        else if p.count > 1 {
            self.groups.insert(Group(members: p))
        }
        
        else if g.count > 1 {
            groups = Set(groups.filter({ x in !g.contains(x) }))
            groups.insert(Group(members: g.reduce(Set()) { i, n in  i.union(n.members) }))
        }
    }
}