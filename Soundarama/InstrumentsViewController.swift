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

protocol ColoredUserInteface: class {
    
    func setColor(color: UIColor)
}

protocol ChargingUserInteface: class {
    
    func setCharge(value: Double)
}

class InstrumentsViewController: ViewController {
        
    @IBOutlet weak var dashedCircleView: BorderedCircleView?
    @IBOutlet weak var compassView: CompassView?
    @IBOutlet weak var circleView: UIView?

    @IBAction func didPressBackButton(sender: AnyObject) { userInterfaceDelegate?.userInterfaceDidNavigateBack(self)}
    
    var dirtyCalibrated = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dashedCircleView!.transform = CGAffineTransformMakeScale(0.7, 0.7)
        circleView!.layer.cornerRadius = circleView!.frame.size.width * 0.5
        circleView!.clipsToBounds = true
        setCharge(0)
    }
}

extension InstrumentsViewController: ChargingUserInteface {
 
    func setCharge(value: Double) {
        
        UIView.animateWithDuration(0.1) { [weak self] in
            
            if value > 0.7 {
                self?.dashedCircleView?.setColor(UIColor.redColor())
            }
            else {
                self?.dashedCircleView?.setColor(UIColor.whiteColor())
            }
            let v = CGFloat(value)
            self?.circleView?.transform = CGAffineTransformMakeScale(v, v)
        }
    }
}

extension InstrumentsViewController: ColoredUserInteface {
    
    func setColor(color: UIColor) {
        
        compassView?.setColor(color)
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
