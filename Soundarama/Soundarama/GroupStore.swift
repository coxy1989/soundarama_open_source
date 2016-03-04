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
        
        guard performers.count > 1 || groupIDs.count > 1 || performers.count + groupIDs.count == 2 else {
            return false
        }
        
        
        let workspaces_with_a_performer = Set(suite.filter({ $0.performers.intersect(performers).count > 0 }))
        
        if workspaces_with_a_performer.count > 1 {
            return false
        }
        
        let workspaces_not_containing_all_performers = suite.filter({ $0.performers.intersect(performers).count != performers.count })
        
        if workspaces_not_containing_all_performers.count > 0 && workspaces_with_a_performer.count > 0 {
            return false
        }
        
        let groups_to_group = groups.filter({ groupIDs.contains($0.id()) })
        let members_of_groups_to_group = groups_to_group.flatMap({$0.members})
        let workspaces_containing_a_member = suite.filter({ $0.performers.intersect(members_of_groups_to_group).count > 0})
        
        if workspaces_containing_a_member.count > 1 {
            return false
        }
        
        let all_performers_in_workspaces = suite.map({ $0.performers }).flatMap({ $0 })
        let groups_with_members_not_in_a_workspace = groups_to_group.filter({ !$0.members.isSubsetOf(all_performers_in_workspaces)})
        
        if workspaces_containing_a_member.count > 0 && groups_with_members_not_in_a_workspace.count > 0 {
            return false
        }
        
        if workspaces_with_a_performer.count != 0 && groups_with_members_not_in_a_workspace.count > 0 {
            return false
        }
        
        let performers_not_in_a_workspace = performers.filter({  })
        
        if workspaces_containing_a_member.count != 0
        
        return true
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
}