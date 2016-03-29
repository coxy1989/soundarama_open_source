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
    
    weak var djAudioStemPickerOutput: DJAudioStemPickerOutput!
    
    var endpoint: Endpoint!
    
    private let suiteStore = SuiteStore(number: UIDevice.isPad() ? 9 : 4)
    
    private let groupStore = GroupStore()
    
    private var christiansTimeServer: ChristiansTimeServer!
    
    private lazy var audioStemStore: AudioStemStore =  { AudioStemStore() } ()
}

extension DJInteractor: DJInput {
    
    func startDJ() {
        
        djOutput.setUISuite(UISuiteTransformer.transform(suiteStore.suite))
        djOutput.setGroupingMode(true)
        
        christiansTimeServer = ChristiansTimeServer(endpoint: endpoint)
        
        endpoint.connectionDelegate = self
        endpoint.connect()
    }
    
    func stopDJ() {
        
        endpoint.disconnect()
    }
    
    func getStemKeys() -> [String] {
        
        return AudioStemStore.keys
    }
    
    func getStemKeyColors() -> [String : UIColor] {
        
        return AudioStemStore.colors
    }
    
    func getStemsIndex() -> [CategoryKey : [SongKey : Set<UIAudioStem>]] {
    
        var idx: [String : [String : Set<UIAudioStem>]] = [ : ]
        
        audioStemStore.index.forEach() { ck, sm in
            
            var songidx: [String : Set<UIAudioStem>] = [ : ]
            sm.forEach() { sk, stems in songidx[sk] = UIAudioStemTransformer.transform(stems) }
            idx[ck] = songidx
        }
        
        return idx
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
    
    func requestAudioStemInWorkspace(audioStemID: AudioStemID, workspaceID: WorkspaceID) {
        
        guard let audioStem = audioStemStore.audioStem(audioStemID) else {
            
            assert(false, "This is a logical error")
            return
        }
        
        let prestate = suiteStore.suite
        suiteStore.setAudioStem(audioStem, workspaceID: workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate))
    }
    
    func requestMovePerformer(performer: Performer, translation: CGPoint) {
        
        guard groupStore.groupingMode == false else {
            return
        }
        
        djOutput.movePerformer(performer, translation: translation)
    }
    
    func requestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID) {
        
        guard groupStore.groupingMode == false else {
            return
        }
        
        let prestate = suiteStore.suite
        suiteStore.addPerformer(performer, workspaceID: workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate))
    }
    
    func requestRemovePerformerFromWorkspace(performer: Performer) {
        
        guard groupStore.groupingMode == false else {
            return
        }
        
        let prestate = suiteStore.suite
        suiteStore.removePerformer(performer)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate))
    }
    
    func requestSelectPerformer(performer: Performer) {
        
        guard groupStore.groupingMode == false else {
            return
        }
        
        djOutput.selectPerformer(performer)
    }
    
    func requestDeselectPerformer(performer: Performer) {
                
        djOutput.deselectPerformer(performer)
    }
    
    func requestToggleGroupingMode() {
        
        groupStore.toggleGroupingMode()
        djOutput.setGroupingMode(groupStore.groupingMode)
    }
    
    func requestStartLassoo(atPoint: CGPoint) {
        
        djOutput.startLassoo(atPoint)
    }
    
    func requestContinueLasoo(toPoint: CGPoint) {
        
        djOutput.continueLasoo(toPoint)
    }   
    
    func requestEndLasoo(atPoint: CGPoint) {
        
        djOutput.endLasoo(atPoint)
    }
    
    func requestCreateGroup(performers: Set<Performer>, groupIDs: Set<GroupID>) {
        
        guard groupStore.isValidGroup(performers, groupIDs: groupIDs, inSuite: suiteStore.suite) else {
            return
        }
        
        let prestate = groupStore.groups
        groupStore.createGroup(performers: performers, groupIDs: groupIDs)
        let poststate = groupStore.groups        
        didChangeGroups(prestate, toGroups: poststate)
    }
    
    func requestDestroyGroup(groupID: GroupID) {
        
        let prestate = groupStore.groups
        groupStore.destroyGroup(groupID)
        let poststate = groupStore.groups
        didChangeGroups(prestate, toGroups: poststate)
    }
    
    func requestSelectGroup(groupID: GroupID) {
        
        guard groupStore.groupingMode == false else {
            return
        }
        
        djOutput.selectGroup(groupID)
    }
    
    func requestDeselectGroup(groupID: GroupID) {
        
        djOutput.deselectGroup(groupID)
    }
    
    func requestMoveGroup(groupID: GroupID, translation: CGPoint) {
        
        guard groupStore.groupingMode == false else {
            return
        }
        
        djOutput.moveGroup(groupID, translation: translation)
    }
    
    func requestAddGroupToWorkspace(groupID: GroupID, workspaceID: WorkspaceID) {
        
        let group = groupStore.groups.filter({ $0.id() == groupID }).first!
        group.members.forEach() { requestAddPerformerToWorkspace($0, workspaceID: workspaceID) }
    }
    
    func requestRemoveGroupFromWorkspace(groupID: GroupID) {
        
        let group = groupStore.groups.filter({ $0.id() == groupID }).first!
        group.members.forEach() { requestRemovePerformerFromWorkspace($0) }
    }
}

extension DJInteractor: DJAudioStemPickerInput {
    
    func startDJAudioStemPicker() {
        
        djAudioStemPickerOutput.setSelectedKey(AudioStemStore.firstKey)
    }
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
        
        MessageTransformer.transform(fromSuite, toSuite: toSuite, timestamp: NSDate().timeIntervalSince1970, sessionTimestamp: ChristiansTimeServer.timestamp, referenceTimestamps: [ : ])
        .map() { (addresss: $0.address, data: MessageSerializer.serialize($0)) }
        .forEach() { endpoint.writeData($0.data, address: $0.addresss) }
        
        
        //let transformer = MessageTransformer(timestamp: NSDate().timeIntervalSince1970, sessionTimestamp: ChristiansTimeServer.timestamp)
        
        //let messages = transformer.transform(fromSuite, toSuite: toSuite)
        
        //MessageLogger.log(messages)
        
        //messages.forEach() { adapter.writeMessage($0) }
    }
}

extension DJInteractor {
    
    func didChangeGroups(fromGroups: Set<Group>, toGroups: Set<Group>) {
        
        let outcome = GroupTransformer.transform(fromGroups, toGroups: toGroups)
        
        if let created = outcome.created {
            
            djOutput.createGroup(created.groupID, groupSize: groupStore.getSize(created.groupID)!, sourcePerformers: created.sourcePerformers, sourceGroupIDs: created.sourceGroupIDs)
        }
            
        else if let destroyed = outcome.destroyed {
            
            djOutput.destroyGroup(destroyed.id(), intoPerformers: destroyed.members)
        }
    }
}

