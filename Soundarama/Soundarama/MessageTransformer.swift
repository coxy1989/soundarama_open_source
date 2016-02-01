//
//  MessageTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class MessageTransformer {
    
    let timestamp: NSTimeInterval
    let sessionTimestamp: NSTimeInterval
    
    init(timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval) {
        
        self.timestamp = timestamp
        self.sessionTimestamp = sessionTimestamp
    }
    
    func transform(fromSuite: Suite, toSuite: Suite) -> [PerformerMessage] {
    
        var messages: [PerformerMessage] = []
        let fromTable = table(fromSuite)
        let solosTo = Set(toSuite.filter({$0.isSolo}))
        let solosFrom = Set(fromSuite.filter({$0.isSolo}))
        
        for ws in toSuite {
            let from = fromTable[ws.identifier]!
            messages.appendContentsOf(solo(from, to: ws, fromSolos: solosFrom, toSolos: solosTo))
            messages.appendContentsOf(performerAdd(from, to: ws, toSolos: solosTo))
            messages.appendContentsOf(performerRemove(from, to: ws, toSolos: solosTo))
            messages.appendContentsOf(toAudioStem(from, to: ws, toSolos: solosTo))
            messages.appendContentsOf(fromAudioStem(from, to: ws, toSolos: solosTo))
            messages.appendContentsOf(mute(from, to: ws, toSolos: solosTo))
            messages.appendContentsOf(betweenAudioStems(from, to: ws, toSolos: solosTo))
        }

        return filter(messages)
    }
}

extension MessageTransformer {
    
    private func filter(messages: [PerformerMessage]) -> [PerformerMessage] {
        
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
    
    private func table(suite: Suite) -> [String : Workspace] {
        
        var table: [String : Workspace] = [ : ]
        for ws in suite {
            table[ws.identifier] = ws
        }
        return table
    }
}

extension MessageTransformer {
    
    private func effectiveMute(workspace ws: Workspace, solos s: Set<Workspace>) -> Bool {
        
            guard s.count > 0 else {
                return ws.isMuted
            }
            
            guard s.contains(ws) else {
                
                return true
            }
            
            return ws.isMuted
    }
    
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
    
    private func performerAdd(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [PerformerMessage] {
        
        guard let stem = to.audioStem else {
            return []
        }
        
        let added = to.performers.subtract(from.performers)
        
        guard added.count > 0 else {
            return []
        }
        
        assert(added.count == 1)
        return [PerformerMessage(address: added.first!, timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: stem.reference,loopLength: stem.loopLength, command: .Start, muted: effectiveMute(workspace: to, solos: toSolos))]
    }
    
    private func performerRemove(from: Workspace, to: Workspace, toSolos: Set<Workspace>) -> [PerformerMessage] {
        
        let removed = from.performers.subtract(to.performers)
        
        guard removed.count > 0 else {
            return []
        }

        guard let stem = from.audioStem else {
            return []
        }
        
        return [PerformerMessage(address: removed.first!, timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: stem.reference,loopLength: stem.loopLength, command: .Stop, muted: effectiveMute(workspace: to, solos: toSolos))]
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

