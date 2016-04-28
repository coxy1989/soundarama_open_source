//
//  StateMessageDeserializer.swift
//  Soundarama
//
//  Created by Jamie Cox on 28/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import Result

struct StateMessageDeserializer {
    
    static func deserialize(data: NSData) -> Result<StateMessage, StateMessageSerializationError> {
        
        return Serialization.getJSON(data)
            .flatMapError() { _ in Result<AnyObject, StateMessageSerializationError>.Failure(.FailedToUnarchiveJSON)}
            .flatMap(getMessage)
    }
    
    static func getMessage(json: AnyObject) -> Result<StateMessage, StateMessageSerializationError> {
        
        guard let suite = json[StateMessageSerializationKeys.suite] as? [[String : AnyObject]],
            performer = json[StateMessageSerializationKeys.performer] as? String,
            referenceTimestamps = json[StateMessageSerializationKeys.referenceTimestamps] as? [String : NSTimeInterval],
            timestamp = json[StateMessageSerializationKeys.timestamp] as? NSTimeInterval
            else {
                
                return Result<StateMessage, StateMessageSerializationError>.Failure(.InvalidMessage)
        }
        
        let workspaces = suite.map(getWorkspace).flatMap() { $0.value }
        
        guard workspaces.count == suite.count else {
            
             return Result<StateMessage, StateMessageSerializationError>.Failure(.InvalidWorkspace)
        }
        
        return Result<StateMessage, StateMessageSerializationError>.Success(StateMessage(suite: Set(workspaces), performer: performer, referenceTimestamps: referenceTimestamps, timestamp: timestamp))
    }
    
    static func getWorkspace(json: [String : AnyObject]) -> Result<Workspace, StateMessageSerializationError> {
        
        guard let identifier = json[WorkspaceSerializationKeys.identifier] as? String,
            audioStem = json[WorkspaceSerializationKeys.audioStem] as? String,
            performers = json[WorkspaceSerializationKeys.performers] as? [String],
            muted = json[WorkspaceSerializationKeys.muted] as? NSNumber,
            solo = json[WorkspaceSerializationKeys.solo] as? NSNumber,
            antiSolo = json[WorkspaceSerializationKeys.antiSolo] as? NSNumber else {
                
               return Result<Workspace, StateMessageSerializationError>.Failure(.FailedToUnarchiveJSON)
        }
        
        return Result<Workspace, StateMessageSerializationError>.Success(Workspace(identifier: identifier, audioStem: audioStem == "NULL" ? nil : audioStem, performers: Set(performers), isMuted: muted.boolValue, isSolo: solo.boolValue, isAntiSolo: antiSolo.boolValue))
    }
}
