//
//  StateMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import Result

struct StateMessage {
    
    let suite: Suite
    
    let performer: Performer
    
    let referenceTimestamps: [Reference : NSTimeInterval]
    
    let timestamp: NSTimeInterval
}

struct StateMessageSerialisationKeys {
    
    static let suite = "suite"
    
    static let performer = "performer"
    
    static let referenceTimestamps = "referenceTimestamps"
    
    static let timestamp = "timestamp"
}

struct WorkspaceSerialisationKeys {
    
    static let identifier = "identifier"
    
    static let audioStem = "audioStem"
    
    static let performers = "performers"
    
    static let muted = "muted"
    
    static let solo = "solo"
    
    static let antiSolo = "antiSolo"
}

enum StateMessageSerializationError: ErrorType {
    
    case FailedToUnarchiveJSON
    
    case InvalidMessage
}

struct StateMessageSerializer {
    
    static func serialize(message: StateMessage) -> NSData {
        
        let json = toJSON(message)
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0)).mutableCopy()
        data.appendData(Serialisation.terminator)
        return data as! NSData
    }
    
    private static func toJSON(message: StateMessage) -> [String : AnyObject] {
        
        return [ StateMessageSerialisationKeys.suite : message.suite.map(serializeWorkspace),
                 StateMessageSerialisationKeys.performer : message.performer,
                 StateMessageSerialisationKeys.referenceTimestamps : message.referenceTimestamps,
                 StateMessageSerialisationKeys.timestamp : message.timestamp]
    }
    
    private static func serializeWorkspace(workspace: Workspace) -> [String : AnyObject] {
        
        return [ WorkspaceSerialisationKeys.identifier : workspace.identifier,
          WorkspaceSerialisationKeys.audioStem : workspace.audioStem ?? "NULL",
          WorkspaceSerialisationKeys.performers : Array(workspace.performers),
          WorkspaceSerialisationKeys.muted :  workspace.isMuted,
          WorkspaceSerialisationKeys.solo : workspace.isSolo,
          WorkspaceSerialisationKeys.antiSolo : workspace.isAntiSolo ]
    }
}

struct StateMessageDeserializer {
    
    static func deserialize(data: NSData) -> Result<StateMessage, StateMessageSerializationError> {
     
        return getJSON(data).flatMap(getMessage)
    }
    
    static func getMessage(json: AnyObject) -> Result<StateMessage, StateMessageSerializationError> {
        
        guard let suite = json[StateMessageSerialisationKeys.suite] as? [[String : AnyObject]],
                    performer = json[StateMessageSerialisationKeys.performer] as? String,
                    referenceTimestamps = json[StateMessageSerialisationKeys.referenceTimestamps] as? [String : NSTimeInterval],
                    timestamp = json[StateMessageSerialisationKeys.timestamp] as? NSTimeInterval
            else {
                
                return Result<StateMessage, StateMessageSerializationError>.Failure(.InvalidMessage)
        }
        
        let wsr = suite.map(getWorkspace).flatMap() { $0.value }
        
        //TODO: assert no fucked up workspaces
        
        let msg = StateMessage(suite: Set(wsr), performer: performer, referenceTimestamps: referenceTimestamps, timestamp: timestamp)
        
        return Result<StateMessage, StateMessageSerializationError>.Success(msg)
    }

    static func getWorkspaces(json: [[String : AnyObject]]) -> Result<[Workspace], StateMessageSerializationError> {
        
        let wsr = json.map(getWorkspace)
        let fu = wsr.flatMap() { $0.value }
        
        return  Result<[Workspace], StateMessageSerializationError>.Success(fu)
    }
    
    static func getWorkspace(json: [String : AnyObject]) -> Result<Workspace, StateMessageSerializationError> {
        
        let identifier = json[WorkspaceSerialisationKeys.identifier] as! String
        let audioStem = json[WorkspaceSerialisationKeys.audioStem] as! String
        let performers = json[WorkspaceSerialisationKeys.performers] as! [String]
        let muted = json[WorkspaceSerialisationKeys.muted] as! NSNumber
        let solo = json[WorkspaceSerialisationKeys.solo] as! NSNumber
        let antiSolo = json[WorkspaceSerialisationKeys.antiSolo] as! NSNumber
    //    else {
            
       //     return Result<Workspace, StateMessageSerializationError>.Failure(.FailedToUnarchiveJSON)
      //  }
        
        return Result<Workspace, StateMessageSerializationError>.Success(Workspace(identifier: identifier, audioStem: audioStem == "NULL" ? nil : audioStem, performers: Set(performers), isMuted: muted.boolValue, isSolo: solo.boolValue, isAntiSolo: antiSolo.boolValue))
    }
}

private func getJSON(data: NSData) -> Result<AnyObject, StateMessageSerializationError> {
    
    let dat = data.mutableCopy()
    let range = NSMakeRange(data.length - Serialisation.terminator.length, Serialisation.terminator.length)
    
    dat.replaceBytesInRange(range, withBytes: nil, length: 0)
    
    do {
     
        let dic2 = try NSJSONSerialization.JSONObjectWithData(dat as! NSData , options: NSJSONReadingOptions.AllowFragments)
        //debugPrint(dic2)
        return Result<AnyObject, StateMessageSerializationError>.Success(dic2)
    }
    catch {
        debugPrint("FUCK")
        return Result<AnyObject, StateMessageSerializationError>.Failure(.FailedToUnarchiveJSON)
    }
    
    
    //let payload = Serialisation.getPayload(data)
    //let json = JSON(payload)
    
    //debugPrint(json.dictionary)
    //debugPrint(json.dictionary?.keys)
    //assert(json != nil)
    
    //return Result<AnyObject, StateMessageSerializationError>.Failure(.FailedToUnarchiveJSON)
    
    //return NSKeyedUnarchiver.unarchiveObjectWithData(payload).map() { Result<AnyObject, SyncMessageParsingError>.Success($0) } ?? Result<AnyObject, SyncMessageParsingError>.Failure(.FailedToUnarchiveJSON)
}
