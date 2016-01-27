//
//  DJInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class DJInteractor {
    
    weak var djOutput: DJOutput!
    
    var adapter: WritableMessageAdapter!
    
    private let endpoint = TP2P.broadcastingEndpoint()
    
    private var christiansTimeServer: ChristiansTimeServer!
    
    private var audioStemStore = AudioStemStore()
    
    func start() {
        
        christiansTimeServer = ChristiansTimeServer(endpoint: endpoint)
        adapter = WritableMessageAdapter(writeable: endpoint)
        
        endpoint.connectionDelegate = self
        endpoint.connect()
    }
}

extension DJInteractor: DJInput {
    
    func didSelectAudioStemForPerformer(audioStem: AudioStem, performer: Performer) {
        
        print("Sending AudoStem Message: \(audioStem.reference) performer: \(performer)")
        return
        
        let message = AudioStemMessage(reference: audioStem.reference, timestamp: NSDate().timeIntervalSince1970, sessionTimestamp: ChristiansTimeServer.timestamp,loopLength: 1.875, type: .Start)
        adapter.writeAudioStemMessage(message, address: performer)
    }
    
    func fetchAudioStems() -> [AudioStem] {
        
        return audioStemStore.fetchAllStems()
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
