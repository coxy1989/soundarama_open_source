//
//  AudioStemMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

struct AudioStemMessage {
    
    enum MessageType: UInt {
        case Start = 0
        case Stop
    }
    
    let reference: String
    let timestamp: Double
    let sessionTimestamp: Double
    let loopLength: NSTimeInterval
    let type: MessageType

    init (reference: String, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, loopLength: NSTimeInterval, type: MessageType)
    {
        self.reference = reference
        self.timestamp = timestamp
        self.loopLength = loopLength
        self.type = type
        self.sessionTimestamp = sessionTimestamp
    }
}