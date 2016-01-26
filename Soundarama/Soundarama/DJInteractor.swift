//
//  DJInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class DJInteractor: DJInput {
    
    weak var djOutput: DJOutput!
    
    var adapter: WritableMessageAdapter!
    
    private let endpoint = TP2P.broadcastingEndpoint()
    
    private var christiansTimeServer: ChristiansTimeServer!
    
    func start() {
        
        christiansTimeServer = ChristiansTimeServer(endpoint: endpoint)
        adapter = WritableMessageAdapter(writeable: endpoint)
        
        endpoint.connectionDelegate = self
        endpoint.connect()
    }
    
    func didSelectAudioStemForPerformer(audioStem: AudioStem, performer: Performer) {
        
        let message = AudioStemMessage(reference: audioStem.reference, timestamp: NSDate().timeIntervalSince1970, sessionTimestamp: ChristiansTimeServer.timestamp,loopLength: 69, type: .Start)
        adapter.writeAudioStemMessage(message, address: performer)
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
