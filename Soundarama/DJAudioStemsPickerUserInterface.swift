//
//  DJAudioStemsPickerUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 07/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

protocol DJAudioStemPickerUserInterfaceDelegate: class {
    
    func didRequestSelectStem(ui: DJAudioStemPickerUserInterface, audioStemID: AudioStemID)
    
    func didRequestSetSelectedKey(ui: DJAudioStemPickerUserInterface, key: String)
}

protocol DJAudioStemPickerUserInterface: class {
    
    var keys: [String]! { get set }
    
    var colors: [String : UIColor]! { get set }
    
    var stemsIndex: [String : [String : Set<UIAudioStem>]]! { get set }
    
    var delegate: DJAudioStemPickerUserInterfaceDelegate! { get set }
    
    var identifier: String! { get set }
    
    func setSelectedKey(key: String)
}
