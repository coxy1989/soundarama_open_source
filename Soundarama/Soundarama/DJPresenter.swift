//
//  DJPresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJPresenter: DJModule {
    
    weak var djWireframe: DJWireframe!
    weak var ui: DJUserInterface!
    weak var input: DJInput!
    
    func start(navigationController: UINavigationController) {
        
        djWireframe.presentDjUI(navigationController)
    }
}

extension DJPresenter: DJOutput {
    
    func addPerformer(performer: Performer) {
        
        ui.addPerformer(performer)
    }
    
    func removePerformer(performer: Performer) {
        
        ui.removePerformer(performer)
    }
}

extension DJPresenter: DJUserInterfaceDelegate {
    
    func ready() {
        
        input.start()
    }
    
    func didSelectAudioStemForPerformer(audioStem: AudioStem, performer: Performer) {
        
        input.didSelectAudioStemForPerformer(audioStem, performer: performer)
    }
}
