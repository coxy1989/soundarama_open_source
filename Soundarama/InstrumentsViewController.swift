//
//  InstrumentsViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

protocol CompassUserInterface: class {
    
    func setCompassValue(value: Double)
}

class InstrumentsViewController: ViewController {
    
    @IBOutlet weak var compassView: UIView!
}

extension InstrumentsViewController: CompassUserInterface {
    
    func setCompassValue(value: Double) {
        
        let radians = CGFloat((M_PI * value) / 180)
                
        UIView.animateWithDuration(0.1) { [weak self] in
            
            self?.compassView.transform = CGAffineTransformMakeRotation(radians)
        }
    }
}
