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
    
    weak var pickDJUI: PickDJUserInterface?
    
    weak var input: PerformerInput!
    
    weak var pickDJInput: PerformerDJPickerInput!
    
    func start(navigationController: UINavigationController) {
        
        performerWireframe.presentInstrumentsUI(navigationController)
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

extension PerformerPresenter: PerformerDJPickerOutput {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool) {
     
        pickDJUI?.set(identifier, state: state, identifiers: identifiers, isReachable: isReachable)
    }
}

extension PerformerPresenter: UserInterfaceDelegate {
    
    func userInterfaceDidLoad(userInterface: UserInterface) {
        
        //TODO: Fixme
        if userInterface !== pickDJUI {
        
            input.start()
        }
        
        else  {
            
             pickDJInput.startDJPickerInput()
        }
    }
    
    func userInterfaceWillAppear(userInterface: UserInterface) { }
    
    func userInterfaceDidAppear(userInterface: UserInterface) {}
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface) {
    
        if userInterface === pickDJUI {
            
            performerWireframe.dismissDJPickerUI()
        }
        
        else {
            performerWireframe.dismissInstrumentsUI()
            input.stop()
        }
    }
}

extension PerformerPresenter: PickDJUserInterfaceDelegate {
    
    func didPickIdentifier(identifier: String) {
        
        pickDJInput.pickIdentifier(identifier)
    }
}

extension PerformerPresenter: ConnectionUserInterfaceDelegate {
    
    func didRequestConfigureConnection() {
        
          performerWireframe.presentDJPickerUI()
        
    }
}
