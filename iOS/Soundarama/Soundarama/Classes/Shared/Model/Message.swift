//
//  Message.swift
//  Soundarama
//
//  Created by Jamie Cox on 02/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

protocol Message
{
    var timestamp: Double { get }
    var loopLength: NSTimeInterval { get }
    func data() -> NSData
}

struct MessageConstants
{
    static let seperator = ";".dataUsingEncoding(NSUTF8StringEncoding)!
}

struct AudioStemMessage: Message
{
    enum Type: UInt
    {
        case Start = 0
        case Stop
    }
    
    let audioStemRef: String
    let timestamp: Double
    let loopLength: NSTimeInterval
    let type: Type

    init (audioStemRef: String, timestamp: NSTimeInterval, loopLength: NSTimeInterval, type: Type)
    {
        self.audioStemRef = audioStemRef
        self.timestamp = timestamp
        self.loopLength = loopLength
        self.type = type
    }
    
    init?(data: NSData)
    {
        let mutable = data.mutableCopy() as! NSMutableData
        let range = NSMakeRange(mutable.length - MessageConstants.seperator.length, MessageConstants.seperator.length)
        mutable.replaceBytesInRange(range, withBytes: nil, length: 0)
        if let msg = NSKeyedUnarchiver.unarchiveObjectWithData(mutable),
                audioStemRef = msg["audioStemRef"] as? String,
                    timestamp = msg["timestamp"] as? Double,
                        loopLength = msg["loopLength"] as? NSTimeInterval,
                            typeVal = msg["type"] as? UInt
        {
            self.audioStemRef =  audioStemRef
            self.timestamp = timestamp
            self.loopLength = loopLength
            self.type = Type(rawValue: typeVal)!
        }
        else
        {
            return nil
        }
    }
    
    func data() -> NSData
    {
        let dic = ["audioStemRef" : audioStemRef, "timestamp" : timestamp, "loopLength" : loopLength, "type" : self.type.rawValue]
        let msg = NSKeyedArchiver.archivedDataWithRootObject(dic)
        let dat = msg.mutableCopy()
        dat.appendData(MessageConstants.seperator)
        return dat as! NSData
    }
}
