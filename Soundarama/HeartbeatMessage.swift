//
//  HeartbeatMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

enum DJHeartbeatMessageType: String {
    
    case Heartbeat = "Heartbeat"
}

struct DJHeartbeatMessage {
    
    let type: DJHeartbeatMessageType = .Heartbeat
}
