//
//  CompassAltitudeVolumeController.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

typealias Volume = Double

struct CompassAltitudeVolumeController {
    
    static let altitude_tags = ["Altitude:HIGH", "Altitude:MIDDLE", "Altitude:LOW"]
    
    static let direction_tags = ["Compass:0", "Compass:1"]
    
    static func calculateVolume(paths:Set<TaggedAudioPath>, compassValue: Double, altitudeValue: Double) -> [ TaggedAudioPath :  Volume ]{
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        paths.forEach() { ret[$0] = 0 }
        
        return ret
    }
}