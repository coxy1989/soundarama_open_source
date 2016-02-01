//
//  AudioStemMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

enum PerformerMessageCommand: UInt {
    
    case Start = 0, Stop, ToggleMute
}

struct PerformerMessage {
    
    let address: Address
    let timestamp: Double
    let sessionTimestamp: Double
    let reference: String
    let loopLength: NSTimeInterval
    let command: PerformerMessageCommand
    let muted: Bool
}
