//
//  SyncMessageSerialisation.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

struct TimeServerSyncMessageSerialisationKeys {
    
    static let type = "Type"
    
    static let timestamp = "Timestamp"
}

struct TimeProcessSyncMessageSerialisationKeys {
    
    static let type = "Type"
}

enum SyncMessageParsingError: ErrorType {
    
    case FailedToUnarchiveJSON
    
    case InvalidJSON
    
    case InvalidMessage
}