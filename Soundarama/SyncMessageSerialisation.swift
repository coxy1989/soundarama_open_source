//
//  SyncMessageSerialisation.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

enum TimeServerSyncMessageType: String {
    
    case Time = "Time"
    
    case Stop = "Stop"
}

enum TimeProcessSyncMessageType: String {
    
    case Start = "Start"
    
    case Acknowledge = "Ack"
    
    case Repeat = "Repeat"
}

struct TimeServerSyncMessageSerialisationKeys {
    
    static let type = "Type"
    
    static let timestamp = "Timestamp"
}

struct TimeProcessSyncMessageSerialisationKeys {
    
    static let type = "Type"
}