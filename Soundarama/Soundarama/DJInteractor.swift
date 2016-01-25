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
    
    private let endpoint = TP2P.endpoint()
    
    func start() {
        
        endpoint.connectionDelegate = self
        endpoint.connect(.Broadcast)
        adapter = WritableMessageAdapter(writeable: endpoint)
    }
    
    func didSelectAudioStemForPerformer(audioStem: AudioStem, performer: Performer) {
        
    // TODO: sessionTimestamp
    
        let message = AudioStemMessage(audioStem: audioStem, timestamp: NSDate().timeIntervalSince1970, sessionTimestamp: 0.03, type: .Start)
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
