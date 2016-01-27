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
        
        //input.start()
        ui.addPerformer("x")
    }
    
    func didSelectAudioStemForPerformer(audioStem: AudioStem, performer: Performer, muted: Bool) {
        
        print("Selected audio stem muted: \(muted)")
        // TODO: mute
        //input.didSelectAudioStemForPerformer(audioStem, performer: performer)
    }
    
    func didMutePerformer(performer: Performer) {
        print("Muted performer")
    }
    
    func didDeselectAudioStemForPerformer(performer: Performer) {
        print("Deselected audio stem")
    }
}

extension DJPresenter: DJUserInterfaceDataSource {
    
    func audioStems() -> [AudioStem] {
        
        return input.fetchAudioStems()
    }
}
