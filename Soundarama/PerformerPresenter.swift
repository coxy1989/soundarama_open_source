//
//  PerformerPresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class PerformerPresenter: PerformerModule {
    
    weak var performerWireframe: PerformerWireframe!
    weak var ui: PerformerUserInterface!
    weak var input: PerformerInput!
    
    func start(navigationController: UINavigationController) {
        
        performerWireframe.presentPerformerUI(navigationController)
    }
}

extension PerformerPresenter: PerformerOutput {
    
    func connectionStateDidChange(state: ConnectionState) {
        
        ui.setConnectionState(state)
    }
    
    func audioStemDidChange(stem: AudioStem?) {
        
        ui.setColour(stem?.colour)
    }
}

extension PerformerPresenter: PerformerUserInterfaceDelegate {
    
    func ready() {
        
        input.start()
    }
}