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

protocol PerformerOutput: class {
    
    func setConnectionState(state: ConnectionState)
    
    func setCompassValue(value: Double)
    
    func setLevel(level: Level)
    
    func setColor(color: UIColor)
}

protocol PerformerDJPickerOutput: class {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool)
}
