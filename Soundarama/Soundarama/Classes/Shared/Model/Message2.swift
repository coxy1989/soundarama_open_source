//
//  Message.swift
//  Soundarama
//
//  Created by Jamie Cox on 02/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation


/*
struct AudioStemMessage {
    
    enum Type: UInt {
        case Start = 0
        case Stop
    }
    
    let audioStemRef: String
    let timestamp: Double
    let sessionTimestamp: Double
    let loopLength: NSTimeInterval
    let type: Type

    init (audioStem: AudioStem, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, type: Type) {
        self.audioStemRef = audioStem.reference
        self.timestamp = timestamp
        self.loopLength = 1.75
        self.type = type
        self.sessionTimestamp = sessionTimestamp
    }
    
    
    init (audioStemRef: String, timestamp: NSTimeInterval, sessionTimestamp: NSTimeInterval, loopLength: NSTimeInterval, type: Type)
    {
        self.audioStemRef = audioStemRef
        self.timestamp = timestamp
        self.loopLength = loopLength
        self.type = type
        self.sessionTimestamp = sessionTimestamp
    }
    
    /*
    init?(data: NSData)
    {
        let mutable = data.mutableCopy() as! NSMutableData
        let range = NSMakeRange(mutable.length - MessageConstants.seperator.length, MessageConstants.seperator.length)
        mutable.replaceBytesInRange(range, withBytes: nil, length: 0)
        if let msg = NSKeyedUnarchiver.unarchiveObjectWithData(mutable) {
            if let  audioStemRef = msg["ref"] as? String,
            timestamp = msg["time"] as? Double,
            loopLength = msg["loopLength"] as? NSTimeInterval,
                typeVal = msg["type"] as? UInt,
                sessionStamp = msg["sessionStamp"] as? Double
            {
                    self.audioStemRef =  audioStemRef
                    self.timestamp = timestamp
                    self.loopLength = loopLength
                    self.type = Type(rawValue: typeVal)!
                    self.sessionStamp = sessionStamp
                
            } else {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func data() -> NSData
    {
        let dic = ["ref" : audioStemRef, "time" : timestamp, "sessionStamp" : sessionStamp, "loopLength" : loopLength, "type" : self.type.rawValue]
        let msg = NSKeyedArchiver.archivedDataWithRootObject(dic)
        let dat = msg.mutableCopy()
        dat.appendData(MessageConstants.seperator)
        return dat as! NSData
    }
*/
}
*/

/*
struct VolumeChangeMessage: Message
{
    let volume: Float
    let timestamp: Double
    
    init (volume: Float, timestamp: NSTimeInterval)
    {
        self.volume = volume
        self.timestamp = timestamp
    }
    
    init?(data: NSData)
    {
        let mutable = data.mutableCopy() as! NSMutableData
       // let range = NSMakeRange(mutable.length - MessageConstants.seperator.length, MessageConstants.seperator.length)
       // mutable.replaceBytesInRange(range, withBytes: nil, length: 0)
        if let msg = NSKeyedUnarchiver.unarchiveObjectWithData(mutable), volume = msg["volume"] as? Float, timestamp = msg["timestamp"] as? Double
        {
            self.volume = volume
            self.timestamp = timestamp
        }
        else
        {
            return nil
        }
    }
    
    func data() -> NSData
    {
        let dic = ["volume" : volume, "timestamp" : timestamp]
        let msg = NSKeyedArchiver.archivedDataWithRootObject(dic)
        let dat = msg.mutableCopy()
      //  dat.appendData(MessageConstants.seperator)
        return dat as! NSData
    }
}
*/