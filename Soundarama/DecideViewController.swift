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
    
    @IBOutlet weak var djLabel: UILabel!
    
    @IBOutlet weak var performerLabel: UILabel!
    
    @IBOutlet weak var aboutButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        debugPrint(NSLocalizedString("DECIDE_DJ", comment: ""))
        debugPrint("DECIDE_DJ".localizedString)
        djLabel.text = "DECIDE_DJ".localizedString
        performerLabel.text = "DECIDE_PERFORMER".localizedString
        aboutButton.setTitle("ABOUT".localizedString, forState: .Normal)
    }
}
