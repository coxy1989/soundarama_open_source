//
//  MessageSerialisation.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

// TODO: Rename `ActionMessage` SerialisationKeys

struct MessageSerialisationKeys {
    
    static let type = "Type"
}

struct StartMessageSerialisationKeys {
    
    static let timestamp = "Timestamp"
    
    static let reference = "Reference"
    
    static let sessionTimestamp = "SessionTimestamp"
    
    static let referenceTimestamp = "ReferenceTimestamp"
    
    static let muted = "Muted"
}
