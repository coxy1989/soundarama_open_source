//
//  MessageTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class MessageTransformer {
    
    static func transform(fromSuite: Suite, toSuite: Suite, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, referenceTimestamps: [String : NSTimeInterval]) -> [Message] {
        
        // TODO: SANITY CHECK -> CRASH if any stems without a reference timestamp.
    
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
            //messages.appendContentsOf(solo(from , to: ws, fromSolos: solosFrom, toSolos: solosTo))
            //messages.appendContentsOf(performerAdd(from, to: ws, toSolos: solosTo))
            //messages.appendContentsOf(performerRemove(from, to: ws, toSolos: solosTo))
            //messages.appendContentsOf(toAudioStem(from, to: ws, toSolos: solosTo))
            //messages.appendContentsOf(fromAudioStem(from, to: ws, toSolos: solosTo))
            //messages.appendContentsOf(betweenAudioStems(from, to: ws, toSolos: solosTo))
            //messages.appendContentsOf(mute(from, to: ws, toSolos: solosTo))
        }
        
        return filter(messages)
    }
}

extension MessageTransformer {
    
    
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

extension MessageTransformer {
    
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
}

extension MessageTransformer {
    
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
}

extension MessageTransformer {
    
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
        
        /*
        var messages: [Message] = []
        if from.isMuted != to.isMuted {
            for p in to.performers {
                let message = PerformerMessage(address: p, timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: to.audioStem!.reference,loopLength: to.audioStem!.loopLength, command: .ToggleMute, muted: effectiveMute(workspace: to, solos: toSolos))
                messages.append(message)
            }
        }
        return messages
 */
    }
}

/*
extension MessageTransformer {
 
    private func solo(from: Workspace, to: Workspace, fromSolos: Set<Workspace>, toSolos: Set<Workspace>) -> [PerformerMessage] {
        
        guard toSolos.count != fromSolos.count else {
            return []
        }
        
        let from_mut = effectiveMute(workspace: from, solos: fromSolos)
        let to_mut = effectiveMute(workspace: to, solos: toSolos)
        
        guard from_mut != to_mut else {
            return []
        }
        
        return to.performers.map({ PerformerMessage(address: $0, timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: to.audioStem!.reference,loopLength: to.audioStem!.loopLength, command: .ToggleMute, muted: to_mut) })
    }
    
    private func toAudioStem(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [PerformerMessage] {
        
        guard from.audioStem == nil else {
            return []
        }
        
        guard let audioStem = to.audioStem else {
            return []
        }
        
        return to.performers.map({PerformerMessage(address: $0, timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: audioStem.reference,loopLength: audioStem.loopLength, command: .Start, muted: effectiveMute(workspace: to, solos: toSolos))})
    }
    
    private func fromAudioStem(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [PerformerMessage] {
        
        guard to.audioStem == nil else {
            return []
        }
        
        guard let audioStem = from.audioStem else {
            return []
        }
        
        return to.performers.map({ PerformerMessage(address: $0, timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: audioStem.reference,loopLength: audioStem.loopLength, command: .Stop, muted: effectiveMute(workspace: to, solos: toSolos))})
    }
    
    private func betweenAudioStems(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [PerformerMessage] {
        
        guard let toStem = to.audioStem, fromStem = from.audioStem else {
            return []
        }
        
        guard toStem.reference != fromStem.reference else {
            return []
        }
        
        return to.performers.map({ PerformerMessage(address: $0, timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: toStem.reference,loopLength: toStem.loopLength, command: .Stop, muted: effectiveMute(workspace: to, solos: toSolos))})
    }
    
    private func mute(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [PerformerMessage] {
        
        var messages: [PerformerMessage] = []
        if from.isMuted != to.isMuted {
            for p in to.performers {
                let message = PerformerMessage(address: p, timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: to.audioStem!.reference,loopLength: to.audioStem!.loopLength, command: .ToggleMute, muted: effectiveMute(workspace: to, solos: toSolos))
                messages.append(message)
            }
        }
        return messages
    }
}

*/

/*
 private static func filter(messages: [PerformerMessage]) -> [PerformerMessage] {
 
 var ptable: [Performer : PerformerMessage] = [ : ]
 for m in messages {
 if let em = ptable[m.address] {
 if m.command.rawValue < em.command.rawValue {
 ptable[m.address] = m
 }
 } else {
 ptable[m.address] = m
 }
 }
 
 return Array(ptable.values)
 }
 */