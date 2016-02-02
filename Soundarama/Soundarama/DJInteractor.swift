//
//  DJInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJInteractor {
    
    weak var djOutput: DJOutput!
    
    var endpoint: Endpoint!
    
    private var adapter: WritableMessageAdapter!
    
    private var christiansTimeServer: ChristiansTimeServer!
    
    private var audioStemStore = AudioStemStore()
    
    private var suiteStore: SuiteStore!
}

extension DJInteractor: DJInput {
    
    func start() {
        
        //TODO: handle pro (16), pad(9) phone(4)
        suiteStore = SuiteStore(number: UIDevice.isPad() ? 9 : 4)
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
    
    func requestToggleMuteInWorkspace(workspace: Workspace) {
        
        let prestate = suiteStore.suite
        suiteStore.toggleMute(workspace)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
    }
    
    func requestToggleSoloInWorkspace(workspace: Workspace) {
        
      let prestate = suiteStore.suite
        suiteStore.toggleSolo(workspace)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
    }
    
    func requestAudioStemInWorkspace(audioStem: AudioStem, workspace: Workspace) {
        
        let prestate = suiteStore.suite
        suiteStore.setAudioStem(audioStem, workspace: workspace)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
    }
    
    func requestAddPerformerToWorkspace(performer: Performer, workspace: Workspace) {
        
        let prestate = suiteStore.suite
        suiteStore.addPerformer(performer, workspace: workspace)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
    }
    
    func requestRemovePerformerFromWorkspace(performer: Performer, workspace: Workspace) {
        
        let prestate = suiteStore.suite
        suiteStore.removePerformer(performer, workspace: workspace)
        let poststate = suiteStore.suite
        didChangeSuite(prestate, toSuite: poststate)
        djOutput.setSuite(poststate)
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
