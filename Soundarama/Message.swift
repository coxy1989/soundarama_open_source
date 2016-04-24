//
//  AudioStemMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

// TODO: Rename `Action`Message

protocol Message {
    
    var type: MessageType { get }
}

enum MessageType: String {
    
    case Start = "Start"
    
    case Stop = "Stop"
    
    case Mute = "Mute"
    
    case Unmute = "Unmute"
}

struct StartMessage: Message {
    
    let type: MessageType = .Start
    
    let timestamp: NSTimeInterval
    
    let reference: String
    
    let sessionTimestamp: Double
    
    let referenceTimestamp: NSTimeInterval
    
    let muted: Bool
    
    var hashValue: Int {
        
        return type.hashValue
            ^ timestamp.hashValue
            ^ reference.hashValue
            ^ sessionTimestamp.hashValue
            ^ referenceTimestamp.hashValue
            ^ muted.hashValue
    }
}

struct StopMessage: Message {
    
    let type: MessageType = .Stop
    
    var hashValue: Int {
        
        return type.hashValue
    }
}

struct MuteMessage: Message {
    
    let type: MessageType = .Mute
    
    var hashValue: Int {
        
        return type.hashValue
    }
}

struct UnmuteMessage: Message {
    
    let type: MessageType = .Unmute
    
    var hashValue: Int {
        
        return type.hashValue
    }
}

func == (lhs: StartMessage, rhs: StartMessage) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.timestamp == rhs.timestamp
        && lhs.reference == rhs.reference
        && lhs.sessionTimestamp == rhs.sessionTimestamp
        && lhs.referenceTimestamp == rhs.referenceTimestamp
        && lhs.muted == rhs.muted
}

func == (lhs: StopMessage, rhs: StopMessage) -> Bool {
    
    return lhs.type == rhs.type
}

func == (lhs: MuteMessage, rhs: MuteMessage) -> Bool {
    
    return lhs.type == rhs.type
}

func == (lhs: UnmuteMessage, rhs: UnmuteMessage) -> Bool {
    
    return lhs.type == rhs.type
}

