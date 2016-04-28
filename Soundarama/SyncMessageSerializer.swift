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
        
        let json = toJSON(message)
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0)).mutableCopy()
        data.appendData(Serialization.terminator)
        return data as! NSData
    }
    
    static func toJSON(message: TimeProcessSyncMessage) -> [String : AnyObject] {
        
        return [ TimeProcessSyncMessageSerializationKeys.type : message.type.rawValue ]
    }
}

class TimeServerSyncMessageSerializer {
    
    static func serialize(message: TimeServerSyncMessage) -> NSData {
        
        let json = toJSON(message)
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0)).mutableCopy()
        data.appendData(Serialization.terminator)
        return data as! NSData
    }
    
    static func toJSON(message: TimeServerSyncMessage) -> [String : AnyObject] {
        
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
     
        return [ TimeServerSyncMessageSerializationKeys.type : message.type.rawValue,
                 TimeServerSyncMessageSerializationKeys.timestamp : message.timestamp ]
    }
     
    static func stopMessageSerialization(message: TimeServerSyncStopMessage) -> [String : AnyObject] {
     
        return [ TimeServerSyncMessageSerializationKeys.type : message.type.rawValue ]
    }
}
