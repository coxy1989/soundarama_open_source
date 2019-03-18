//
//  StateMessageSerialisation.swift
//  Soundarama
//
//  Created by Jamie Cox on 28/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct StateMessageSerializationKeys {
    
    static let suite = "suite"
    
    static let performer = "performer"
    
    static let referenceTimestamps = "referenceTimestamps"
    
    static let timestamp = "timestamp"
}

struct WorkspaceSerializationKeys {
    
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
    
    case InvalidWorkspace
}
