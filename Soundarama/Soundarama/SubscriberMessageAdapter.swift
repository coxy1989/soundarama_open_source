//
//  SubscriberMessageAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol SubscriberMessageAdapterDelegate {
    
    func didReceiveAudioStemMessage(message: AudioStemMessage)
    
    func didRecieveVolumeChangeMessage(message: VolumeChangeMessage)
}

class SubscriberMessageAdapter: SubscriberDelegate {
    
    var delegate: SubscriberMessageAdapterDelegate!
    
    init(subscriber: Subscriber) {
        subscriber.delegate = self
    }
    
    func didRecieveData(data: NSData) {
        
        print("RECIEVE HERE")
    }
}
