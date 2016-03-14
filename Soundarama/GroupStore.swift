//
//  GroupStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class GroupStore {
    
    var groupingMode = false
    
    var groups: Set<Group> = Set()
    
    func isValidGroup(performers: Set<Performer>, groupIDs: Set<GroupID>, inSuite suite: Suite) -> Bool {
        
        guard performers.count + groupIDs.count > 1 else {
        
            return false
        }
        
        let grouped_performers = Set(groups.filter({groupIDs.contains($0.id())}).flatMap({$0.members}))
        
        let all_performers = grouped_performers.union(performers)
        
        let no_workspace = all_performers.filter({ !suite.flatMap({$0.performers}).contains($0) }).count
        
        let different_workspaces = suite.filter({ $0.performers.intersect(all_performers).count > 0 }).count
        
        if no_workspace > 0 && different_workspaces > 0 {
            
            return false
        }
        
        return (different_workspaces < 2)
    }
    
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
    
    func getSize(groupID: GroupID) -> UInt? {
        
        return groups.filter({ $0.id() == groupID }).map({ UInt($0.members.count) }).first
    }
}
