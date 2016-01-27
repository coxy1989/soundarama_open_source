//
//  DJUseCase.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol DJInput: class {
    
    func start()
    
    func didSelectAudioStemForPerformer(audioStem: AudioStem, performer: Performer)
    
    func fetchAudioStems() -> [AudioStem]
}

protocol DJOutput: class {
    
    func addPerformer(performer: Performer)
    
    func removePerformer(performer: Performer)
}
