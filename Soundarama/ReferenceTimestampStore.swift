//
//  ReferenceTimestampStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

typealias Reference = String

class ReferenceTimestampStore {
    
    private var timestamps: [Reference : NSTimeInterval] = [ : ]
    
    func getTimestamp(reference: Reference) -> NSTimeInterval? {
        
        return timestamps[reference]
    }
    
    func setTimestamp(timestamp: NSTimeInterval, reference: Reference) {
        
        timestamps[reference] = timestamp
    }
}