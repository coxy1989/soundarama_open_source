//
//  DJAudioStemsPickerUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 07/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

protocol DJAudioStemPickerUserInterfaceDelegate: class {
    
    func djAudioStemsUserInterfaceDidSelectStem(audioStemUI: DJAudioStemPickerUserInterface, audioStemID: AudioStemID)
}

protocol DJAudioStemPickerUserInterface: class {
    
    var keys: [String]! { get set }
    
    var colors: [String : UIColor]! { get set }
    
    var stemsIndex: [String : Set<UIAudioStem>]! { get set }
    
    var delegate: DJAudioStemPickerUserInterfaceDelegate! { get set }
    
    var identifier: String! { get set }
}
