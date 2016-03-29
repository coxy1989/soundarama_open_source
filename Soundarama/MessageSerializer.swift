//
//  PublisherMessageAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class MessageSerializer {
    
    static func serialize(message: Message) -> NSData {
        
        switch message.type {
            
            case .Start:
                
            let m = message as! StartMessage
            return Serialisation.setPayload(startMessageSerialization(m))
        
            case .Stop:
                
            let m = message as! StopMessage
            return Serialisation.setPayload(stopMessageSerialization(m))
            
            case .Mute:
            
            let m = message as! MuteMessage
            return Serialisation.setPayload(muteMessageSerialization(m))
            
            case .Unmute:
            
            let m = message as! UnmuteMessage
            return Serialisation.setPayload(unmuteMessageSerialization(m))
        }
    }
}

extension MessageSerializer {
    
    static func startMessageSerialization(message: StartMessage) -> [String : AnyObject] {
        
        return [ MessageSerialisationKeys.type : message.type.rawValue,
                 StartMessageSerialisationKeys.timestamp : message.timestamp,
                 StartMessageSerialisationKeys.reference : message.reference,
                 StartMessageSerialisationKeys.sessionTimestamp : message.sessionTimestamp,
                 StartMessageSerialisationKeys.referenceTimestamp : message.referenceTimestamp,
                 StartMessageSerialisationKeys.muted : message.muted ]
    }
    
    static func stopMessageSerialization(message: StopMessage) -> [String : AnyObject] {
        
         return [ MessageSerialisationKeys.type : message.type.rawValue ]
    }
    
    static func muteMessageSerialization(message: MuteMessage) -> [String : AnyObject] {
        
        return [ MessageSerialisationKeys.type : message.type.rawValue ]
    }
    
    static func unmuteMessageSerialization(message: UnmuteMessage) -> [String : AnyObject] {
        
        return [ MessageSerialisationKeys.type : message.type.rawValue ]
    }
}

/*
 let json = [
 "timestamp" : message.timestamp,
 "sessionTimestamp" : message.sessionTimestamp,
 "reference" : message.reference,
 "loopLength" : message.loopLength,
 "command" : message.command.rawValue,
 "muted" : message.muted
 ]
 
 return Serialisation.setPayload(json)
 */