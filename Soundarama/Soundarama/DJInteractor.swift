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
        djOutput.setSuite(suiteStore.suite)
        djOutput.setAudioStems(audioStemStore.audioStems)
        
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
        djOutput.setSuite(poststate)
    }
    
    func requestToggleSoloInWorkspace(workspaceID: WorkspaceID) {
        
      let prestate = suiteStore.suite
        suiteStore.toggleSolo(workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
    }
    
    func requestAudioStemInWorkspace(audioStem: AudioStem, workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.setAudioStem(audioStem, workspaceID: workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
    }
    
    func requestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.addPerformer(performer, workspaceID: workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
    }
    
    func requestRemovePerformerFromWorkspace(performer: Performer, workspaceID: WorkspaceID) {
        
        let prestate = suiteStore.suite
        suiteStore.removePerformer(performer, workspaceID: workspaceID)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
    }
    
    func didRequestAddGroup(group: Group, workspaceID: WorkspaceID) {
        
        for p in group.members {
            requestAddPerformerToWorkspace(p, workspaceID: workspaceID)
        }
    }
    
    func didRequestRemoveGroup(group: Group, workspaceID: WorkspaceID) {
        
        for p in group.members {
            requestRemovePerformerFromWorkspace(p, workspaceID: workspaceID)
        }
    }
    
    func requestCreateGroup(performers: Set<Performer>, groups: Set<Group>) {
        
        let prestate = groupStore.groups
        groupStore.createGroup(performers: performers, groups: groups)
        let poststate = groupStore.groups
        djOutput.changeGroups(prestate, toGroups: poststate)
    }
    
    func requestDestroyGroup(group: Group) {
        
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
        
        let transformer = MessageTransformer(timestamp: NSDate().timeIntervalSince1970, sessionTimestamp: ChristiansTimeServer.timestamp)
        let messages = transformer.transform(fromSuite, toSuite: toSuite)
        
        MessageLogger.log(messages)
        
        for m in messages {
            adapter.writeMessage(m)
        }
    }
}


