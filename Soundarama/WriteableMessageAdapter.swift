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
        
        writeable.writeData(serialize(message), address: message.address)
    }
}

extension WritableMessageAdapter {
    
    func serialize(message: PerformerMessage) -> NSData {
        
        let json = [
            "timestamp" : message.timestamp,
            "sessionTimestamp" : message.sessionTimestamp,
            "reference" : message.reference,
            "loopLength" : message.loopLength,
            "command" : message.command.rawValue,
            "muted" : message.muted
        ]
        
        return Serialisation.setPayload(json)
    }
}
