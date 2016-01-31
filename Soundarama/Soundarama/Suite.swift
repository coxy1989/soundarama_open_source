//
//  Suite.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

typealias Performer = String

typealias Suite = Set<Workspace>

func == (lhs: Workspace, rhs: Workspace) -> Bool {
    
    return lhs.identifier == rhs.identifier
}

func == (lhs: AudioStem, rhs: AudioStem) -> Bool {
    
    return lhs.name == rhs.name
    && lhs.colour == rhs.colour
    && lhs.category == rhs.category
    && lhs.reference == rhs.reference
    && lhs.loopLength == rhs.loopLength
}

struct Workspace: Hashable {
    
    let identifier: String
    let audioStem: AudioStem?
    let performers: Set<Performer>
    let isMuted: Bool
    let isSolo: Bool
    let isAntiSolo: Bool
    
    var hashValue: Int {
        
        return identifier.hash
    }
}

struct AudioStem {
    
    let name: String
    let colour: UIColor
    let category: String
    let reference: String
    let loopLength: NSTimeInterval
    
    var audioFilePath: String? {
        
        return NSBundle.mainBundle().pathForResource(self.reference, ofType: "wav", inDirectory: "Sounds") ?? nil
    }
}