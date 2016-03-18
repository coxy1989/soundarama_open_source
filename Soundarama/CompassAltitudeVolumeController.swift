//
//  CompassAltitudeVolumeController.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

typealias Volume = Float
typealias Tag = String

enum AltitudeTag: String {
    
    case High = "Altitude:HIGH"
    
    case Middle = "Altitude:MIDDLE"
    
    case Low = "Altitude:LOW"
}

enum CompassTag: String {
    
    case North = "Compass:NORTH"
    
    case South = "Compass:SOUTH"
}

struct CompassAltitudeVolumeController {
    
    static let high_lower_limit: Double = 0.25
    
    static let high_upper_limit: Double = 0.26
    
    static let low_upper_limit: Double = -0.25
    
    static let low_lower_limit: Double = -0.26
    
    private static let contains_alt: (Set<String>, AltitudeTag) -> Bool = { $0.contains($1.rawValue) }
    
    private static let contains_com: (Set<String>, CompassTag) -> Bool = { $0.contains($1.rawValue) }

    static func calculateVolume(paths:Set<TaggedAudioPath>, compassValue: Double, altitudeValue: Double) -> [ TaggedAudioPath :  Volume ]{
    
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        interploateCompassHighAltitude(paths, compassValue: compassValue, altitudeValue: altitudeValue).forEach() { ret[$0] = $1 * 0.5 }
        
        interploateCompassMiddleAltitude(paths, compassValue: compassValue, altitudeValue: altitudeValue).forEach() { ret[$0] = $1 * 0.5 }
        
        interploateCompassLowAltitude(paths, compassValue: compassValue, altitudeValue: altitudeValue).forEach() { ret[$0] = $1 * 0.5 }
        
        return ret
    }
    
    private static func interploateCompassHighAltitude(paths:Set<TaggedAudioPath>, compassValue: Double, altitudeValue: Double) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        let n_high = paths.filter() { contains_alt($0.tags, .High) && contains_com($0.tags, .North) }
        
        let s_high = paths.filter() { contains_alt($0.tags, .High) && contains_com($0.tags, .South) }
        
        guard altitudeValue > high_lower_limit else {
            
            n_high.forEach() { ret[$0] = 0 }
            s_high.forEach() { ret[$0] = 0 }
            return ret
        }
        
        /* Interpolate between 360 == 0, 180 == 1, 90 == 0.5, 270 == 0.5 */
        
        let compass_transform = (1 - abs(compassValue - 180) / 180)
        
        /* Interpolate between high_lower_limit = 0, high_upper_limit = 1 (> high_upper_limit == 1) */
        
        let range = high_upper_limit - high_lower_limit
        
        let altitude_transform = min(1, (altitudeValue - high_lower_limit) / range)
        
        n_high.forEach() { ret[$0] =  Float( (1 - compass_transform) * altitude_transform) }
        
        s_high.forEach() { ret[$0] =  Float( compass_transform * altitude_transform) }
        
        return ret
    }
    
    private static func interploateCompassMiddleAltitude(paths:Set<TaggedAudioPath>, compassValue: Double, altitudeValue: Double) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        let n_mid = paths.filter() { contains_alt($0.tags, .Middle) && contains_com($0.tags, .North) }
        
        let s_mid = paths.filter() { contains_alt($0.tags, .Middle) && contains_com($0.tags, .South) }
        
        /* Interpolate between 360 == 0, 180 == 1, 90 == 0.5, 270 == 0.5 */
        
        let compass_transform = (1 - abs(compassValue - 180) / 180)
        
        n_mid.forEach() { ret[$0] =  Float(1 - compass_transform) }
        
        s_mid.forEach() { ret[$0] = Float(compass_transform) }
        
        return ret
    }
    
    private static func interploateCompassLowAltitude(paths:Set<TaggedAudioPath>, compassValue: Double, altitudeValue: Double) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        let n_low = paths.filter() { contains_alt($0.tags, .Low) && contains_com($0.tags, .North) }
        
        let s_low = paths.filter() { contains_alt($0.tags, .Low) && contains_com($0.tags, .South) }
        
        guard altitudeValue < low_upper_limit else {
            
            n_low.forEach() { ret[$0] = 0 }
            s_low.forEach() { ret[$0] = 0 }
            return ret
        }
        
        /* Interpolate between 360 == 0, 180 == 1, 90 == 0.5, 270 == 0.5 */
        
        let compass_transform = (1 - abs(compassValue - 180) / 180)
        
        /* Interpolate between low_upper_limit = 0, low_lower_limit = 1 (< low_lower_limit == 1) */
        
        let range = low_upper_limit - low_lower_limit
        
        
        
        let altitude_transform = min(1, (abs(altitudeValue) + low_upper_limit) / range)
        
        n_low.forEach() { ret[$0] =  Float( (1 - compass_transform) * altitude_transform) }
        
        s_low.forEach() { ret[$0] =  Float( compass_transform * altitude_transform) }
        
        return ret
    }
}

