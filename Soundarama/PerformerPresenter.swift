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
        
    weak var pickDJInput: PerformerDJPickerInput!
    
    weak var instrumentsInput: PerformerInstrumentsInput!
    
    weak var compassUI: CompassUserInterface?
    
    weak var levelUI: LevelUserInterface?
    
    weak var coloredUI: ColoredUserInteface?
    
    weak var chargingUI: ChargingUserInteface?
    
    weak var pickDJUI: PickDJUserInterface?
    
    func start(navigationController: UINavigationController) {
        
        performerWireframe.navigationController = navigationController
        //performerWireframe.presentDJPickerUI(self)
        performerWireframe.presentInstrumentsUI(self)
    }
}

extension PerformerPresenter: PerformerInstrumentsOutput {
    
    func setCompassValue(value: Double) {
        
        compassUI?.setCompassValue(value)
    }
    
    func setCharge(value: Double) {
        
        chargingUI?.setCharge(value)
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
        
        if state == .Connected {
            
            performerWireframe.presentInstrumentsUI(self)
        }
    }
}

extension PerformerPresenter: UserInterfaceDelegate {
    
    func userInterfaceDidLoad(userInterface: UserInterface) {
        
        if userInterface === compassUI || userInterface === levelUI {
            
            instrumentsInput.startPerformerInstrumentInput()
        }
    }
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface) {
    
        if userInterface === pickDJUI {
            
            performerWireframe.dismissDJPickerUI()
        }
        
        else if userInterface === compassUI || userInterface === levelUI {
            
            pickDJInput.stopDJPickerInput()
            performerWireframe.dismissInstrumentsUI(self)
        }
    }
    
    func userInterfaceWillAppear(userInterface: UserInterface) {
        
        if userInterface === pickDJUI {
            
            pickDJInput.startDJPickerInput()
        }
    }
    
    func userInterfaceDidAppear(userInterface: UserInterface) {}
}

extension PerformerPresenter: PickDJUserInterfaceDelegate {
    
    func didPickIdentifier(identifier: String) {
        
        pickDJInput.pickIdentifier(identifier)
    }
}

