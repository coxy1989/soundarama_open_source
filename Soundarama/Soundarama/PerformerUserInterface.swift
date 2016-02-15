//
//  PerformerUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

protocol PerformerUserInterface: class {
    
    weak var delegate: PerformerUserInterfaceDelegate! { get set }
    
    func setConnectionState(state: ConnectionState)
    
    func setColour(colour: UIColor?)
}

protocol PerformerUserInterfaceDelegate: class {
    
    func ready()
}