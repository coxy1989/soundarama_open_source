//
//  MessageDeserializer.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class MessageDeserializer {
    
    static func deserialize(data: NSData)  -> Message? {
        
        let payload = Serialisation.getPayload(data)
        
        guard let json = NSKeyedUnarchiver.unarchiveObjectWithData(payload) else {
            
            print("Failed to unarchive JSON")
            return nil
        }
        
        guard let type = json[MessageSerialisationKeys.type] as? String else {
            
            print("Failed to obtain a value for MessageSerialisationKeys.type Key")
            return nil
        }
     
    
        if type == MessageType.Start.rawValue {
            
            return deserialiseStartMessage(json)
        }
        
        else if type == MessageType.Stop.rawValue {
            
            return deserializeStopMessage(json)
        }
        
        else if type == MessageType.Mute.rawValue {
            
            return deserializeMuteMessage(json)
        }
        
        else if type == MessageType.Unmute.rawValue {
            
            return deserializeUnmuteMessage(json)
        }
        
        else {
            
            print("Failed to obtain a valid value for MessageSerialisationKeys.type Key")
            return nil
        }
    }
}

extension MessageDeserializer {
    
    static func deserialiseStartMessage(json: AnyObject) -> StartMessage? {
        
        guard let timestamp = json[StartMessageSerialisationKeys.timestamp] as? Double,
                reference = json[StartMessageSerialisationKeys.reference] as?  String,
                sessionTimestamp = json[StartMessageSerialisationKeys.sessionTimestamp] as? Double,
                referenceTimestamp = json[StartMessageSerialisationKeys.referenceTimestamp] as? Double,
                muted = json[StartMessageSerialisationKeys.muted] as? Bool else {
                    
            return nil
        }
        
        return StartMessage(timestamp: timestamp, reference: reference, sessionTimestamp: sessionTimestamp, referenceTimestamp: referenceTimestamp, muted: muted)
    }
    
    static func deserializeStopMessage(json: AnyObject) -> StopMessage? {
        
        return StopMessage()
    }
    
    static func deserializeMuteMessage(json: AnyObject) -> MuteMessage? {
        
        return MuteMessage()
    }
    
    static func deserializeUnmuteMessage(json: AnyObject) -> UnmuteMessage? {
        
        return UnmuteMessage()
    }
}
