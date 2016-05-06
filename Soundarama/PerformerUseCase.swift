//
//  PerformerUseCase.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

/* Input */

protocol PerformerDJPickerInput: class {
    
    func startDJPickerInput()
    
    func stopDJPickerInput()
}

protocol PerformerInstrumentsInput: class {
    
    func startPerformerInstrumentInput()
    
    func stopPerfromerInstrumentInput()
}

protocol PerformerInstructionInput: class {
    
    func startPerformerInstructionInput()
    
    func stopPerformerInstructionInput()
    
    func requestShowInstruction(instruction: PerformerInstruction)
    
    func requestHideInstruction(instruction: PerformerInstruction)
}

protocol PerformerConnectionInput: class {
    
    func connect(identifier: Int)
    
    func disconnect()
    
    func cancelConnect()
}

/* Output */

protocol PerformerDJPickerOutput: class {
    
    func set(identifier: UIDJIdentifier?, state: ConnectionState, identifiers: [UIDJIdentifier], isReachable: Bool)
}

protocol PerformerInstrumentsOutput: class {
    
    func setCurrentlyPerforming(name: String?)
    
    func setCompassValue(value: Double)
    
    func setCharge(value: Double)
    
    func setColors(colors: [UIColor])
    
    func setMuted(value: Bool)
}

protocol PerformerFlashingOutput: class {
    
    func startFlashing()
    
    func stopFlashing()
    
    func flash(opacity: CGFloat, duration: NSTimeInterval)
}

protocol PerformerInstructionOutput: class {
    
    func showInstruction(instruction: PerformerInstruction)
    
    func hideInstruction()
}

protocol PerformerReconnectionOutput: class {
    
    func updateWithReconnectionEvent(event: ReconnectionEvent)
}
