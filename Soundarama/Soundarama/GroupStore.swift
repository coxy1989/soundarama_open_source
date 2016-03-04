//
//  GroupStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

// Will need to know about workspaces to enforce rules

class GroupStore {
    
    var groupingMode = false
    
    var groups: Set<Group> = Set()
    
    func createGroup(performers p: Set<Performer>, groupIDs g: Set<GroupID>) {
        
        if p.count > 0 && g.count > 0 {
            
            let merged = Set(groups.filter({ x in g.contains(x.id()) }))
            groups.subtractInPlace(merged)
            let members = Set(merged.reduce(Set()) { i, n in  i.union(n.members) }).union(p)
            groups.insert(Group(members: members))
        }
        
        else if p.count > 1 {
            
            self.groups.insert(Group(members: p))
        }
        
        else if g.count > 1 {
            
            let merged = Set(groups.filter({ x in g.contains(x.id()) }))
            groups.subtractInPlace(merged)
            let members = Set(merged.reduce(Set()) { i, n in  i.union(n.members) })
            groups.insert(Group(members: members))
        }
    }
    
    func destroyGroup(groupID: GroupID) {
        
        groups = Set(groups.filter() { $0.id() != groupID })
    }
    
    func toggleGroupingMode() {
        
        groupingMode = !groupingMode
    }
}