//
//  PerformerInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class PerformerInteractor: PerformerInput {
 
    weak var performerOutput: PerformerOutput!
    
    let subscriber = Subscriber()
    
    var adapter: SubscriberMessageAdapter!
    
    func start() {
        
        adapter = SubscriberMessageAdapter(subscriber: subscriber)
        adapter.delegate = self
        subscriber.subscribe()
    }
}

extension PerformerInteractor: SubscriberMessageAdapterDelegate {
    
    func didReceiveAudioStemMessage(message: AudioStemMessage) {
        
    }
    
    func didRecieveVolumeChangeMessage(message: VolumeChangeMessage) {
        
    }
}
