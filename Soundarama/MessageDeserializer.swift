//
//  MessageDeserializer.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Result

class MessageDeserializer {
    
    //TODO: flat map this mess
    
    static func deserialize(data: NSData)  -> Result<Message, ParsingError> {
        
        let payload = Serialisation.getPayload(data)
        
        guard let json = NSKeyedUnarchiver.unarchiveObjectWithData(payload) else {
            
            return Result<Message, ParsingError>.Failure(.FailedToUnarchiveJSON)
        }
        
        guard let type = json[MessageSerialisationKeys.type] as? String else {
            
            return Result<Message, ParsingError>.Failure(.InvalidJSON)
        }
     
        if type == MessageType.Start.rawValue {
            
            return deserialiseStartMessage(json)
        }
        
        else if type == MessageType.Stop.rawValue {
            
            return Result<Message, ParsingError>.Success(StopMessage())
        }
        
        else if type == MessageType.Mute.rawValue {
            
            return Result<Message, ParsingError>.Success(MuteMessage())
        }
        
        else if type == MessageType.Unmute.rawValue {
            
             return Result<Message, ParsingError>.Success(UnmuteMessage())
        }
        
        else {
    
            return Result<Message, ParsingError>.Failure(.InvalidMessage)
        }
    }
}

extension MessageDeserializer {
    
    static func deserialiseStartMessage(json: AnyObject) -> Result<Message, ParsingError> {
        
        guard let timestamp = json[StartMessageSerialisationKeys.timestamp] as? Double,
                reference = json[StartMessageSerialisationKeys.reference] as?  String,
                sessionTimestamp = json[StartMessageSerialisationKeys.sessionTimestamp] as? Double,
                referenceTimestamp = json[StartMessageSerialisationKeys.referenceTimestamp] as? Double,
                muted = json[StartMessageSerialisationKeys.muted] as? Bool else {
                    
            return Result<Message, ParsingError>.Failure(.InvalidStartMessage)
        }
        
        return Result<Message, ParsingError>.Success( StartMessage(timestamp: timestamp, reference: reference, sessionTimestamp: sessionTimestamp, referenceTimestamp: referenceTimestamp, muted: muted))
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
