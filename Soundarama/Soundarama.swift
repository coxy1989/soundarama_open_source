//
//  Soundarama.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Injection of internal VIPER dependencies */

import UIKit

class Soundarama {
    
    let dependencies: SoundaramaDependencies!
    
    private let decideWireframe: DecideWireframe!
    private let decidePresenter = DecidePresenter()
    private let decideInteractor = DecideInteractor()
    
    private let performerWireframe = PerformerWireframe()
    private let performerPresenter = PerformerPresenter()
    private let performerInteractor = PerformerInteractor()
    
    private let djWireframe = DJWireframe()
    private let djPresenter = DJPresenter()
    private let djInteractor = DJInteractor()
    
    init(window: UIWindow, dependencies: SoundaramaDependencies) {
    
        self.dependencies = dependencies
        decideWireframe = DecideWireframe(window: window)
        setupDecideModule()
        setupPerformerModule()
        setupDjModule()
    }
    
    func start() {
        
        decideWireframe.presentUI()
    }
}

extension Soundarama {
    
    private func setupDecideModule() {
        
        decideWireframe.performerModule = performerPresenter
        decideWireframe.djModule = djPresenter
        decideWireframe.decidePresenter = decidePresenter
        decidePresenter.decideWireframe = decideWireframe
    }
    
    private func setupPerformerModule() {
        
        performerPresenter.performerWireframe = performerWireframe
        performerWireframe.performerPresenter = performerPresenter
        performerPresenter.input = performerInteractor
        performerInteractor.performerOutput = performerPresenter
        performerInteractor.performerDJPickerOutput = performerPresenter
        performerPresenter.pickDJInput = performerInteractor
       // performerInteractor.endpoint = dependencies.searchingEndpoint()
    }
    
    private func setupDjModule() {
        
        djPresenter.djWireframe = djWireframe
        djWireframe.djPresenter = djPresenter
        djPresenter.djInput = djInteractor
        djPresenter.djAudioStemPickerInput = djInteractor
        djInteractor.djOutput = djPresenter
        djInteractor.djAudioStemPickerOutput = djPresenter
        djInteractor.djBroadcastConfigurationOutput = djPresenter
        djPresenter.djBroadcastConfigurationInput = djInteractor
    }
}
