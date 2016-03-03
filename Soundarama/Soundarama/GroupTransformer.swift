//
//  GroupTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 02/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct GroupCreationRecord {
    
    let groupID: GroupID
    let sourcePerformers: Set<Performer>
    let sourceGroupIDs: Set<GroupID>
}

class GroupTransformer {
    
    static func transform(fromGroups: Set<Group>, toGroups: Set<Group>) -> (created: [GroupCreationRecord], destroyed: Set<Group>) {
        
        var created: [GroupCreationRecord] = []
        var destroyed: Set<Group> = Set()
        
        for g in toGroups {
            
            let from_performers = fromGroups.reduce(Set()) { i, g in return i.union(g.members)}
            let to_performers = toGroups.reduce(Set()) { i, g in return i.union(g.members)}
            
            let merged_performers = to_performers.subtract(from_performers)
            
            let merged_groupIDs = Set(fromGroups
                .filter({ g2 in  g2.members.intersect(g.members).count != 0})
                .filter({ fromGroups.contains($0) })
                .map({ $0.id()}))
            
            let record = GroupCreationRecord(groupID: g.id(), sourcePerformers: merged_performers, sourceGroupIDs: merged_groupIDs)
            created.append(record)
        }
        
        for g in fromGroups {
            
            let wasMerged = toGroups.filter({ g.members.isSubsetOf($0.members)}).count == 1
            let stillExists = toGroups.contains(g)
            
            if !stillExists && !wasMerged {
                destroyed.insert(g)
            }
        }
        
        return (created: created, destroyed: destroyed)
    }
}