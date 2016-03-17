//
//  CompassAltitudeVolumeController.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

typealias Volume = Float
typealias Tag = String

struct CompassAltitudeVolumeController {
    
    private static let contains_middle: Set<String> -> Bool = { $0.contains(AltitudeTag.Middle.rawValue) }
    
    private static let contains_north: Set<String> -> Bool = { $0.contains(CompassTag.North.rawValue) }
    
    private static let contains_south: Set<String> -> Bool = { $0.contains(CompassTag.South.rawValue) }
    
    static func calculateVolume(paths:Set<TaggedAudioPath>, compassValue: Double, altitudeValue: Double) -> [ TaggedAudioPath :  Volume ]{
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        let n_mid = paths.filter() { contains_middle($0.tags) && contains_north($0.tags) }
        
        let s_mid = paths.filter() { contains_middle($0.tags) && contains_south($0.tags) }
        
        let n_transform = (1 - abs(compassValue - 180) / 180)
        
        paths.forEach() { ret[$0] = 0 }
        
        n_mid.forEach() { ret[$0] =  Float(1 - n_transform) }
        
        s_mid.forEach() { ret[$0] = Float(n_transform) }
        
        return ret
    }
}

enum AltitudeTag: String {
    
    case High = "Altitude:HIGH"
    
    case Middle = "Altitude:MIDDLE"
    
    case Low = "Altitude:LOW"
}

enum CompassTag: String {
    
    case North = "Compass:NORTH"
    
    case South = "Compass:SOUTH"
}