//
//  Command.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

enum DJCommandType {
    
    case Start
    
    case Stop
    
    case Mute
    
    case Unmute
}

protocol DJCommand {

    var type: DJCommandType { get }
    
    var performer: Performer { get }
    
    func precedence() -> Int
}

struct DJStartCommand: DJCommand, Equatable {
 
    let type = DJCommandType.Start
    
    let performer: Performer
    
    let reference: String
    
    let muted: Bool
    
    func precedence() -> Int {
        
        return 0
    }
}

struct DJStopCommand: DJCommand, Equatable {
    
    let type = DJCommandType.Stop
    
    let performer: Performer
    
    func precedence() -> Int {
        
        return 1
    }
}

struct DJMuteCommand: DJCommand, Equatable {
    
    let type = DJCommandType.Mute
    
    let performer: Performer
    
    func precedence() -> Int {
        
        return 2
    }
}

struct DJUnmuteCommand: DJCommand, Equatable {
    
    let type = DJCommandType.Unmute
    
    let performer: Performer
    
    func precedence() -> Int {
        
        return 2
    }
}

func == (lhs: DJStartCommand, rhs: DJStartCommand) -> Bool {

    return  lhs.type == rhs.type &&
            lhs.performer == rhs.performer &&
            lhs.reference == rhs.reference &&
            lhs.muted == rhs.muted
}

func == (lhs: DJStopCommand, rhs: DJStopCommand) -> Bool {

    return  lhs.type == rhs.type &&
            lhs.performer == rhs.performer
}


func == (lhs: DJMuteCommand, rhs: DJMuteCommand) -> Bool {

    return  lhs.type == rhs.type &&
            lhs.performer == rhs.performer
}


func == (lhs: DJUnmuteCommand, rhs: DJUnmuteCommand) -> Bool {

    return  lhs.type == rhs.type &&
            lhs.performer == rhs.performer
}
