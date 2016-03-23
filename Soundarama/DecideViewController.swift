//
//  DecideViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DecideViewController: UIViewController, DecideUserInterface {
    
    weak var delegate: DecideUserInterfaceDelegate!
    
    @IBAction func didTapPerformer(sender: AnyObject) {
        
        delegate.decideUserInterfaceDidSelectPerformer(self)
    }
    
    @IBAction func didTapDJ(sender: AnyObject) {
        
        delegate.decideUserInterfaceDidSelectDJ(self)
    }
}
