//
//  GroupTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 02/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct GroupCreationRecord: Hashable {
    
    let groupID: GroupID
    let sourcePerformers: Set<Performer>
    let sourceGroupIDs: Set<GroupID>
    
    var hashValue: Int {
        
        return sourcePerformers.hashValue ^ groupID.hashValue ^ sourceGroupIDs.hashValue
    }
}

func == (lhs: GroupCreationRecord, rhs: GroupCreationRecord) -> Bool {
    
    return lhs.hashValue == rhs.hashValue
}

class GroupTransformer {
    
    static func transform(fromGroups: Set<Group>, toGroups: Set<Group>) -> (created: GroupCreationRecord?, destroyed: Group?) {
        
        guard fromGroups != toGroups else {
            return (created: nil, destroyed: nil)
        }
        
        if let created = toGroups.filter({ !fromGroups.contains($0)}).first {
            
            let from_group_members = fromGroups.reduce(Set()) { return $0.union($1.members) }
            let to_group_members = toGroups.reduce(Set()) { return $0.union($1.members) }
            let source_performers = to_group_members.subtract(from_group_members)
            
            let merged = fromGroups.filter({ !toGroups.contains($0)})
            let source_groupIDs = merged.map({ $0.id() })
            
            return (created: GroupCreationRecord(groupID: created.id(), sourcePerformers: Set(source_performers), sourceGroupIDs: Set(source_groupIDs)), destroyed: nil)
        }
        
        else if let destroyed = fromGroups.filter({ !toGroups.contains($0) }).first {
            
            return (created: nil, destroyed: destroyed)
        }
        
        return (created: nil, destroyed: nil)
        
        /*
        
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
*/
       // return (created: [], destroyed: Set())
    }
}