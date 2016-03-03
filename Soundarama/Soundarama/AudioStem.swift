//
//  AudioStem.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

func == (lhs: AudioStem, rhs: AudioStem) -> Bool {
    
    return lhs.name == rhs.name
        && lhs.colour == rhs.colour
        && lhs.category == rhs.category
        && lhs.reference == rhs.reference
        && lhs.loopLength == rhs.loopLength
}

struct AudioStem {
    
    let name: String
    let colour: UIColor
    let category: String
    let reference: String
    let loopLength: NSTimeInterval
    
    var audioFilePath: String {
        
        return NSBundle.mainBundle().pathForResource(self.reference, ofType: "wav", inDirectory: "Sounds")!
    }
}