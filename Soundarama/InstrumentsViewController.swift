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
        
    @IBOutlet weak var levelCompassView: LevelCompassView!

    @IBAction func didPressBackButton(sender: AnyObject) { userInterfaceDelegate?.userInterfaceDidNavigateBack(self)}
    
    var dirtyCalibrated = false
}

extension InstrumentsViewController: LevelUserInterface {
    
    func setLevel(level: Level) {
        
        levelCompassView.setLevel(level)
        
        switch level {
            
        case .High:
            
            debugPrint("H")
            
        case .Middle:
            
            debugPrint("M")
            
        case .Low:
            
            debugPrint("L")
        }
    }
}

extension InstrumentsViewController: CompassUserInterface {
    
    func setCompassValue(value: Double) {
        
        let radians = CGFloat((M_PI * value) / 180)
        
        guard dirtyCalibrated == true else {
            
            levelCompassView.transform = CGAffineTransformMakeRotation(-radians)
            dirtyCalibrated = true
            return
        }
        
        UIView.animateWithDuration(0.1) { [weak self] in
        
            self?.levelCompassView.transform = CGAffineTransformMakeRotation(-radians)
        }
 
    }
}
