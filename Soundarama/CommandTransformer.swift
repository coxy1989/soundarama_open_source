//
//  MessageTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

// Start: reference, performer, muted
// Rest: performer


class DJCommandTransformer {
    
    static func transform(fromSuite: Suite, toSuite: Suite) -> [DJCommand] {
        
        var records: [DJCommand] = []
        let fromTable = table(fromSuite)
        let solosTo = Set(toSuite.filter({$0.isSolo}))
        let solosFrom = Set(fromSuite.filter({$0.isSolo}))
        
        toSuite.forEach() {
            
            let from = fromTable[$0.identifier]!
            
            if let rec = addedPerformer(from, to: $0, toSolos: solosTo) {
                
                records.append(rec)
            }
            
            if let rec = removedPerformer(from, to: $0, toSolos: solosTo) {
                
                records.append(rec)
            }
            
            if let recs = toAudioStem(from, to: $0, toSolos: solosTo) {
                
                recs.forEach() { records.append($0) }
            }
            
            if let recs = fromAudioStem(from, to: $0, toSolos: solosTo) {
                
                recs.forEach() { records.append($0) }
            }
            
            if let recs = betweenAudioStems(from, to: $0, toSolos: solosTo) {
                
                recs.forEach() { records.append($0) }
            }
            
            if let recs = mute(from, to: $0, toSolos: solosTo) {
                
                recs.forEach() { records.append($0) }
            }
            
            if let recs = solo(from, to: $0, fromSolos: solosFrom, toSolos: solosTo) {
                
                recs.forEach() { records.append($0) }
            }
        }
        
        return filter(records)
    }
}

extension DJCommandTransformer {
    
    private static func filter(commands: [DJCommand]) -> [DJCommand] {
    
        var ptable: [Performer : DJCommand] = [ : ]
        
        commands.forEach() {
            
            if let ec = ptable[$0.performer] {
                
                if $0.precedence() < ec.precedence() {
                
                    ptable[$0.performer] = $0
                }
            }
            
            else {
                
                ptable[$0.performer] = $0
            }
        }
        
        return Array(ptable.values)
    }
    
    private static func table(suite: Suite) -> [String : Workspace] {
        
        var table: [String : Workspace] = [ : ]
        for ws in suite {
            table[ws.identifier] = ws
        }
        return table
    }
    
    private static func effectiveMute(workspace ws: Workspace, solos s: Set<Workspace>) -> Bool {
        
        guard s.count > 0 else {
            return ws.isMuted
        }
        
        guard s.contains(ws) else {
            
            return true
        }
        
        return ws.isMuted
    }
}

