//
//  PerformerPresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class PerformerPresenter {
    
    weak var performerWireframe: PerformerWireframe!
        
    weak var pickDJInput: PerformerDJPickerInput!
    
    weak var instrumentsInput: PerformerInstrumentsInput!
    
    weak var compassUI: CompassUserInterface?
    
    weak var coloredUI: ColoredUserInteface?
    
    weak var chargingUI: ChargingUserInteface?
    
    weak var pickDJUI: PickDJUserInterface?
    
    private var close: (() -> ())!
    
    func start(navigationController: UINavigationController, close: () -> ()) {
        
        self.close = close
        performerWireframe.navigationController = navigationController
        performerWireframe.presentDJPickerUI(self)
    }
}

extension PerformerPresenter: PerformerInstrumentsOutput {
    
    func setCompassValue(value: Double) {
        
        compassUI?.setCompassValue(value)
    }
    
    func setCharge(value: Double) {
        
        chargingUI?.setCharge(value)
    }
    
    func setColor(color: UIColor) {
        
        coloredUI?.setColor(color)
    }
}

extension PerformerPresenter: PerformerDJPickerOutput {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool) {
     
        pickDJUI?.set(identifier, state: state, identifiers: identifiers, isReachable: isReachable)
        
        if state == .Connected && compassUI == nil {
            
            performerWireframe.presentInstrumentsUI(self)
        }
    }
}

extension PerformerPresenter: UserInterfaceDelegate {
    
    func userInterfaceDidLoad(userInterface: UserInterface) {
        
        if userInterface === compassUI || userInterface === chargingUI {
            
            instrumentsInput.startPerformerInstrumentInput()
        }
    }
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface) {
    
        if userInterface === pickDJUI {
            
            performerWireframe.dismissDJPickerUI()
            close()
        }
        
        else if userInterface === compassUI || userInterface === chargingUI {
            
            pickDJInput.stopDJPickerInput()
            instrumentsInput.stopPerfromerInstrumentInput()
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

