//
//  PickDJUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol PickDJUserInterface: class {
    
    func set(identifier: UIDJIdentifier?, state: ConnectionState, identifiers: [UIDJIdentifier], isReachable: Bool)
}

protocol PickDJUserInterfaceDelegate: class {
    
    func didPickIdentifier(identifier: Int)
}