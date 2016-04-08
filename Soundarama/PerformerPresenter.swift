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
    
    weak var performerInput: PerformerInput!
    
    weak var pickDJInput: PerformerDJPickerInput!
    
    weak var instrumentsInput: PerformerInstrumentsInput!
    
    weak var compassUI: CompassUserInterface?
    
    weak var levelUI: LevelUserInterface?
   
    weak var coloredUI: ColoredUserInterface?
    
    weak var connectionUI: ConnectionUserInterface?
    
    weak var pickDJUI: PickDJUserInterface?
    
    func start(navigationController: UINavigationController) {
        
        performerWireframe.presentDJPickerUI(navigationController)
    }
}

extension PerformerPresenter: PerformerOutput {
    
    func setConnectionState(state: ConnectionState) {
        
        connectionUI?.setConnectionState(state)
    }
}

extension PerformerPresenter: PerformerInstrumentsOutput {
    
    func setCompassValue(value: Double) {
        
        compassUI?.setCompassValue(value)
    }
    
    func setLevel(level: Level) {
        
        levelUI?.setLevel(level)
    }
    
    func setColor(color: UIColor) {
        
        coloredUI?.setColor(color)
    }
}

extension PerformerPresenter: PerformerDJPickerOutput {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool) {
     
        pickDJUI?.set(identifier, state: state, identifiers: identifiers, isReachable: isReachable)
    }
}

extension PerformerPresenter: UserInterfaceDelegate {
    
    func userInterfaceDidLoad(userInterface: UserInterface) {
        
        if userInterface === pickDJUI {
            
            pickDJInput.startDJPickerInput()
        }
        
        else {
            
            instrumentsInput.startPerformerInstrumentInput()
        }
    }
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface) {
    
        if userInterface === pickDJUI {
            
            performerWireframe.dismissDJPickerUI()
        }
        
        else {
            performerWireframe.dismissInstrumentsUI()
            performerInput.stop()
        }
    }
    
    func userInterfaceWillAppear(userInterface: UserInterface) { }
    
    func userInterfaceDidAppear(userInterface: UserInterface) {}
}

extension PerformerPresenter: PickDJUserInterfaceDelegate {
    
    func didPickIdentifier(identifier: String) {
        
        pickDJInput.pickIdentifier(identifier)
    }
}

extension PerformerPresenter: ConnectionUserInterfaceDelegate {
    
    // TODO: fuck this.
    
    func didRequestConfigureConnection() {
        
         // performerWireframe.presentDJPickerUI()
        
    }
}
