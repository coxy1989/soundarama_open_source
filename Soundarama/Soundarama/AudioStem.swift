//
//  AudioStem.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

struct AudioStem {
    
    let name: String
    let colour: UIColor
    let category: String
    let reference: String
    
    
    var audioFilePath: String? {
        
        return NSBundle.mainBundle().pathForResource(self.reference, ofType: "wav", inDirectory: "Sounds") ?? nil
    }
}