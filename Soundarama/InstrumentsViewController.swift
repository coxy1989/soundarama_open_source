//
//  InstrumentsViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

protocol LevelUserInterface: class {
    
    func setLevel(level: Level)
}

protocol CompassUserInterface: class {
    
    func setCompassValue(value: Double)
}

class InstrumentsViewController: ViewController {
    
    @IBOutlet weak var compassView: UIView!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
}

extension InstrumentsViewController: LevelUserInterface {
    
    func setLevel(level: Level) {
        
        switch level {
            
        case .High:
            
            highLabel.hidden = false
            middleLabel.hidden = true
            lowLabel.hidden = true
            
        case .Middle:
            
            highLabel.hidden = true
            middleLabel.hidden = false
            lowLabel.hidden = true
            
        case .Low:
            
            highLabel.hidden = true
            middleLabel.hidden = true
            lowLabel.hidden = false
        }
    }
}

extension InstrumentsViewController: CompassUserInterface {
    
    func setCompassValue(value: Double) {
        
        let radians = CGFloat((M_PI * value) / 180)
                
        UIView.animateWithDuration(0.1) { [weak self] in
            
            self?.compassView.transform = CGAffineTransformMakeRotation(radians)
        }
    }
}
