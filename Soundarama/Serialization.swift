//
//  Serialisation.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Result

enum SerializationError: ErrorType {
    
    case FailedToDeserialiseJSON
}

struct Serialization {
    
    static let terminator = ";".dataUsingEncoding(NSUTF8StringEncoding)!
    
    static func getJSON(data: NSData) -> Result<AnyObject, SerializationError> {
        
        let dat = data.mutableCopy()
        let range = NSMakeRange(data.length - Serialization.terminator.length, Serialization.terminator.length)
        dat.replaceBytesInRange(range, withBytes: nil, length: 0)
        
        do {
            
            let json = try NSJSONSerialization.JSONObjectWithData(dat as! NSData , options: NSJSONReadingOptions.AllowFragments)
            return Result<AnyObject, SerializationError>.Success(json)
        }
            
        catch {
            
            debugPrint("FUCK")
            return Result<AnyObject, SerializationError>.Failure(.FailedToDeserialiseJSON)
        }
    }
}
