//
//  StateMessage.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import Result

struct StateMessage {
    
    let suite: Suite
    
    let performer: Performer
    
    let referenceTimestamps: [Reference : NSTimeInterval]
    
    let timestamp: NSTimeInterval
}
