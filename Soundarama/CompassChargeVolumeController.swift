//
//  CompassChargeVolumeController.swift
//  Soundarama
//
//  Created by Jamie Cox on 13/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

struct CompassChargeVolumeController {
    
    static func calculateVolume(paths:Set<TaggedAudioPath>, compassValue: Double, charge: Double, threshold: Double) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        interpolateCompassLT(paths, compassValue: compassValue, charge: charge, threshold: threshold).forEach() { ret[$0] = $1 }
        
        interpolateCompassGT(paths, compassValue: compassValue, charge: charge, threshold: threshold).forEach() { ret[$0] = $1 }
        
        return ret
    }
    
    private static func interpolateCompassLT(paths:Set<TaggedAudioPath>, compassValue: Double, charge: Double, threshold: Double) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        
        let n_lt = paths.filter() { $0.tags.contains(ChargeTag.LT.rawValue) && $0.tags.contains(CompassTag.North.rawValue) }
        
        let s_lt = paths.filter() { $0.tags.contains(ChargeTag.LT.rawValue) && $0.tags.contains(CompassTag.South.rawValue) }
        
        guard charge < threshold else {
            
            n_lt.forEach() { ret[$0] = 0 }
            s_lt.forEach() { ret[$0] = 0 }
            return ret
        }
        
        /* Interpolate between 360 == 0, 180 == 1, 90 == 0.5, 270 == 0.5 */
        
        let compass_transform = (1 - abs(compassValue - 180) / 180)
        
        n_lt.forEach() { ret[$0] =  Float( (1 - compass_transform)) }
        
        s_lt.forEach() { ret[$0] =  Float( compass_transform) }
        
        return ret
    }
    
    private static func interpolateCompassGT(paths:Set<TaggedAudioPath>, compassValue: Double, charge: Double, threshold: Double) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        
        let n_gt = paths.filter() { $0.tags.contains(ChargeTag.GT.rawValue) && $0.tags.contains(CompassTag.North.rawValue) }
        
        let s_gt = paths.filter() { $0.tags.contains(ChargeTag.GT.rawValue) && $0.tags.contains(CompassTag.South.rawValue) }
        
        guard charge > threshold else {
            
            n_gt.forEach() { ret[$0] = 0 }
            s_gt.forEach() { ret[$0] = 0 }
            return ret
        }
        
        /* Interpolate between 360 == 0, 180 == 1, 90 == 0.5, 270 == 0.5 */
        
        let compass_transform = (1 - abs(compassValue - 180) / 180)
        
        n_gt.forEach() { ret[$0] =  Float( (1 - compass_transform)) }
        
        s_gt.forEach() { ret[$0] =  Float( compass_transform) }
        
        return ret
    }
}