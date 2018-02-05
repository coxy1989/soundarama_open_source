//
//  DecidePresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DecidePresenter { //: DecideModule {
    
    weak var decideWireframe: DecideWireframe!
    
    var decision: ((Decision, UINavigationController) -> ())!
    
    func start(decision: (Decision, UINavigationController) -> ()) {
        
        self.decision = decision
        decideWireframe.presentUI(self)
    }
}

extension DecidePresenter: DecideUserInterfaceDelegate {
    
    func decideUserInterfaceDidSelectDJ(decideUserInterface: DecideUserInterface) {
        
        decision(.DJ, decideWireframe.navigationController)
    }
    
    func decideUserInterfaceDidSelectPerformer(decideUserInterface: DecideUserInterface) {
        
        decision(.Performer, decideWireframe.navigationController)
    }
}
