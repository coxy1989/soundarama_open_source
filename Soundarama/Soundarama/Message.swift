//
//  AudioStemMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct PerformerMessage {
    
    enum PerformerMessageCommand: UInt {
        
        case Start = 0, Stop, ToggleMute
    }
    
    let address: Address
    let timestamp: Double
    let sessionTimestamp: Double
    let reference: String
    let loopLength: NSTimeInterval
    let command: PerformerMessageCommand
    let muted: Bool
    
    func data() -> NSData {
        
        //TODO
        return NSData()
    }
}


/*
protocol Message {

var address: Address { get }
var timestamp: Double { get }
func data() -> NSData
}
*/
/*
func == (lhs: PerformerMessageAudioStem, rhs: PerformerMessageAudioStem) -> Bool {

let refs = lhs.reference == rhs.reference
let lengths = lhs.loopLength == rhs.loopLength
let commands = lhs.audioStemCommand == rhs.audioStemCommand
return refs && lengths && commands
}

*/
/*
struct AudioStemMessage {
    
    enum MessageType: UInt {
        
        case Start = 0, Stop
    }
    
    let reference: String
    let timestamp: Double
    let sessionTimestamp: Double
    let loopLength: NSTimeInterval
    let type: MessageType

    init (reference: String, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, loopLength: NSTimeInterval, type: MessageType) {
        
        self.reference = reference
        self.timestamp = timestamp
        self.loopLength = loopLength
        self.type = type
        self.sessionTimestamp = sessionTimestamp
    }
}
*/