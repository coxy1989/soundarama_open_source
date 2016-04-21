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
    
    private let broadcastStore = BroadcastStore()
    
    private let endpointStore = EndpointStore()
    
    private let referenceTimestampStore = ReferenceTimestampStore()
    
    private lazy var audioStemStore: AudioStemStore =  { AudioStemStore() } ()
    
    /* Connect */
    
    private var christiansTimeServers: [String : ChristiansTimeServer] = [ : ]
    
    private var socketAcceptor: SocketAcceptor?
    
   // private var searchcastService: SearchcastService?
    
    private var wifiReachability: WiFiReachability!

    private var discovery: ReceptiveDiscovery?
}

extension DJInteractor: DJInput {
    
    func startDJ() {
        
        discovery = ReceptiveDiscovery()
        
        discovery?.discover(NetworkConfiguration.type, domain: NetworkConfiguration.domain, name: UIDevice.currentDevice().name)
            
            .on(failed: { e in
                
                debugPrint("FAILED: \(e)") })
        
            .on(next: { n in
                
                 debugPrint("NEXT: \(n)") })
            
            .start()
        /*
        let wifi_reachable = { [weak self] in
            
            self?.startNetworkIO()
            self?.djBroadcastConfigurationOutput?.setReachabilityState(true)
            self?.requestAddIdentifier(UIDevice.currentDevice().name)
            debugPrint("WiFi available")
        }
        
        let wifi_unreachable = { [weak self] in
        
            self?.stopNetworkIO()
            self?.djBroadcastConfigurationOutput?.setIdentifiers([])
            self?.djBroadcastConfigurationOutput?.setReachabilityState(false)
            self?.djOutput.setBroadcastStatusMessage("Not Broadcasting")
            debugPrint("WiFi unavailable")
        }
        
        let wifi_failure = {
            
            debugPrint("WiFi monitioring failure")
            return
        }
        
        wifiReachability = WiFiReachability.monitoringReachability(wifi_reachable, unreachable: wifi_unreachable, failure: wifi_failure)
        djOutput.setBroadcastStatusMessage("Not Broadcasting")
        djOutput.setUISuite(UISuiteTransformer.transform(suiteStore.suite))
        djOutput.setGroupingMode(true)
 */
        //wifiReachability = WiFiReachability.monitoringReachability(wifi_reachable, unreachable: wifi_unreachable, failure: wifi_failure)
        djOutput.setBroadcastStatusMessage("Not Broadcasting")
        djOutput.setUISuite(UISuiteTransformer.transform(suiteStore.suite))
        djOutput.setGroupingMode(true)
        
    }
    
    func stopDJ() {
        
        wifiReachability.stop()
        stopNetworkIO()
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

extension DJInteractor: DJBroadcastConfigurationInput {
    
    func startBroadcastConfiguration() {
        
        let reachable = wifiReachability.isReachable()
        let identifiers = reachable ? broadcastStore.getState().resolvableIdentifiers.sort() : []
        djBroadcastConfigurationOutput?.setIdentifiers(identifiers)
        djBroadcastConfigurationOutput?.setReachabilityState(reachable)
    }
    
    func requestAddIdentifier(identifier: String) {
    
        let prestate = broadcastStore.getState()
        broadcastStore.setUserBroadcastIdentifer(identifier)
        let poststate = broadcastStore.getState()
        didChangeBroadcastState(prestate, toState: poststate)
     //   searchcastService?.broadcast(NetworkConfiguration.type, domain: NetworkConfiguration.domain, port: Int32(NetworkConfiguration.port), identifier: identifier)
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

extension DJInteractor {
    
    func startNetworkIO() {
        
        if startSocketAcceptor() {
            
            startSearchcast()
        }
        
        else {
            
            //TODO: This represents a nasty IO fuck up. Give some "check internet connection and restart the app"  messaging.
        }
    }
    
    func stopNetworkIO() {
        
        socketAcceptor?.stop()
      //  searchcastService?.stop()
        endpointStore.getEndpoints().forEach() { $0.disconnect() }
    }
    
    func startSocketAcceptor() -> Bool {
        
        let accepted: (String, Endpoint) -> () = { [weak self] e in
            
            debugPrint("accepted endpoint")
            let cts = ChristiansTimeServer(address: e.0, endpoint: e.1)
            cts.delegate = self
            self?.christiansTimeServers[e.0] = cts
            e.1.onDisconnect() { self?.christiansTimeServers.removeValueForKey(e.0) }
        }
    
        let stopped: () -> () = {
            
            debugPrint("stopped accepting endpoints")
            return
        }
        
        guard let acceptor = SocketAcceptor.accepting(NetworkConfiguration.port16, accepted: accepted, stopped: stopped) else {
            
            return false
        }
        
        socketAcceptor = acceptor
        
        return true
    }
    
    func startSearchcast() {
        
        let added: String -> () = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            let prestate = this.broadcastStore.getState()
            this.broadcastStore.addResolvableIdentifier($0)
            let poststate = this.broadcastStore.getState()
            this.didChangeBroadcastState(prestate, toState: poststate)
        }
        
        let removed: String -> () = { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            let prestate = this.broadcastStore.getState()
            this.broadcastStore.removeResolvableIdentifier($0)
            let poststate = this.broadcastStore.getState()
            this.didChangeBroadcastState(prestate, toState: poststate)
        }
        
     //   searchcastService = SearchcastService.searching(NetworkConfiguration.type, domain: NetworkConfiguration.domain, added: added, removed: removed)
    }
}

extension DJInteractor: ChristiansTimeServerDelegate {
    
    func christiansTimeServerDidSyncronise(timeServer: ChristiansTimeServer, endpoint: (String, Endpoint)) {
        
        debugPrint("syncronised")
        
        endpoint.1.onDisconnect() { [weak self] in
            
            self?.endpointStore.removeEndpoint(endpoint.0)
            self?.djOutput.removePerformer(endpoint.0)
            debugPrint("disconnected syncronised endpoint")
        }
        
        endpointStore.addEndpoint(endpoint.0, endpoint: endpoint.1)
        djOutput.addPerformer(endpoint.0)
        
        debugPrint("TIME_SERVERS: " + "\(christiansTimeServers.count)")
      //  christiansTimeServers.removeValueForKey(endpoint.0)
    }
}

extension DJInteractor {
    
    func didChangeBroadcastState(fromState: BroadcastState, toState: BroadcastState) {
        
        if let ub = toState.userBroadcastIdentifier where toState.resolvableIdentifiers.contains(ub) {
            
            djOutput.setBroadcastStatusMessage("Broadcating as \(ub)")
        }
            
        else {
            
            djOutput.setBroadcastStatusMessage("Not Broadcasting")
        }
        
        djBroadcastConfigurationOutput?.setIdentifiers(toState.resolvableIdentifiers.sort())
    }
}
