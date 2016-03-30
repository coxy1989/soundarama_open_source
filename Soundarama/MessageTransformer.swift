//
//  MessageTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class DJMessageTransformer {
    
    static func transform(startCommand: DJStartCommand, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, referenceTimestamp: NSTimeInterval) -> StartMessage {
        
        return StartMessage(timestamp: timestamp, reference: startCommand.reference, sessionTimestamp: sessionTimestamp, referenceTimestamp: referenceTimestamp, muted: startCommand.muted)
    }
    
    static func transform(stopCommand: DJStopCommand) -> StopMessage {
        
        return StopMessage()
    }
    
    static func transform(muteCommand: DJMuteCommand) -> MuteMessage {
        
        return MuteMessage()
    }
    
    static func transform(unmuteCommand: DJUnmuteCommand) -> UnmuteMessage {
        
        return UnmuteMessage()
    }
}
