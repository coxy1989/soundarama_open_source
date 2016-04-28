//
//  Serialisation.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct Serialisation {
    
    static let terminator = ";".dataUsingEncoding(NSUTF8StringEncoding)!
        
    static func setPayload(object: AnyObject) -> NSData {
        
        let dat = NSKeyedArchiver.archivedDataWithRootObject(object).mutableCopy()
        dat.appendData(Serialisation.terminator)
        return dat as! NSData
    }
    
    static func getPayload(data: NSData) -> NSData {
        
        let payload = data.mutableCopy() as! NSMutableData
        let range = NSMakeRange(payload.length - Serialisation.terminator.length, Serialisation.terminator.length)
        payload.replaceBytesInRange(range, withBytes: nil, length: 0)
        return payload
    }
}
