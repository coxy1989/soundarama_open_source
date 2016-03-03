//
//  DJInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class DJInteractor {
    
    weak var djOutput: DJOutput!
    
    var endpoint: Endpoint!
    
    private let suiteStore = SuiteStore(number: UIDevice.isPad() ? 9 : 4)
    
    private let groupStore = GroupStore()
    
    private var adapter: WritableMessageAdapter!
    
    private var christiansTimeServer: ChristiansTimeServer!
    
    private var audioStemStore = AudioStemStore()
}

extension DJInteractor: DJInput {
    
    func start() {
        
        //TODO: handle pro (16), pad(9) phone(4)
        
        djOutput.setUISuite(UISuiteTransformer.transform(suiteStore.suite))
        djOutput.setAudioStems(audioStemStore.audioStems)
        djOutput.setGroupingMode(false)
        
        christiansTimeServer = ChristiansTimeServer(endpoint: endpoint)
        adapter = WritableMessageAdapter(writeable: endpoint)
        
        endpoint.connectionDelegate = self
        endpoint.connect()
    }
    
    func stop() {
        
        endpoint.disconnect()
        
    }
    
    func requestToggleMuteInWorkspace(workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.toggleMute(workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate))
    }
    
    func requestToggleSoloInWorkspace(workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.toggleSolo(workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate))
    }
    
    func requestAudioStemInWorkspace(audioStem: AudioStem, workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.setAudioStem(audioStem, workspaceID: workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate))
    }
    
    func requestMovePerformer(performer: Performer, translation: CGPoint) {
        
        djOutput.movePerformer(performer, translation: translation)
    }
    
    func requestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.addPerformer(performer, workspaceID: workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate))
    }
    
    func requestRemovePerformerFromWorkspace(performer: Performer) {
        
        let prestate = suiteStore.suite
        suiteStore.removePerformer(performer)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate))
    }
    
    func requestSelectPerformer(performer: Performer) {
        
        djOutput.selectPerformer(performer)
    }
    
    func requestDeselectPerformer(performer: Performer) {
        
        djOutput.deselectPerformer(performer)
    }
    
    func requestToggleGroupingMode() {
        
        groupStore.toggleGroupingMode()
        djOutput.setGroupingMode(groupStore.groupingMode)
    }
    
    func requestCreateGroup(performers: Set<Performer>, groupIDs: Set<GroupID>) {
        
        let prestate = groupStore.groups
        groupStore.createGroup(performers: performers, groupIDs: groupIDs)
        let poststate = groupStore.groups        
        didChangeGroups(prestate, toGroups: poststate)
    }
    
    /*
    func requestAddGroup(group: Group, workspaceID: WorkspaceID) {
        
        for p in group.members {
            requestAddPerformerToWorkspace(p, workspaceID: workspaceID)
        }
    }
    
    func requestRemoveGroup(group: Group, workspaceID: WorkspaceID) {
        
        for p in group.members {
            requestRemovePerformerFromWorkspace(p, workspaceID: workspaceID)
        }
    }
    */

    /*

    
    func requestDestroyGroup(group: Group) {
        
        let prestate = groupStore.groups
        groupStore.destroyGroup(group)
        let poststate = groupStore.groups
  //      djOutput.changeGroups(prestate, toGroups: poststate)
        
        didChangeGroups(prestate, toGroups: poststate)
    }
*/
}

extension DJInteractor: ConnectableDelegate {
    
    func didConnectToAddress(address: Address) {
        
        djOutput.addPerformer(address)
    }
    
    func didDisconnectFromAddress(address: Address) {
        
        djOutput.removePerformer(address)
    }
}

extension DJInteractor {
    
    func didChangeSuite(fromSuite: Suite, toSuite: Suite) {
        
        let transformer = MessageTransformer(timestamp: NSDate().timeIntervalSince1970, sessionTimestamp: ChristiansTimeServer.timestamp)
        let messages = transformer.transform(fromSuite, toSuite: toSuite)
        
        MessageLogger.log(messages)
        
        for m in messages {
            adapter.writeMessage(m)
        }
    }
}

extension DJInteractor {
    
    func didChangeGroups(fromGroups: Set<Group>, toGroups: Set<Group>) {
        
        let outcome = GroupTransformer.transform(fromGroups, toGroups: toGroups)
        for c in outcome.created {
        //    djOutput.createGroup(c.group, performers: c.performers, groups: c.groups)
            djOutput.createGroup(c.groupID, sourcePerformers: c.sourcePerformers, sourceGroupIDs: c.sourceGroupIDs)
        }
        for d in outcome.destroyed {
       //     djOutput.destroyGroup(d)
            print(d)
        }
    }
        /*
        for g in toGroups {
            
            let merged_groups = fromGroups.filter({ g2 in  g2.members.intersect(g.members).count != 0}).filter({ fromGroups.contains($0) })
            
            let from_performers = fromGroups.reduce(Set()) { i, g in return i.union(g.members)}
            let to_performers = toGroups.reduce(Set()) { i, g in return i.union(g.members)}
            
            let merged_performers = to_performers.subtract(from_performers)
            
            print("Groups: \(merged_groups)")
            
            print("Performers: \(merged_performers)")
        }
        
        for g in fromGroups {
            
            let wasMerged = toGroups.filter({ g.members.isSubsetOf($0.members)}).count == 1
            
            guard !wasMerged else {
                return
            }
            
            print("DESTROYED: \(g)")
        }
*/
//    }
}



