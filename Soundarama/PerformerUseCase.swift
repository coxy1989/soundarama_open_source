//
//  PerformerUseCase.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol PerformerInput: class {
    
    func start()
}

protocol PerformerOutput: class {
    
    func setConnectionState(state: ConnectionState)
    
    func setCompassValue(value: Double)
    
    func setLevel(level: Level)
}
