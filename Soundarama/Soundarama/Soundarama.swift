//
//  Soundarama.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class Soundarama {
    
    let decideWireframe: DecideWireframe!
    let decidePresenter = DecidePresenter()
    var decideInteractor = DecideInteractor()
    
    let performerWireframe = PerformerWireframe()
    let performerPresenter = PerformerPresenter()
    let performerInteractor = PerformerInteractor()
    
    let djWireframe = DJWireframe()
    let djPresenter = DJPresenter()
    let djInteractor = DJInteractor()
    
    init(window: UIWindow) {
    
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
    }
    
    private func setupDjModule() {
        
        djPresenter.djWireframe = djWireframe
        djWireframe.djPresenter = djPresenter
        djPresenter.input = djInteractor
        djInteractor.djOutput = djPresenter
    }
}
