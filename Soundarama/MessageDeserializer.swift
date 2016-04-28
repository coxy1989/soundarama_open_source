//
//  MessageDeserializer.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Result

class ActionMessageDeserializer {
    
    //TODO: flat map this mess
    
    static func deserialize(data: NSData)  -> Result<ActionMessage, ActionMessageParsingError> {
        
        let payload = Serialisation.getPayload(data)
        
        guard let json = NSKeyedUnarchiver.unarchiveObjectWithData(payload) else {
            
            return Result<ActionMessage, ActionMessageParsingError>.Failure(.FailedToUnarchiveJSON)
        }
        
        guard let type = json[ActionMessageSerialisationKeys.type] as? String else {
            
            return Result<ActionMessage, ActionMessageParsingError>.Failure(.InvalidJSON)
        }
     
        if type == ActionMessageType.Start.rawValue {
            
            return deserialiseStartMessage(json)
        }
        
        else if type == ActionMessageType.Stop.rawValue {
            
            return Result<ActionMessage, ActionMessageParsingError>.Success(StopActionMessage())
        }
        
        else if type == ActionMessageType.Mute.rawValue {
            
            return Result<ActionMessage, ActionMessageParsingError>.Success(MuteActionMessage())
        }
        
        else if type == ActionMessageType.Unmute.rawValue {
            
             return Result<ActionMessage, ActionMessageParsingError>.Success(UnmuteActionMessage())
        }
        
        else {
    
            return Result<ActionMessage, ActionMessageParsingError>.Failure(.InvalidMessage)
        }
    }
}

extension ActionMessageDeserializer {
    
    static func deserialiseStartMessage(json: AnyObject) -> Result<ActionMessage, ActionMessageParsingError> {
        
        guard let timestamp = json[StartActionMessageSerialisationKeys.timestamp] as? Double,
                reference = json[StartActionMessageSerialisationKeys.reference] as?  String,
                sessionTimestamp = json[StartActionMessageSerialisationKeys.sessionTimestamp] as? Double,
                referenceTimestamp = json[StartActionMessageSerialisationKeys.referenceTimestamp] as? Double,
                muted = json[StartActionMessageSerialisationKeys.muted] as? Bool else {
                    
            return Result<ActionMessage, ActionMessageParsingError>.Failure(.InvalidStartMessage)
        }
        
        return Result<ActionMessage, ActionMessageParsingError>.Success( StartActionMessage(timestamp: timestamp, reference: reference, sessionTimestamp: sessionTimestamp, referenceTimestamp: referenceTimestamp, muted: muted))
    }
    
    static func deserializeStopMessage(json: AnyObject) -> StopActionMessage? {
        
        return StopActionMessage()
    }
    
    static func deserializeMuteMessage(json: AnyObject) -> MuteActionMessage? {
        
        return MuteActionMessage()
    }
    
    static func deserializeUnmuteMessage(json: AnyObject) -> UnmuteActionMessage? {
        
        return UnmuteActionMessage()
    }
}
