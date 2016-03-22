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

class Swishometer {
    
    let accellerometer: Accellerometer
    
    private var values: [Double] = []
    
    init(accellerometer: Accellerometer) {
        
        self.accellerometer = accellerometer
    }
    
    func start(handler: Direction -> ()) {
        
        accellerometer.start() { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.values.append($0.z)
            
            let last40 = this.values.suffix(40)
            
            let triggeredDown = last40.filter() { $0 > 0.5 }.count >= 1
            
            let triggeredDown2 = last40.map() { $0 > 0 }.filter({ $0 == true}).count >= 20
            
            let triggeredUp = last40.filter() { $0 < -0.5 }.count >= 1
            
            let triggeredUp2 = last40.map() { $0 < 0 }.filter({ $0 == true}).count >= 20
            
            if triggeredDown && triggeredDown2 {
                
                handler(.Down)
            }
            
            if triggeredUp && triggeredUp2 {
                
                handler(.Up)
            }
            
            if this.values.count > 40 {
             
                this.values = Array(last40)
            }
        }
    }
}