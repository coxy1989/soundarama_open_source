//
//  VibrationStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 09/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import AudioToolbox

class VibrationStore {
    
    private var onWayUp = true
    
    func setValue(value: Double) {
        
        if value > 0.7 && onWayUp {
            
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            onWayUp = false
        }
        
        if value < 0.7 {
            
            onWayUp = true
        }
    }
}
