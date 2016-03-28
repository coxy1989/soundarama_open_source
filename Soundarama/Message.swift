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

protocol Message {
    
    var type: MessageType { get }
    
    var address: Address { get }
}

enum MessageType: String {
    
    case Start = "Start"
    
    case Stop = "Stop"
    
    case Mute = "Mute"
    
    case Unmute = "Unmute"
}

struct StartMessage: Message {
    
    let type: MessageType = .Start
    
    let address: Address
    
    let timestamp: NSTimeInterval
    
    let reference: String
    
    let sessionTimestamp: Double
    
    let referenceTimestamp: NSTimeInterval
    
    let muted: Bool
    
    var hashValue: Int {
        
        return type.hashValue
            ^ address.hashValue
            ^ timestamp.hashValue
            ^ reference.hashValue
            ^ sessionTimestamp.hashValue
            ^ referenceTimestamp.hashValue
            ^ muted.hashValue
    }
}

struct StopMessage: Message {
    
    let type: MessageType = .Stop
    
    let address: Address
    
    var hashValue: Int {
        
        return type.hashValue
            ^ address.hashValue
    }
}

struct MuteMessage: Message {
    
    let type: MessageType = .Mute
    
    let address: Address
    
    var hashValue: Int {
        
        return type.hashValue ^ address.hashValue
    }
}

struct UnmuteMessage: Message {
    
    let type: MessageType = .Unmute
    
    let address: Address
    
    var hashValue: Int {
        
        return type.hashValue ^ address.hashValue
    }
}

func == (lhs: StartMessage, rhs: StartMessage) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.address == rhs.address
        && lhs.timestamp == rhs.timestamp
        && lhs.reference == rhs.reference
        && lhs.sessionTimestamp == rhs.sessionTimestamp
        && lhs.referenceTimestamp == rhs.referenceTimestamp
        && lhs.muted == rhs.muted
}

func == (lhs: StopMessage, rhs: StopMessage) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.address == rhs.address
}

func == (lhs: MuteMessage, rhs: MuteMessage) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.address == rhs.address
}

func == (lhs: UnmuteMessage, rhs: UnmuteMessage) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.address == rhs.address
}

