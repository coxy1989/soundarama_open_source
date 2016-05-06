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
    
    /* Viper */
    
    weak var performerWireframe: PerformerWireframe!
        
    weak var pickDJInput: PerformerDJPickerInput!
    
    weak var instrumentsInput: PerformerInstrumentsInput!
    
    weak var instructionInput: PerformerInstructionInput!
    
    weak var connectionInput: PerformerConnectionInput!
    
    /* UI */
    
    weak var performerUserInterface: PerformerUserInterface?
    
    weak var pickDJUI: PickDJUserInterface?
    
    /* Lifecyle */
    
    private var close: (() -> ())!
    
    func start(navigationController: UINavigationController, close: () -> ()) {
        
        self.close = close
        performerWireframe.navigationController = navigationController
        //performerWireframe.presentDJPickerUI(self)
        performerWireframe.presentInstrumentsUI(self)
    }
    
    /* API */
    
    func requestShowInstruction(instruction: PerformerInstruction) {
        
        instructionInput.requestShowInstruction(instruction)
    }
    
    func requestHideInstruction(instruction: PerformerInstruction) {
    
        instructionInput.requestHideInstruction(instruction)
    }
}

extension PerformerPresenter: PerformerInstrumentsOutput {
    
    func setCurrentlyPerforming(name: String?) {
        
        performerUserInterface?.setCurrentlyPerforming(name)
    }
    
    func setCompassValue(value: Double) {
        
        performerUserInterface?.setCompassValue(value)
    }
    
    func setCharge(value: Double) {
        
        performerUserInterface?.setCharge(value)
    }
    
    func setColors(colors: [UIColor]) {
        
        performerUserInterface?.setColors(colors)
    }
    
    func setMuted(value: Bool) {
        
        performerUserInterface?.setMuted(value)
    }
}

extension PerformerPresenter: PerformerFlashingOutput {
    
    func startFlashing() {
        
        performerUserInterface?.startFlashing()
    }
    
    func stopFlashing() {
        
        performerUserInterface?.stopFlashing()
    }
    
    func flash(opacity: CGFloat, duration: NSTimeInterval) {
        
        performerUserInterface?.flash(opacity, duration: duration)
    }
}

extension PerformerPresenter: PerformerDJPickerOutput {
    
    func set(identifier: UIDJIdentifier?, state: ConnectionState, identifiers: [UIDJIdentifier], isReachable: Bool) {
     
        pickDJUI?.set(identifier, state: state, identifiers: identifiers, isReachable: isReachable)
        
        if state == .Connected && performerUserInterface == nil {
            
            performerWireframe.presentInstrumentsUI(self)
        }
    }
}

extension PerformerPresenter: PerformerReconnectionOutput {
    
    func updateWithReconnectionEvent(event: ReconnectionEvent) {
        
        performerUserInterface?.updateWithReconnectionEvent(event)
    }
}

extension PerformerPresenter: UserInterfaceDelegate {
    
    func userInterfaceWillAppear(userInterface: UserInterface) {
        
        if userInterface === pickDJUI {
            
            pickDJInput.startDJPickerInput()
        }
        
        if userInterface === performerUserInterface  {
            
            pickDJInput.stopDJPickerInput()
            instrumentsInput.startPerformerInstrumentInput()
        }
    }
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface) {
    
        if userInterface === pickDJUI {
            
            connectionInput.cancelConnect()
            pickDJInput.stopDJPickerInput()
            performerWireframe.dismissDJPickerUI()
            close()
        }
        
        else if userInterface === performerUserInterface {
            
            connectionInput.disconnect()
            instrumentsInput.stopPerfromerInstrumentInput()
            instructionInput.stopPerformerInstructionInput()
            performerWireframe.dismissInstrumentsUI(self)
        }
    }

    func userInterfaceDidLoad(userInterface: UserInterface) { }
    
    func userInterfaceDidAppear(userInterface: UserInterface) { }
}

extension PerformerPresenter: PickDJUserInterfaceDelegate {
    
    func didPickIdentifier(identifier: Int) {
        
        connectionInput.connect(identifier)
    }
}

extension PerformerPresenter: PerformerInstructionOutput {
    
    func showInstruction(instruction: PerformerInstruction) {
     
        performerUserInterface?.showInstruction(instruction)
    }
    
    func hideInstruction() {
        
        performerUserInterface?.hideInstruction()
    }
}

