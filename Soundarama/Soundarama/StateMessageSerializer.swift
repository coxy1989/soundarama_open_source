//
//  StateMessageSerializer.swift
//  Soundarama
//
//  Created by Jamie Cox on 28/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

struct StateMessageSerializer {
    
    static func serialize(message: StateMessage) -> NSData {
        
        let json = toJSON(message)
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0)).mutableCopy()
        data.appendData(Serialization.terminator)
        return data as! NSData
    }
    
    private static func toJSON(message: StateMessage) -> [String : AnyObject] {
        
        return [ StateMessageSerializationKeys.suite : message.suite.map(serializeWorkspace),
                 StateMessageSerializationKeys.performer : message.performer,
                 StateMessageSerializationKeys.referenceTimestamps : message.referenceTimestamps,
                 StateMessageSerializationKeys.timestamp : message.timestamp]
    }
    
    private static func serializeWorkspace(workspace: Workspace) -> [String : AnyObject] {
        
        return [ WorkspaceSerializationKeys.identifier : workspace.identifier,
                 WorkspaceSerializationKeys.audioStem : workspace.audioStem ?? "NULL",
                 WorkspaceSerializationKeys.performers : Array(workspace.performers),
                 WorkspaceSerializationKeys.muted :  workspace.isMuted,
                 WorkspaceSerializationKeys.solo : workspace.isSolo,
                 WorkspaceSerializationKeys.antiSolo : workspace.isAntiSolo ]
    }
}
