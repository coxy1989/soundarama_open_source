//
//  PerformerPresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class PerformerPresenter: PerformerModule {
    
    weak var performerWireframe: PerformerWireframe!
    
    weak var compassUI: CompassUserInterface!
    
    weak var levelUI: LevelUserInterface!
   
    weak var coloredUI: ColoredUserInterface!
    
    weak var connectionUI: ConnectionUserInterface!
    
    weak var input: PerformerInput!
    
    func start(navigationController: UINavigationController) {
        
        performerWireframe.presentPerformerUI(navigationController)
    }
}

extension PerformerPresenter: PerformerOutput {
    
    func setConnectionState(state: ConnectionState) {
        
        connectionUI.setConnectionState(state)
    }

    func setCompassValue(value: Double) {
        
        compassUI.setCompassValue(value)
    }
    
    func setLevel(level: Level) {
        
        levelUI.setLevel(level)
    }
    
    func setColor(color: UIColor) {
        
        coloredUI.setColor(color)
    }
}

extension PerformerPresenter: UserInterfaceDelegate {
    
    func userInterfaceDidLoad(userInterface: UserInterface) {
        
        input.start()
    }
    
    func userInterfaceWillAppear(userInterface: UserInterface) { }
    
    func userInterfaceDidAppear(userInterface: UserInterface) { }
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface) { }
}