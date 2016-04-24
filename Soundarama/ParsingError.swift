//
//  ParsingError.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

/* Action Message */

//TODO: rename `action`MessageParsing

enum ParsingError: ErrorType {
    
    case FailedToUnarchiveJSON
    
    case InvalidJSON
    
    case InvalidStartMessage
    
    case InvalidMessage
}

enum SyncMessageParsingError: ErrorType {
    
    case FailedToUnarchiveJSON
    
    case InvalidJSON
    
    case InvalidMessage
}