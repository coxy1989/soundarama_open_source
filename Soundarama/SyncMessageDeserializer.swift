//
//  SyncMessageDeserializer.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import Result

class TimeProcessSyncMessageDeserializer {
    
    static func deserialize(data: NSData)  -> Result<TimeProcessSyncMessage, SyncMessageParsingError> {
        
        return Serialization.getJSON(data)
            .flatMapError() { _ in Result<AnyObject, SyncMessageParsingError>.Failure(SyncMessageParsingError.FailedToUnarchiveJSON) }
            .flatMap(getType)
            .flatMap(getMessage)
    }
    
    static func getType(object: AnyObject) -> Result<String, SyncMessageParsingError> {
        
        return (object[TimeProcessSyncMessageSerializationKeys.type] as? String).map() { Result<String, SyncMessageParsingError>.Success($0) } ?? Result<String, SyncMessageParsingError>.Failure(.InvalidJSON)
    }
    
    static func getMessage(type: String) -> Result<TimeProcessSyncMessage, SyncMessageParsingError> {
        
        if type == TimeProcessSyncMessageType.Start.rawValue {
            
            return Result<TimeProcessSyncMessage, SyncMessageParsingError>.Success(TimeProcessSyncStartMessage())
        }
        
        else if type == TimeProcessSyncMessageType.Acknowledge.rawValue {
         
               return Result<TimeProcessSyncMessage, SyncMessageParsingError>.Success(TimeProcessSyncAcknowledgeMessage())
        }
        
        else if type == TimeProcessSyncMessageType.Repeat.rawValue {
            
            return Result<TimeProcessSyncMessage, SyncMessageParsingError>.Success(TimeProcessSyncRepeatMessage())
        }
        
        return Result<TimeProcessSyncMessage, SyncMessageParsingError>.Failure(.InvalidMessage)
    }
}

class TimeServerSyncMessageDeserializer {
    
    static func deserialize(data: NSData)  -> Result<TimeServerSyncMessage, SyncMessageParsingError> {
        
        return Serialization.getJSON(data)
            .flatMapError() { _ in Result<AnyObject, SyncMessageParsingError>.Failure(SyncMessageParsingError.FailedToUnarchiveJSON) }
            .flatMap(getType)
            .flatMap(getMessage)
    }
    
    static func getType(json: AnyObject) -> Result<(String, AnyObject), SyncMessageParsingError> {
        
        return (json[TimeServerSyncMessageSerializationKeys.type] as? String).map() { Result<(String, AnyObject), SyncMessageParsingError>.Success($0, json) } ?? Result<(String, AnyObject), SyncMessageParsingError>.Failure(.InvalidJSON)
    }
    
    static func getMessage(type: String, json: AnyObject) -> Result<TimeServerSyncMessage, SyncMessageParsingError> {
        
        if type == TimeServerSyncMessageType.Time.rawValue {
            
            return deserializeTimeMessage(json)
        }
        
        else if type == TimeServerSyncMessageType.Stop.rawValue {
            
            return Result<TimeServerSyncMessage, SyncMessageParsingError>.Success(TimeServerSyncStopMessage())
        }
        
        return Result<TimeServerSyncMessage, SyncMessageParsingError>.Failure(.InvalidMessage)
    }
    
    static func deserializeTimeMessage(json: AnyObject) -> Result<TimeServerSyncMessage, SyncMessageParsingError> {
        
        guard let timestamp = json[TimeServerSyncMessageSerializationKeys.timestamp] as? NSTimeInterval else {
            
            return Result<TimeServerSyncMessage, SyncMessageParsingError>.Failure(.InvalidMessage)
        }
        
        return Result<TimeServerSyncMessage, SyncMessageParsingError>.Success(TimeServerSyncTimeMessage(timestamp: timestamp))
    }
}
