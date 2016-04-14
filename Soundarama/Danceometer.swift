//
//  Danceometer.swift
//  Soundarama
//
//  Created by Jamie Cox on 12/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class Danceometer {

    let accellerometer: Accellerometer
    
    var score: Double = 0
    
    init(accellerometer: Accellerometer) {
        
        self.accellerometer = accellerometer
    }
    
    func start(handler: Double -> ()) {
        
        accellerometer.start() { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            let v = sqrt(pow($0.x, 2) + pow($0.y, 2) + pow($0.z, 2))
            
            var charge_thresh: Double = 1
            
            var gravity = 0.0004
            
            if this.score < 0.7 {
                
                gravity = 0.001
            }
            
            let resistance: Double = 1700 * max(0.05, pow(this.score,2))
            
            if this.score < 0.15 {
                
                charge_thresh = 0.25
            }
                
            else {
                
                charge_thresh = 1.0
            }
            
            let time = NSDate().timeIntervalSince1970
            
            if this.score < 0.03 {
                this.score = this.score + abs(sin(time)/15 * 20 * v)
            }
            
            if v > charge_thresh {
                
                this.score = min(1, (this.score + ((v - charge_thresh) / resistance)))
            
            }
            
            else {
                
                this.score = max(0, this.score - gravity)
            }
            
            debugPrint("s:\(this.score), v = \(v)")
            
            handler(max(this.score,0))
        }
    }
}
