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
    
    @IBAction func didPressPerformerButton(sender: AnyObject) {
        delegate.decideUserInterfaceDidSelectPerformer(self)
    }
    
    @IBAction func didPressDJButton(sender: AnyObject) {
        delegate.decideUserInterfaceDidSelectDJ(self)
    }
}
