//
//  Flickometer.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class Flickometer {
    
    let accellerometer: Accellerometer
    
    init(accellerometer: Accellerometer) {
        
        self.accellerometer = accellerometer
    }
    
    func start(handler: Direction -> ()) {
       
        accellerometer.start() {
            
            var v: Double?
            
            if $0.z >= 0 {
                v = ($0.z + (0.3 * sqrt(pow($0.x, 2) + pow($0.y, 2))))
            } else {
                v = ($0.z - (0.3 * sqrt(pow($0.x, 2) + pow($0.y, 2))))
            }
            
            if v > 2.5 {
                
                handler(.Down)
            }
            
            if v < -2.5 {
                
                handler(.Up)
            }
        }
    }
}