//
//  MessageTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class MessageTransformer {
    
    static func transform(fromSuite: Suite, toSuite: Suite) -> [PerformerMessage] {
    
        let fromTable = table(fromSuite)
        var messages: [PerformerMessage] = []
        
        let solos = Set(toSuite.filter({$0.isSolo}))
        
        let solosBefore = Set(fromSuite.filter({$0.isSolo}))
        let effectiveMuteFrom: (ws: Workspace) -> Bool = { ws in
            
            guard solosBefore.count > 0 else {
                return ws.isMuted
            }
            
            guard solosBefore.contains(ws) else {
                
                return true
            }
            
            return ws.isMuted
        }
        
        let effectiveMuteTo: (ws: Workspace) -> Bool = { ws in
            
            guard solos.count > 0 else {
                return ws.isMuted
            }
            
            guard solos.contains(ws) else {
                
                return true
            }
            
            return ws.isMuted
        }
        
        for ws in toSuite {
            
            let from = fromTable[ws.identifier]!
            
            if solos.count != solosBefore.count {
                let frm = effectiveMuteFrom(ws: from)
                let to = effectiveMuteTo(ws: ws)
                if frm != to {
                    for p in ws.performers {
                        let message = PerformerMessage(address: p, timestamp: 1.0, sessionTimestamp: 1.1, reference: ws.audioStem!.reference,loopLength: ws.audioStem!.loopLength, command: .ToggleMute, muted: to)
                        messages.append(message)
                    }
                }
            }
            
            if let stem = ws.audioStem  {
                let added = ws.performers.subtract(from.performers)
                if added.count > 0 {
                    let message = PerformerMessage(address: added.first!, timestamp: 1.0, sessionTimestamp: 1.1, reference: stem.reference,loopLength: stem.loopLength, command: .Start, muted: effectiveMuteTo(ws: ws))
                    messages.append(message)
                }
                else{
                   let removed = from.performers.subtract(ws.performers)
                    if removed.count > 0 {
                        if let stem = from.audioStem  {
                            let message = PerformerMessage(address: removed.first!, timestamp: 1.0, sessionTimestamp: 1.1, reference: stem.reference,loopLength: stem.loopLength, command: .Stop, muted: effectiveMuteTo(ws: ws))
                            messages.append(message)
                        }
                    }
                }
                if from.audioStem == nil {
                    for p in ws.performers {
                        let message = PerformerMessage(address: p, timestamp: 1.0, sessionTimestamp: 1.1, reference: stem.reference,loopLength: stem.loopLength, command: .Start, muted: effectiveMuteTo(ws: ws))
                        messages.append(message)
                    }
                }
            }
            else {
                if from.audioStem != nil {
                    for p in ws.performers {
                        let message = PerformerMessage(address: p, timestamp: 1.0, sessionTimestamp: 1.1, reference: from.audioStem!.reference,loopLength: from.audioStem!.loopLength, command: .Stop, muted: effectiveMuteTo(ws: ws))
                        messages.append(message)
                    }
                }
            }
            if from.isMuted != ws.isMuted {
                for p in ws.performers {
                    let message = PerformerMessage(address: p, timestamp: 1.0, sessionTimestamp: 1.1, reference: ws.audioStem!.reference,loopLength: ws.audioStem!.loopLength, command: .ToggleMute, muted: effectiveMuteTo(ws: ws))
                    messages.append(message)
                }
            }
        }

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
    
    private static func table(suite: Suite) -> [String : Workspace] {
        
        var table: [String : Workspace] = [ : ]
        for ws in suite {
            table[ws.identifier] = ws
        }
        return table
    }
}
