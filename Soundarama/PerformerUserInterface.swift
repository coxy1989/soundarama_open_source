//
//  PerformerUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 19/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol PerformerUserInterface: CurrentlyPerformingUserInterface, CompassUserInterface, ColoredUserInteface, ChargingUserInteface, ReconnectionUserInterface, PerformerInstructionUserInterface, FlashingUserinterface {}

protocol FlashingUserinterface: class {
    
    func startFlashing()
    
    func stopFlashing()
    
    func flash(opacity: CGFloat, duration: NSTimeInterval)
}

protocol CurrentlyPerformingUserInterface: class {
    
    func setCurrentlyPerforming(name: String?)
}

protocol CompassUserInterface: class {
    
    func setCompassValue(value: Double)
    
    func setCompassActive(value: Bool)
}

protocol ChargingUserInteface: class {
    
    func setCharge(value: Double)
    
    func setChargeActive(value: Bool)
}

protocol ColoredUserInteface: class {
    
    func setColors(colours: [UIColor])
}

protocol ReconnectionUserInterface: class {
    
    func updateWithReconnectionEvent(event: ReconnectionEvent)
}

protocol PerformerInstructionUserInterface {
    
    func showInstruction(instruction: PerformerInstruction)
    
    func hideInstruction()
}
