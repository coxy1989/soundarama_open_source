//
//  PerformerModule.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class PerformerModule {
    
    let wireframe = PerformerWireframe()
    let presenter = PerformerPresenter()
    let interactor = PerformerInteractor()

    static func start(navigationController: UINavigationController, close: () -> ()) -> PerformerModule {
        
        let module = PerformerModule()
        module.start(navigationController, close: close)
        return module
    }
    
    private func start(navigationController: UINavigationController, close: () -> ()) {
        
        presenter.start(navigationController, close: close)
    }
    
    private init() {
        
        presenter.performerWireframe = wireframe
        presenter.instrumentsInput = interactor
        presenter.pickDJInput = interactor
        presenter.connectionInput = interactor
        interactor.performerDJPickerOutput = presenter
        interactor.performerInstrumentsOutput = presenter
        interactor.performerReconnectionOutput = presenter
    }
}
