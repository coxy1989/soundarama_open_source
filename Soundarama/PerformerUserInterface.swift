//
//  PerformerUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 19/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol CompassUserInterface: class {
    
    func setCompassValue(value: Double)
}

protocol ColoredUserInteface: class {
    
    func setColor(color: UIColor)
}

protocol ChargingUserInteface: class {
    
    func setCharge(value: Double)
}

protocol ReconnectionUserInterface: class {
    
    func updateWithReconnectionEvent(event: ReconnectionEvent)
}

protocol PickDJUserInterface: class {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool)
}

protocol PickDJUserInterfaceDelegate: class {
    
    func didPickIdentifier(identifier: String)
}
