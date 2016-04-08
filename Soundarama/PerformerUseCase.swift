//
//  PerformerUseCase.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

protocol PerformerInput: class {
    
    func start()
    
    func stop()
}

protocol PerformerDJPickerInput: class {
    
    func startDJPickerInput()
    
    func pickIdentifier(identifier: String)
}

protocol PerformerInstrumentsInput: class {
    
    func startPerformerInstrumentInput()
}

protocol PerformerOutput: class {
    
    //TODO: fuck this?
    
    func setConnectionState(state: ConnectionState)
}

protocol PerformerDJPickerOutput: class {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool)
}

protocol PerformerInstrumentsOutput: class {
    
    func setCompassValue(value: Double)
    
    func setLevel(level: Level)
    
    func setColor(color: UIColor)
}
