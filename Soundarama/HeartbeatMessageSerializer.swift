//
//  HeartbeatMessageSerializer.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class DJHeartbeatMessageSerializer {
    
    static func serialize(message: DJHeartbeatMessage) -> NSData {
        
        return Serialisation.setPayload(messageSerialization(message))
    }
    
    static func messageSerialization(message: DJHeartbeatMessage) -> [String : AnyObject] {
        
        return [ DJHeartbeatMessageSerialisationKeys.type : message.type.rawValue ]
    }
}