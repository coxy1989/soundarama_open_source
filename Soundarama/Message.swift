//
//  AudioStemMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

// TODO: Rename `Action`Message

protocol ActionMessage {
    
    var type: ActionMessageType { get }
}

enum ActionMessageType: String {
    
    case Start = "Start"
    
    case Stop = "Stop"
    
    case Mute = "Mute"
    
    case Unmute = "Unmute"
}

struct StartActionMessage: ActionMessage {
    
    let type: ActionMessageType = .Start
    
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

struct StopActionMessage: ActionMessage {
    
    let type: ActionMessageType = .Stop
    
    var hashValue: Int {
        
        return type.hashValue
    }
}

struct MuteActionMessage: ActionMessage {
    
    let type: ActionMessageType = .Mute
    
    var hashValue: Int {
        
        return type.hashValue
    }
}

struct UnmuteActionMessage: ActionMessage {
    
    let type: ActionMessageType = .Unmute
    
    var hashValue: Int {
        
        return type.hashValue
    }
}

func == (lhs: StartActionMessage, rhs: StartActionMessage) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.timestamp == rhs.timestamp
        && lhs.reference == rhs.reference
        && lhs.sessionTimestamp == rhs.sessionTimestamp
        && lhs.referenceTimestamp == rhs.referenceTimestamp
        && lhs.muted == rhs.muted
}

func == (lhs: StopActionMessage, rhs: StopActionMessage) -> Bool {
    
    return lhs.type == rhs.type
}

func == (lhs: MuteActionMessage, rhs: MuteActionMessage) -> Bool {
    
    return lhs.type == rhs.type
}

func == (lhs: UnmuteActionMessage, rhs: UnmuteActionMessage) -> Bool {
    
    return lhs.type == rhs.type
}

