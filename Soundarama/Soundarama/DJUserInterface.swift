//
//  DJUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

typealias Performer = String

protocol DJUserInterface: class {
    
    weak var delegate: DJUserInterfaceDelegate! { get set }
    
    func addPerformer(performer: Performer)
    
    func removePerformer(performer: Performer)
}

protocol DJUserInterfaceDelegate: class {
    
    func ready()
    
    func didSelectAudioStemForPerformer(audioStem: AudioStem, performer: Performer)
}
