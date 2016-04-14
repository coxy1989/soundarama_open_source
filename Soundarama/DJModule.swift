//
//  DJModule.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJModule {
    
    let wireframe = DJWireframe()
    let presenter = DJPresenter()
    let interactor = DJInteractor()
    
    static func start(navigationController: UINavigationController, close: () -> ()) -> DJModule {
        
        let module = DJModule()
        module.start(navigationController, close: close)
        return module
    }
    
    private init() {
        
        wireframe.djPresenter = presenter
        presenter.djWireframe = wireframe
        presenter.djInput = interactor
        presenter.djAudioStemPickerInput = interactor
        presenter.djBroadcastConfigurationInput = interactor
        interactor.djOutput = presenter
        interactor.djAudioStemPickerOutput = presenter
        interactor.djBroadcastConfigurationOutput = presenter
    }
    
    func start(navigationController: UINavigationController, close: () -> ()) {
        
        presenter.start(navigationController, close: close)
    }
}
