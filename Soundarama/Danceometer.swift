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
        
        accellerometer.start() { [unowned self] in
            
            let v = sqrt(pow($0.x, 2) + pow($0.y, 2) + pow($0.z, 2))
            
            let charge_thresh: Double = 1
            
            let gravity = 0.001
            
            let resistance: Double = 100
            
            if v > charge_thresh {
                
                self.score = min(1, self.score + ((v - charge_thresh) / resistance))
            }
            
            else {
                
                self.score = max(0, self.score - gravity)
            }
            
            //debugPrint(self.score)
            handler(self.score)
        }
    }
}
