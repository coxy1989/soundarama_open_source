//
//  PublisherMessageAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class PublisherMessageAdapter {
    
    let publisher: Publisher!
    
    init(publisher: Publisher) {
        self.publisher = publisher
    }
    
    func publishAudioStemMessage(message: AudioStemMessage) {
        
        print("PUBLISH HERE")
    }
    
    func publishVolumeChangeMessage(message: VolumeChangeMessage) {
        
        print("PUBLISH HERE")
    }
}