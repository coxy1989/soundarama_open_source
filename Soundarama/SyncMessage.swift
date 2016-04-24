//
//  SyncMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

/* Process */

protocol TimeProcessSyncMessage {
    
    var type: TimeProcessSyncMessageType { get }
}

struct TimeProcessSyncStartMessage: TimeProcessSyncMessage {
    
    let type: TimeProcessSyncMessageType = .Start
}

struct TimeProcessSyncAcknowledgeMessage: TimeProcessSyncMessage {
    
    let type: TimeProcessSyncMessageType = .Acknowledge
}

/* Server */

protocol TimeServerSyncMessage {
    
    var type: TimeServerSyncMessageType { get }
}

struct TimeServerSyncTimeMessage: TimeServerSyncMessage {
    
    let type: TimeServerSyncMessageType = .Time
    
    let timestamp: NSTimeInterval
}

struct TimeServerSyncStopMessage: TimeServerSyncMessage {
    
    let type: TimeServerSyncMessageType = .Stop
}
