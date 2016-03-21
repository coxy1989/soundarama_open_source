//
//  Accelerometer.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CoreMotion

class MotionService {
    
    static let manager = CMMotionManager()
}

class Accellerometer {
    
    private let queue = NSOperationQueue()
    
    private let motionManager: CMMotionManager
    
    init(motionManager: CMMotionManager) {
        
        self.motionManager = motionManager
    }
    
    func start(handler:(x: Double, y: Double, z: Double) -> ()) {
        
        motionManager.startDeviceMotionUpdatesToQueue(queue) { d in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let ua = d.0?.userAcceleration else {
                    return
                }
                
                handler((x:ua.x, y:ua.y, z:ua.z))
            }
        }
    }
}