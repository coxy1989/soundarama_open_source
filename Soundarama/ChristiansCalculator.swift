//
//  ChristiansCalculator.swift
//  Soundarama
//
//  Created by Jamie Cox on 14/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct ChristiansCalculator {
    
    static func calculateDelay(remoteTime: NSTimeInterval, localTime: NSTimeInterval, sessionTimestamp: NSTimeInterval, loopLength: NSTimeInterval) -> NSTimeInterval {
        
        let now = NSDate().timeIntervalSince1970
        let elapsed = now - localTime
        let remoteNow = remoteTime + elapsed
        
        // Calculate `nextStartTime` as a value equal to `timestamp` plus an integer multiple of `loopLength`
        // +0.1 is to make sure the audio player has enough time to prepare for playback
        
        var nextStartTime = sessionTimestamp
        
        while nextStartTime < remoteNow + 0.1 {
            nextStartTime += loopLength
        }
        
        return Double(nextStartTime) - Double(remoteNow)
    }
}


/*
extension PerformerInteractor {

func calculateDelay(message: PerformerMessage) -> NSTimeInterval {

let now = NSDate().timeIntervalSince1970
let elapsed = now - christiansMap!.local
let remoteNow = christiansMap!.remote + elapsed

// Calculate `nextStartTime` as a value equal to `timestamp` plus an integer multiple of `loopLength`
// +0.1 is to make sure the audio player has enough time to prepare for playback

var nextStartTime = message.sessionTimestamp

while nextStartTime < remoteNow + 0.1 {
nextStartTime += message.loopLength
}

return Double(nextStartTime) - Double(remoteNow)
}
}

*/