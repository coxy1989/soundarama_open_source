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
        
        let all_performers_in_suite = suite.flatMap({$0.performers})
        
        let no_workspace = all_performers.subtract(Set(all_performers_in_suite))
        
        let different_workspaces = suite.filter({ $0.performers.intersect(all_performers).count > 0 })
        
        if no_workspace.count > 0 && different_workspaces.count > 0 {
            
            return false
        }
        
        return (different_workspaces.count < 2)
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
