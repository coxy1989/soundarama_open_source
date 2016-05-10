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
    
    /* State */
    
    private let suiteStore = SuiteStore(number: UIDevice.isPad() ? 9 : 4)
    
    private let groupStore = GroupStore()
    
    private let endpointStore = EndpointStore()
    
    private let referenceTimestampStore = ReferenceTimestampStore()
    
    private lazy var audioStemStore: AudioStemStore =  { AudioStemStore() } ()
    
    /* Accept */
    
    private let discovery = ReceptiveDiscovery()
    
    private var socketAcceptor = SocketAcceptor()
    
    private var server = ChristiansTimeServer()
    
    /* Heartbeat */
    
    private var heartbeat: NSTimer?
}

extension DJInteractor: DJInput {
   
    /*
    @objc func beatHeart() {
        
        endpointStore.getEndpoints().forEach() { address, endpoint in
            
            debugPrint("Sending Heartbeat")
            endpoint.writeData(StateMessageSerializer.serialize(StateMessage(suite: suiteStore.suite, performer: address, referenceTimestamps: referenceTimestampStore.getTimestamps(), timestamp: NSDate().timeIntervalSince1970)))
        }
    }
     */
    
    func startDJ() {

        /* heartbeat = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(beatHeart), userInfo: nil, repeats: true) */
        
        djOutput.setUISuite(UISuiteTransformer.transform(suiteStore.suite, name: audioStemStore.name, colors: ColorStore.colors))
        djOutput.setGroupingMode(true)
        
        discovery.discover(NetworkConfiguration.type, domain: NetworkConfiguration.domain, name: UIDevice.currentDevice().name)
            
            .on(failed: { e in
                
                /* TODO: UI */
                debugPrint("Discovery Error: \(e)")})
            
            .on(next: { e in
                
                /* TODO: UI */
                debugPrint("Discovery Event: \(e)")})
            
            
            .on(disposed: { debugPrint("Disposed discovery signal")})
            
            .start()
        
        socketAcceptor.accept(NetworkConfiguration.port16)
            
            .on(failed: {e in
                
                /* TODO: UI */
                debugPrint("Socket acceptor Error: \(e)")})
            
            .on(next: { [weak self] e in
                
                self?.onEndpoint(e.0, ep: e.1)
                debugPrint("Socket acceptor Event: \(e)")})
            
            .on(disposed: { debugPrint("Disposed acceptor signal")})
            
            .start()
    }
    
    func stopDJ() {
        
        discovery.stop()
        socketAcceptor.stop()
        server.stop()
        endpointStore.getEndpoints().forEach() { $0.1.disconnect() }
        heartbeat?.invalidate()
    }
    
    func getCategoryKeys() -> [String] {
        
        return AudioStemStore.categoryKeys
    }
    
    func getCategoryKeyColors() -> [String : UIColor] {
        
        return ColorStore.categoryKeyColors
    }
    
    func getStemsIndex() -> [CategoryKey : [SongKey : Set<UIAudioStem>]] {
    
        var idx: [String : [String : Set<UIAudioStem>]] = [ : ]
        
        audioStemStore.index.forEach() { ck, sm in
            
            var songidx: [String : Set<UIAudioStem>] = [ : ]
            sm.forEach() { sk, stems in songidx[sk] = UIAudioStemTransformer.transform(stems, color: ColorStore.colors) }
            idx[ck] = songidx
        }
        
        return idx
    }

    func requestToggleMuteInWorkspace(workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.toggleMute(workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate, name: audioStemStore.name, colors: ColorStore.colors))
    }
    
    func requestToggleSoloInWorkspace(workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.toggleSolo(workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate, name: audioStemStore.name, colors: ColorStore.colors))
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
        djOutput.setUISuite(UISuiteTransformer.transform(poststate, name: audioStemStore.name, colors: ColorStore.colors))
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
        djOutput.setUISuite(UISuiteTransformer.transform(poststate, name: audioStemStore.name, colors: ColorStore.colors))
    }
    
    func requestRemovePerformerFromWorkspace(performer: Performer) {
        
        guard groupStore.groupingMode == false else {
            return
        }
        
        let prestate = suiteStore.suite
        suiteStore.removePerformer(performer)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setUISuite(UISuiteTransformer.transform(poststate, name: audioStemStore.name, colors: ColorStore.colors))
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
        
        djOutput.cancelLasoo()
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
        
        server.syncronise(id, endpoint: ep)
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
        
        /* TODO: There is a bug here. Need to remove performer from group too. */
        suiteStore.removePerformer(performer)
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
        
        commands.forEach() {
            
            if $0.type == .Start {
                
                calculateStartTimestamps(($0 as! DJStartCommand).reference)
            }
        }
        
        endpointStore.getEndpoints().forEach() { address, endpoint in
            
            debugPrint("Sending state change")
            endpoint.writeData(StateMessageSerializer.serialize(StateMessage(suite: suiteStore.suite, performer: address, referenceTimestamps: referenceTimestampStore.getTimestamps(), timestamp: NSDate().timeIntervalSince1970)))
        }
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