extension DJCommandTransformer {
    
    
    private static func addedPerformer(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> DJCommand? {
        
        guard let stem = to.audioStem else {
            
            return nil
        }
        
        let added = to.performers.subtract(from.performers)
        
        guard added.count > 0 else {
            
            return nil
        }
        
        return DJStartCommand(performer: added.first!, reference: stem.reference, muted: effectiveMute(workspace: to, solos: toSolos))
        
    }
    
    private static func removedPerformer(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> DJCommand? {
        
        let removed = from.performers.subtract(to.performers)
        
        guard let removed_performer = removed.first else {
            
            return nil
        }
        
        guard from.audioStem != nil else {
            
            return nil
        }
        
        return DJStopCommand(performer: removed_performer)
    }
}

extension DJCommandTransformer {
    
    private static func toAudioStem(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [DJCommand]? {
        
        
        guard from.audioStem == nil else {
            
            return nil
        }
        
        guard let audioStem = to.audioStem else {
            
            return nil
        }
        
        return to.performers.map() { DJStartCommand(performer: $0, reference: audioStem.reference, muted: effectiveMute(workspace: to, solos: toSolos)) }
    }
    
    private static func fromAudioStem(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [DJCommand]? {
        
        guard to.audioStem == nil else {
            return nil
        }
        
        guard from.audioStem != nil else {
            return nil
        }
        
        return to.performers.map() { DJStopCommand(performer: $0)}
    }
    
    private static func betweenAudioStems(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [DJCommand]? {
        
        guard let toStem = to.audioStem, fromStem = from.audioStem else {
            
            return nil
        }
        
        guard toStem.reference != fromStem.reference else {
            
            return nil
        }
        
        return to.performers.map() { DJStartCommand(performer: $0, reference: toStem.reference, muted: effectiveMute(workspace: to, solos: toSolos)) }
    }
    
}

extension DJCommandTransformer {
    
    private static func solo(from: Workspace, to: Workspace, fromSolos: Set<Workspace>, toSolos: Set<Workspace>) -> [DJCommand]? {
        
        guard toSolos.count != fromSolos.count else {
            
            return nil
        }
        
        let from_mut = effectiveMute(workspace: from, solos: fromSolos)
        let to_mut = effectiveMute(workspace: to, solos: toSolos)
        
        guard from_mut != to_mut else {
            
            return nil
        }
        
        return to_mut ? to.performers.map() { DJMuteCommand(performer: $0)} : to.performers.map() { DJUnmuteCommand(performer: $0) }
    }
    
    private static func mute(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [DJCommand]? {
        
        guard from.isMuted != to.isMuted else {
            
            return nil
        }
        
        let to_mut = effectiveMute(workspace: to, solos: toSolos)
        
        return to_mut ? to.performers.map() { DJMuteCommand(performer: $0)} : to.performers.map() { DJUnmuteCommand(performer: $0) }
    }
}

    /*
    private static func toAudioStem(from: Workspace, to: Workspace, toSolos: Set<Workspace>, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, referenceTimestamps: [String : NSTimeInterval]) -> [StartMessage]? {
        
        
        guard from.audioStem == nil else {
            
            return nil
        }
        
        guard let audioStem = to.audioStem else {
            
            return nil
        }
        
        return to.performers.map() {
            
            StartMessage(address: $0, timestamp: timestamp, reference: audioStem.reference, sessionTimestamp: sessionTimestamp, referenceTimestamp: referenceTimestamps[audioStem.reference]!, muted: effectiveMute(workspace: to, solos: toSolos))
        }
    }
    
    private static func fromAudioStem(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [StopMessage]? {
        
        guard to.audioStem == nil else {
            return nil
        }
        
        guard from.audioStem != nil else {
            return nil
        }
        
        return to.performers.map() { StopMessage(address: $0)}
    }
    
    private static func betweenAudioStems(from: Workspace, to: Workspace, toSolos: Set<Workspace>, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, referenceTimestamps: [String : NSTimeInterval]) -> [StartMessage]? {
        
        guard let toStem = to.audioStem, fromStem = from.audioStem else {
            return nil
        }
        
        guard toStem.reference != fromStem.reference else {
            return nil
        }
        
        return to.performers.map() {
            
            StartMessage(address: $0, timestamp: timestamp, reference: toStem.reference, sessionTimestamp: sessionTimestamp, referenceTimestamp: referenceTimestamps[toStem.reference]!, muted: effectiveMute(workspace: to, solos: toSolos))
        }
    }
 */

    /*
    private static func solo(from: Workspace, to: Workspace, fromSolos: Set<Workspace>, toSolos: Set<Workspace>) -> [Message]? {
        
        guard toSolos.count != fromSolos.count else {
            return nil
        }
        
        let from_mut = effectiveMute(workspace: from, solos: fromSolos)
        let to_mut = effectiveMute(workspace: to, solos: toSolos)
        
        guard from_mut != to_mut else {
            return nil
        }
        
        return to_mut ? to.performers.map() { MuteMessage(address: $0)} : to.performers.map() { UnmuteMessage(address: $0) }
    }
    
    private static func mute(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [Message]? {
        
        guard from.isMuted != to.isMuted else {
            return nil
        }
        
        let to_mut = effectiveMute(workspace: to, solos: toSolos)
        
        return to_mut ? to.performers.map() { MuteMessage(address: $0) } : to.performers.map() { UnmuteMessage(address: $0)}
    }
 */

    /*
    private static func addedPerformer(from: Workspace, to: Workspace, toSolos: Set<Workspace>, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, referenceTimestamps: [String : NSTimeInterval]) -> StartMessage? {
        
        guard let stem = to.audioStem else {
            
            return nil
        }
        
        let added = to.performers.subtract(from.performers)
        
        guard added.count > 0 else {
            
            return nil
        }
        
        return StartMessage(address: added.first!, timestamp: timestamp, reference: stem.reference, sessionTimestamp: sessionTimestamp, referenceTimestamp: referenceTimestamps[stem.reference]!, muted: effectiveMute(workspace: to, solos: toSolos))
    }
    
    private static func removedPerformer(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> StopMessage? {
        
        let removed = from.performers.subtract(to.performers)
        
        guard let removed_performer = removed.first else {
            
            return nil
        }
        
        guard from.audioStem != nil else {
            
            return nil
        }
        
        return StopMessage(address: removed_performer)
    }
 */

    /*
    static func transform(fromSuite: Suite, toSuite: Suite, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, referenceTimestamps: [String : NSTimeInterval]) -> [Message] {
        
        var messages: [Message] = []
        let fromTable = table(fromSuite)
        let solosTo = Set(toSuite.filter({$0.isSolo}))
        let solosFrom = Set(fromSuite.filter({$0.isSolo}))
        
        toSuite.forEach() {
            
            let from = fromTable[$0.identifier]!
            
            
            if let msg = addedPerformer(from, to: $0, toSolos: solosTo, timestamp: timestamp, sessionTimestamp: sessionTimestamp, referenceTimestamps: referenceTimestamps) {
                
                messages.append(msg)
            }
            
            if let msg = removedPerformer(from, to: $0, toSolos: solosTo) {
                
                messages.append(msg)
            }
            
            if let msgs = toAudioStem(from, to: $0, toSolos: solosTo, timestamp: timestamp, sessionTimestamp: sessionTimestamp, referenceTimestamps: referenceTimestamps) {
                
                msgs.forEach() { messages.append($0) }
            }
            
            if let msgs = fromAudioStem(from, to: $0, toSolos: solosTo) {
                
                msgs.forEach() { messages.append($0) }
            }
            
            if let msgs = betweenAudioStems(from, to: $0, toSolos: solosTo, timestamp: timestamp, sessionTimestamp: sessionTimestamp, referenceTimestamps: referenceTimestamps) {
            
                msgs.forEach() { messages.append($0) }
            }
            
            if let msgs = mute(from, to: $0, toSolos: solosTo) {
                
                msgs.forEach() { messages.append($0) }
            }
            
            if let msgs = solo(from, to: $0, fromSolos: solosFrom, toSolos: solosTo) {
                
                msgs.forEach() { messages.append($0) }
            }
        }
        
        return filter(messages)
    }
 */

/*
 private static func filter(messages: [Message]) -> [Message] {
 
 let precedence: Message -> Int = {
 
 switch  $0.type {
 case .Start: return 0
 case .Stop: return 1
 case .Mute: return 2
 case .Unmute: return 2
 }
 }
 
 var ptable: [Performer : Message] = [ : ]
 for m in messages {
 if let em = ptable[m.address] {
 if precedence(m) < precedence(em) {
 ptable[m.address] = m
 }
 } else {
 ptable[m.address] = m
 }
 }
 
 return Array(ptable.values)
 }
 */