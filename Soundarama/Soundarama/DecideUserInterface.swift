//
//  DecideUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol DecideUserInterface {
    
    weak var delegate: DecideUserInterfaceDelegate! { get set }
}

protocol DecideUserInterfaceDelegate: class {
    
    func decideUserInterfaceDidSelectPerformer(decideUserInterface: DecideUserInterface)
    
    func decideUserInterfaceDidSelectDJ(decideUserInterface: DecideUserInterface)
}