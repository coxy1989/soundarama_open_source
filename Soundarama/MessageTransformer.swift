//
//  MessageTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class DJMessageTransformer {
    
    static func transform(startCommand: DJStartCommand, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, referenceTimestamp: NSTimeInterval) -> StartActionMessage {
        
        return StartActionMessage(timestamp: timestamp, reference: startCommand.reference, sessionTimestamp: sessionTimestamp, referenceTimestamp: referenceTimestamp, muted: startCommand.muted)
    }
    
    static func transform(stopCommand: DJStopCommand) -> StopActionMessage {
        
        return StopActionMessage()
    }
    
    static func transform(muteCommand: DJMuteCommand) -> MuteActionMessage {
        
        return MuteActionMessage()
    }
    
    static func transform(unmuteCommand: DJUnmuteCommand) -> UnmuteActionMessage {
        
        return UnmuteActionMessage()
    }
}
