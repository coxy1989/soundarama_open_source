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
    
    weak var connectionInput: PerformerConnectionInput!
    
    weak var compassUI: CompassUserInterface?
    
    weak var coloredUI: ColoredUserInteface?
    
    weak var chargingUI: ChargingUserInteface?
    
    weak var reconnectionUI: ReconnectionUserInterface?
    
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
    
    func set(identifier: UIDJIdentifier?, state: ConnectionState, identifiers: [UIDJIdentifier], isReachable: Bool) {
     
        pickDJUI?.set(identifier, state: state, identifiers: identifiers, isReachable: isReachable)
        
        if state == .Connected && compassUI == nil {
            
            performerWireframe.presentInstrumentsUI(self)
        }
    }
}

extension PerformerPresenter: PerformerReconnectionOutput {
    
    func updateWithReconnectionEvent(event: ReconnectionEvent) {
        
        reconnectionUI?.updateWithReconnectionEvent(event)
    }
}

extension PerformerPresenter: UserInterfaceDelegate {
    
    func userInterfaceWillAppear(userInterface: UserInterface) {
        
        if userInterface === pickDJUI {
            
            pickDJInput.startDJPickerInput()
        }
        
        if userInterface === compassUI || userInterface === chargingUI {
            
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
        
        else if userInterface === compassUI || userInterface === chargingUI {
            
            connectionInput.disconnect()
            instrumentsInput.stopPerfromerInstrumentInput()
            performerWireframe.dismissInstrumentsUI(self)
        }
    }

    func userInterfaceDidLoad(userInterface: UserInterface) { }
    
    func userInterfaceDidAppear(userInterface: UserInterface) {}
}

extension PerformerPresenter: PickDJUserInterfaceDelegate {
    
    func didPickIdentifier(identifier: Int) {
        
        connectionInput.connect(identifier)
    }
}

