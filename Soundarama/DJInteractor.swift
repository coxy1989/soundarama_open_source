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
    
    /* Viper */
    
    weak var djOutput: DJOutput!
    
    weak var djAudioStemPickerOutput: DJAudioStemPickerOutput!
    
    weak var djBroadcastConfigurationOutput: DJBroadcastConfigurationOutput?
    
    /* State */
    
    private let suiteStore = SuiteStore(number: UIDevice.isPad() ? 9 : 4)
    
    private let groupStore = GroupStore()
    
    private let endpointStore = EndpointStore()
    
    private let referenceTimestampStore = ReferenceTimestampStore()
    
    private lazy var audioStemStore: AudioStemStore =  { AudioStemStore() } ()
    
    /* Accept */
    
    private var discovery: ReceptiveDiscovery?
    
    private var socketAcceptor: SocketAcceptor?
    
    private var server: ChristiansTimeServer?
}

extension DJInteractor: DJInput {
   
    func startDJ() {

        discovery = ReceptiveDiscovery()
        socketAcceptor = SocketAcceptor()
        server = ChristiansTimeServer()
        
        discovery?.discover(NetworkConfiguration.type, domain: NetworkConfiguration.domain, name: UIDevice.currentDevice().name)
            
            .on(failed: { e in
                
                /* TODO: UI */
                debugPrint("Discovery Error: \(e)")})
            
            .on(next: { e in
                
                /* TODO: UI */
                debugPrint("Discovery Event: \(e)")})
            
            
            .on(disposed: { debugPrint("Disposed discovery signal")})
            
            .start()
        
        socketAcceptor?.accept(NetworkConfiguration.port16)
            
            .on(failed: {e in
                
                /* TODO: UI */
                debugPrint("Socket acceptor Error: \(e)")})
            
            .on(next: { [weak self] e in
                
                self?.onEndpoint(e.0, ep: e.1)
                debugPrint("Socket acceptor Event: \(e)")})
            
            .on(disposed: { debugPrint("Disposed acceptor signal")})
            
            .start()
        
        
        djOutput.setUISuite(UISuiteTransformer.transform(suiteStore.suite))
        djOutput.setGroupingMode(true)
    }
    
    func stopDJ() {
        
        discovery?.stop()
        socketAcceptor?.stop()
        server?.stop()
        endpointStore.getEndpoints().forEach() { $0.disconnect() }
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
        
        djOutput.cancelLasoo()
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

extension DJInteractor {
    
    func onEndpoint(id: String, ep: Endpoint) {
        
        server?.syncronise(id, endpoint: ep)
            .on(next: onSyncronised)
            .on(failed: onSyncFailed)
            .on(disposed: { debugPrint("Disposed syncronise signal")})
            .start()
    }
    
    func onSyncFailed(error: ChristiansTimeServerError) {
        
        switch error {
            
            case .Cancelled(let e):
                
                debugPrint("Sync failed: \(e)")
                e.disconnect()
            
            case .Timeout(let e):
                
                debugPrint("Sync failed: \(e)")
                e.disconnect()
        }
    }
    
    func onSyncronised(performer: Performer, endpoint: Endpoint) {
        
        debugPrint("Successfully synced performer: \(performer)")
        
        outputAddPerformer(performer)
        endpointStore.addEndpoint(performer, endpoint: endpoint)
        endpoint.onDisconnect() { [weak self] in self?.onDisconnected(performer) }
    }
    
    func onDisconnected(performer: String) {
        
        debugPrint("Performer disconnected: \(performer)")
        
        endpointStore.removeEndpoint(performer)
        outputRemovePerformer(performer)
    }
}

extension DJInteractor {
    
    func outputAddPerformer(performer: String) {
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
            self?.djOutput.addPerformer(performer)
        }
    }
    
    func outputRemovePerformer(performer: String) {
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
            self?.djOutput.removePerformer(performer)
        }
    }
}

extension DJInteractor {
    
    func didChangeSuite(fromSuite: Suite, toSuite: Suite) {
        
        let commands = DJCommandTransformer.transform(fromSuite, toSuite: toSuite)
        
        let messages: [(Address, Message)] = commands.map() {
            
            switch $0.type {
                
                case .Start:

                    let timestamps = calculateStartTimestamps(($0 as! DJStartCommand).reference)
                    
                    return ($0.performer, DJMessageTransformer.transform(($0 as! DJStartCommand), timestamp: timestamps.unix, sessionTimestamp: ChristiansTimeServer.timestamp, referenceTimestamp: ChristiansTimeServer.timestamp))
                
                case .Stop:
                    
                    return ($0.performer, DJMessageTransformer.transform($0 as! DJStopCommand))
                
                case .Mute:
                    
                    return ($0.performer, DJMessageTransformer.transform($0 as! DJMuteCommand))
                
                case .Unmute:
                    
                    return ($0.performer, DJMessageTransformer.transform($0 as! DJUnmuteCommand))
            }
        }
        
          messages.forEach() { endpointStore.getEndpoint($0.0).writeData(MessageSerializer.serialize($0.1)) }
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
