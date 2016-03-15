//
//  AudioStem.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

typealias AudioStemID = String

func == (lhs: AudioStem, rhs: AudioStem) -> Bool {
    
    return lhs.name == rhs.name
        && lhs.colour == rhs.colour
        && lhs.category == rhs.category
        && lhs.reference == rhs.reference
        && lhs.loopLength == rhs.loopLength
}

struct AudioStem: Hashable {
    
    let name: String
    let colour: UIColor
    let category: String
    let reference: String /* TODO: Change to 'Identifier' */
    let loopLength: NSTimeInterval
    
    var audioFilePath: String {
        
        return NSBundle.mainBundle().pathForResource(self.reference, ofType: "wav", inDirectory: "Sounds")!
    }
    
    var hashValue: Int {
        
        return name.hashValue ^ colour.hashValue ^ category.hashValue ^ reference.hashValue ^ loopLength.hashValue
    }
}

struct UIAudioStem: Hashable {
    
    let title: String
    let subtitle: String
    let audioStemID: AudioStemID
    let colour: UIColor
    
    
    var hashValue: Int {
        
        return title.hashValue ^ subtitle.hashValue ^ audioStemID.hashValue
    }
}

func == (lhs: UIAudioStem, rhs: UIAudioStem) -> Bool {

    return lhs.title == rhs.title
        && lhs.subtitle == rhs.subtitle
        && lhs.audioStemID == rhs.audioStemID
}