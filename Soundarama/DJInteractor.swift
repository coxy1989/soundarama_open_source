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
    
    weak var djBroadcastConfigurationOutput: DJBroadcastConfigurationOutput!
    
    var endpoint: Endpoint!
    
    private let suiteStore = SuiteStore(number: UIDevice.isPad() ? 9 : 4)
    
    private let groupStore = GroupStore()
    
    private let resolvableStore = ResolvableStore()
    
    private let referenceTimestampStore = ReferenceTimestampStore()
    
    private var christiansTimeServer: ChristiansTimeServer!
    
    private var browsingService: BrowseService?
    
    private lazy var audioStemStore: AudioStemStore =  { AudioStemStore() } ()
}

extension DJInteractor: DJInput {
    
    func startDJ() {
        
        djOutput.setUISuite(UISuiteTransformer.transform(suiteStore.suite))
        djOutput.setGroupingMode(true)
        christiansTimeServer = ChristiansTimeServer(endpoint: endpoint)
        //endpoint.connectionDelegate = self
        //endpoint.connect()
        
    }
    
    func stopDJ() {
        
        //endpoint.disconnect()
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

extension DJInteractor: DJBroadcastConfigurationInput {
    
    func startBroadcastConfiguration() {
        
        let found: (String, Resolvable) -> () = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.resolvableStore.addResolvable($0)
            this.djBroadcastConfigurationOutput.setIdentifiers(this.resolvableStore.identifiers())
        }
        
        let lost: (String, Resolvable) -> () = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.resolvableStore.removeResolvable($0)
            this.djBroadcastConfigurationOutput.setIdentifiers(this.resolvableStore.identifiers())
        }
        
        let failed: () -> () = {
            
        }
        
        browsingService = BrowseService.browsing(NetworkConfiguration.type, domain: NetworkConfiguration.domain, found: found, lost: lost, failed: failed)
    }
    
    func requestAddIdentifier(identifier: String) {
        
        //TODO: callbacki-ify host
        
        /*
         guard let host = Host.aceptingOnPort(666) else {
         // output.setBroadcastingState(.Failed)
         return
         }
         
         let failure: ([String : NSNumber]) -> () = { _ in
         
         }
         
         BroadcastService.broadcasting("", type: "", name: identifier, port: 666, failure: failure)
         */
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
        
        let commands = DJCommandTransformer.transform(fromSuite, toSuite: toSuite)
        
        let messages: [(Address, Message)] = commands.map() {
            
            switch $0.type {
                
                case .Start:

                    let timestamps = calculateStartTimestamps(($0 as! DJStartCommand).reference)
                    
                    return ($0.performer, DJMessageTransformer.transform(($0 as! DJStartCommand), timestamp: timestamps.unix, sessionTimestamp: ChristiansTimeServer.timestamp, referenceTimestamp: timestamps.reference_unix))
                
                case .Stop:
                    
                    return ($0.performer, DJMessageTransformer.transform($0 as! DJStopCommand))
                
                case .Mute:
                    
                    return ($0.performer, DJMessageTransformer.transform($0 as! DJMuteCommand))
                
                case .Unmute:
                    
                    return ($0.performer, DJMessageTransformer.transform($0 as! DJUnmuteCommand))
            }
        }
        
        messages.forEach() { endpoint.writeData(MessageSerializer.serialize($0.1), address: $0.0) }
    }
    
    func calculateStartTimestamps(reference: String) -> (unix: NSTimeInterval, reference_unix: NSTimeInterval) {
        
        let unix = NSDate().timeIntervalSince1970
        var reference_unix = referenceTimestampStore.getTimestamp(reference)
        if reference_unix == nil {
            referenceTimestampStore.setTimestamp(unix, reference: reference)
            reference_unix = unix
        }
        
        return (unix, reference_unix!)
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
