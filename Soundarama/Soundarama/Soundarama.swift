//
//  Soundarama.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

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
        performerInteractor.endpoint = dependencies.searchingEndpoint()
    }
    
    private func setupDjModule() {
        
        djPresenter.djWireframe = djWireframe
        djWireframe.djPresenter = djPresenter
        djPresenter.input = djInteractor
        djInteractor.djOutput = djPresenter
        djInteractor.endpoint = dependencies.broadcastingEndpoint()
    }
}
