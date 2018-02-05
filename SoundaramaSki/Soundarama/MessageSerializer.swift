//
//  PublisherMessageAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//
/*

class ActionMessageSerializer {
    
    static func serialize(message: ActionMessage) -> NSData {
        
        switch message.type {
            
            case .Start:
                
                let m = message as! StartActionMessage
                return Serialisation.setPayload(startMessageSerialization(m))
        
            case .Stop:
                
                let m = message as! StopActionMessage
                return Serialisation.setPayload(stopMessageSerialization(m))
            
            case .Mute:
            
                let m = message as! MuteActionMessage
                return Serialisation.setPayload(muteMessageSerialization(m))
            
            case .Unmute:
            
                let m = message as! UnmuteActionMessage
                return Serialisation.setPayload(unmuteMessageSerialization(m))
        }
    }
}

extension ActionMessageSerializer {
    
    static func startMessageSerialization(message: StartActionMessage) -> [String : AnyObject] {
        
        return [ ActionMessageSerialisationKeys.type : message.type.rawValue,
                 StartActionMessageSerialisationKeys.timestamp : message.timestamp,
                 StartActionMessageSerialisationKeys.reference : message.reference,
                 StartActionMessageSerialisationKeys.sessionTimestamp : message.sessionTimestamp,
                 StartActionMessageSerialisationKeys.referenceTimestamp : message.referenceTimestamp,
                 StartActionMessageSerialisationKeys.muted : message.muted ]
    }
    
    static func stopMessageSerialization(message: StopActionMessage) -> [String : AnyObject] {
        
         return [ ActionMessageSerialisationKeys.type : message.type.rawValue ]
    }
    
    static func muteMessageSerialization(message: MuteActionMessage) -> [String : AnyObject] {
        
        return [ ActionMessageSerialisationKeys.type : message.type.rawValue ]
    }
    
    static func unmuteMessageSerialization(message: UnmuteActionMessage) -> [String : AnyObject] {
        
        return [ ActionMessageSerialisationKeys.type : message.type.rawValue ]
    }
}

 */