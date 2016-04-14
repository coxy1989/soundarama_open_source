//
//  DecideModule.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

enum Decision {
    
    case DJ, Performer
}

class DecideModule {
    
    private let wireframe: DecideWireframe
    
    private let presenter: DecidePresenter = DecidePresenter()
    
    static func start(window:UIWindow, decision: (Decision, UINavigationController) -> ()) -> DecideModule {
        
        let m = DecideModule(window: window, decision: decision)
        m.start(decision)
        return m
    }
    
    private init(window: UIWindow, decision: (Decision, UINavigationController) -> ()) {
    
        wireframe = DecideWireframe(window: window)
        presenter.decideWireframe = wireframe
    }
    
    private func start(decision: (Decision, UINavigationController) -> ()) {
        
        presenter.start(decision)
    }
}
