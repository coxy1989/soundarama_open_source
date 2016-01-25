//
//  PerformerInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class PerformerInteractor: PerformerInput {
 
    weak var performerOutput: PerformerOutput!
    
    private var connectionAdapter: PerformerConnectionAdapter!
    
    private var messageAdapter: ReadableMessageAdapter!
    
    private let endpoint = TP2P.endpoint()
    
    func start() {
        
        messageAdapter = ReadableMessageAdapter(readable: endpoint)
        messageAdapter.delegate = self
        
        connectionAdapter = PerformerConnectionAdapter(connection: endpoint)
        connectionAdapter.delegate = self
        
        endpoint.connect(.Search)
        endpoint.connectionDelegate = self
    }
}

extension PerformerInteractor: ReadableMessageAdapterDelegate {
    
    func didReceiveAudioStemMessage(message: AudioStemMessage) {
        
    }
    
    func didRecieveVolumeChangeMessage(message: VolumeChangeMessage) {
        
    }
}

extension PerformerInteractor: ConnectableDelegate {
    
    func didConnectToAddress(address: Address) {
        
    }
    
    func didDisconnectFromAddress(address: Address) {
        
    }
}

extension PerformerInteractor: PerformerConnectionAdapterDelegate {
    
    func performerConnectionStateDidChange(state: ConnectionState) {
        
        performerOutput.connectionStateDidChange(state)
        if state == .Connected {
            messageAdapter.takeMessage()
        }
    }
}
