//
//  Message.swift
//  Soundarama
//
//  Created by Jamie Cox on 02/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

struct Message {
    
    static let seperator = ";".dataUsingEncoding(NSUTF8StringEncoding)!
    
    let soundID: UInt
    let timestamp: Double
    let loopLength: NSTimeInterval

    
    init (soundID: UInt, timestamp: NSTimeInterval, loopLength: NSTimeInterval) {
        self.soundID = soundID
        self.timestamp = timestamp
        self.loopLength = loopLength
    }
    
    init? (data: NSData) {
        let mutable = data.mutableCopy() as! NSMutableData
        let range = NSMakeRange(mutable.length - Message.seperator.length, Message.seperator.length)
        mutable.replaceBytesInRange(range, withBytes: nil, length: 0)
        if let msg = NSKeyedUnarchiver.unarchiveObjectWithData(mutable) {
            soundID =  UInt(msg.valueForKey("soundID") as! Int)
            timestamp = msg.valueForKey("timestamp") as! Double
            loopLength = msg.valueForKey("loopLength") as! NSTimeInterval
        }
        else {
            print("INVALID MESSAGE")
            return nil
        }
    }
    
    func data() -> NSData {
        let dic = ["soundID" : soundID, "timestamp" : timestamp, "loopLength" : loopLength]
        let msg = NSKeyedArchiver.archivedDataWithRootObject(dic)
        let dat = msg.mutableCopy()
        dat.appendData(Message.seperator)
        return dat as! NSData
    }
}
