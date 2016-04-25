//
//  SyncMessageSerializer.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class TimeProcessSyncMessageSerializer {
    
    static func serialize(message: TimeProcessSyncMessage) -> NSData {
        
        return Serialisation.setPayload(messageSerialization(message))
    }
    
    static func messageSerialization(message: TimeProcessSyncMessage) -> [String : AnyObject] {
        
        return [ TimeProcessSyncMessageSerialisationKeys.type : message.type.rawValue ]
    }
}

class TimeServerSyncMessageSerializer {
    
    static func serialize(message: TimeServerSyncMessage) -> NSData {
        
        return Serialisation.setPayload(getJSON(message))
    }
    
    static func getJSON(message: TimeServerSyncMessage) -> [String : AnyObject] {
        
        switch message.type {
            
            case .Time:
                
                let m = message as! TimeServerSyncTimeMessage
                return timeMessageSerialization(m)
            
            case .Stop:
                
                let m = message as! TimeServerSyncStopMessage
                return stopMessageSerialization(m)
        }
    }
    
    static func  timeMessageSerialization(message: TimeServerSyncTimeMessage) -> [String : AnyObject] {
     
        return [ TimeServerSyncMessageSerialisationKeys.type : message.type.rawValue,
                 TimeServerSyncMessageSerialisationKeys.timestamp : message.timestamp ]
    }
     
    static func stopMessageSerialization(message: TimeServerSyncStopMessage) -> [String : AnyObject] {
     
        return [ TimeServerSyncMessageSerialisationKeys.type : message.type.rawValue ]
    }
}
