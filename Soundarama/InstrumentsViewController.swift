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

protocol ColoredUserInteface: class {
    
    func setColor(color: UIColor)
}

protocol ChargingUserInteface: class {
    
    func setCharge(value: Double)
}

class InstrumentsViewController: ViewController {
        
    @IBOutlet weak var dashedCircleView: UIView!
    @IBOutlet weak var compassView: LevelCompassView!
    @IBOutlet weak var circleView: UIView!

    @IBAction func didPressBackButton(sender: AnyObject) { userInterfaceDelegate?.userInterfaceDidNavigateBack(self)}
    
    var dirtyCalibrated = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dashedCircleView.transform = CGAffineTransformMakeScale(0.5, 0.5)
        circleView.layer.cornerRadius = circleView.frame.size.width * 0.5
        circleView.clipsToBounds = true
        setCharge(0)
    }
}

extension InstrumentsViewController: ChargingUserInteface {
 
    func setCharge(value: Double) {
        
        UIView.animateWithDuration(0.1) { [unowned self] in
            
            let v = CGFloat(max(value, 0.1))
            self.circleView.transform = CGAffineTransformMakeScale(v, v)
        }
    }
}

extension InstrumentsViewController: ColoredUserInteface {
    
    func setColor(color: UIColor) {
        
        
    }
}

extension InstrumentsViewController: LevelUserInterface {
    
    func setLevel(level: Level) {
    
    }
}

extension InstrumentsViewController: CompassUserInterface {
    
    func setCompassValue(value: Double) {
        
        
        let radians = CGFloat((M_PI * value) / 180)
        
        guard dirtyCalibrated == true else {
            
            compassView?.transform = CGAffineTransformMakeRotation(-radians)
            dirtyCalibrated = true
            return
        }
        
        UIView.animateWithDuration(0.1) { [weak self] in
        
            self?.compassView?.transform = CGAffineTransformMakeRotation(-radians)
        }
    }
}
