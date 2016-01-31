//
//  PublisherMessageAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class WritableMessageAdapter {
    
    let writeable: Writeable!
    
    init(writeable: Writeable) {
        
        self.writeable = writeable
    }
    
    func writeMessage(message: PerformerMessage) {
        
        writeable.writeData(message.data(), address: message.address)
    }
}

/*
func writeAudioStemMessage(message: AudioStemMessage, address: Address) {

writeable.writeData(getData(message), address: address)
}
*/

/*
extension WritableMessageAdapter {
    
    func getData(message: AudioStemMessage) -> NSData {
        
        let d = [
            "ref" : message.reference,
            "time" : message.timestamp,
            "sessionTimestamp" : message.sessionTimestamp,
            "loopLength" : message.loopLength,
            "type" : message.type.rawValue
        ]
        
        return Serialisation.setPayload(d)
    }
}
*/