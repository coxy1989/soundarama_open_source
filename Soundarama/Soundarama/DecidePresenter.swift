//
//  DecidePresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class DecidePresenter: DecideUserInterfaceDelegate {
    
    weak var decideWireframe: DecideWireframe!
    
    func decideUserInterfaceDidSelectDJ(decideUserInterface: DecideUserInterface) {
        decideWireframe.decide(.DJ)
    }
    
    func decideUserInterfaceDidSelectPerformer(decideUserInterface: DecideUserInterface) {
        decideWireframe.decide(.Performer)
    }
}
