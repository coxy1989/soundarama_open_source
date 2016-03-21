//
//  Level.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

enum Level {
    
    case High, Middle, Low
    
    func levelUp() -> Level {
        
        switch self {
            
        case .High:
            
            return .High
            
        case .Middle:
            
            return .High
            
        case .Low:
            
            return .Middle
        }
    }
    
    func levelDown() -> Level {
        
        switch self {
            
        case .High:
            
            return .Middle
            
        case .Middle:
            
            return .Low
            
        case .Low:
            
            return .Low
        }
    }
}