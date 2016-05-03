//
//  InstructionView.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class InstructionView: UIView {
    
    var dismissAction: (() -> ())?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func didPressCloseButton(sender: AnyObject) {
        
        dismissAction?()
    }
}
