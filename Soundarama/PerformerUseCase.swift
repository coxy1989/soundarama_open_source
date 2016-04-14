//
//  PerformerUseCase.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

protocol PerformerDJPickerInput: class {
    
    func startDJPickerInput()
    
    func stopDJPickerInput()
    
    func pickIdentifier(identifier: String)
}

protocol PerformerInstrumentsInput: class {
    
    func startPerformerInstrumentInput()
    
    func stopPerfromerInstrumentInput()
}

protocol PerformerDJPickerOutput: class {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool)
}

protocol PerformerInstrumentsOutput: class {
    
    func setCompassValue(value: Double)
    
    func setCharge(value: Double)
    
    func setColor(color: UIColor)
}
