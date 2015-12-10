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

struct AudioStemStopMessage: Message
{
    let timestamp: Double
    let loopLength: NSTimeInterval
    
    init (timestamp: NSTimeInterval, loopLength: NSTimeInterval)
    {
        self.timestamp = timestamp
        self.loopLength = loopLength
    }
    
    init?(data: NSData)
    {
        let mutable = data.mutableCopy() as! NSMutableData
        let range = NSMakeRange(mutable.length - MessageConstants.seperator.length, MessageConstants.seperator.length)
        mutable.replaceBytesInRange(range, withBytes: nil, length: 0)
        if let msg = NSKeyedUnarchiver.unarchiveObjectWithData(mutable),
                _ = msg["audioStemStop"] as? Bool,
                    timestamp = msg["timestamp"] as? Double,
                        loopLength = msg["loopLength"] as? NSTimeInterval
        {
            //Valid stop message
            self.timestamp = timestamp
            self.loopLength = loopLength
        }
        else
        {
            return nil
        }
    }
    
    func data() -> NSData
    {
        let dic = ["audioStemStop" : true, "timestamp" : timestamp, "loopLength" : loopLength]
        let msg = NSKeyedArchiver.archivedDataWithRootObject(dic)
        let dat = msg.mutableCopy()
        dat.appendData(MessageConstants.seperator)
        return dat as! NSData
    }
}

struct AudioStemStartMessage: Message
{
    let audioStemRef: String
    let timestamp: Double
    let loopLength: NSTimeInterval

    init (audioStemRef: String, timestamp: NSTimeInterval, loopLength: NSTimeInterval)
    {
        self.audioStemRef = audioStemRef
        self.timestamp = timestamp
        self.loopLength = loopLength
    }
    
    init?(data: NSData)
    {
        let mutable = data.mutableCopy() as! NSMutableData
        let range = NSMakeRange(mutable.length - MessageConstants.seperator.length, MessageConstants.seperator.length)
        mutable.replaceBytesInRange(range, withBytes: nil, length: 0)
        if let msg = NSKeyedUnarchiver.unarchiveObjectWithData(mutable),
                audioStemRef = msg["audioStemRef"] as? String,
                    timestamp = msg["timestamp"] as? Double,
                        loopLength = msg["loopLength"] as? NSTimeInterval
        {
            self.audioStemRef =  audioStemRef
            self.timestamp = timestamp
            self.loopLength = loopLength
        }
        else
        {
            return nil
        }
    }
    
    func data() -> NSData
    {
        let dic = ["audioStemRef" : audioStemRef, "timestamp" : timestamp, "loopLength" : loopLength]
        let msg = NSKeyedArchiver.archivedDataWithRootObject(dic)
        let dat = msg.mutableCopy()
        dat.appendData(MessageConstants.seperator)
        return dat as! NSData
    }
}
