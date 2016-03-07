//
//  DJAudioStemsPickerUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 07/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol DJAudioStemsPickerUserInterfaceDelegate: class {
    
    func djAudioStemsUserInterfaceDidSelectStem(audioStemUI: DJAudioStemPickerUserInterface, audioStemID: AudioStemID)
}

protocol DJAudioStemPickerUserInterface: class {
    
    var audioStems: Set<UIAudioStem> { get set }
    
    var delegate: DJAudioStemsPickerUserInterfaceDelegate! { get set }
    
    var identifier: String! { get set }
}
