//
//  CompassAltitudeVolumeController.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

typealias Volume = Float

struct CompassLevelVolumeController {
    
    private static let contains_alt: (Set<String>, LevelTag) -> Bool = { $0.contains($1.rawValue) }
    
    private static let contains_com: (Set<String>, CompassTag) -> Bool = { $0.contains($1.rawValue) }

    static func calculateVolume(paths:Set<TaggedAudioPath>, compassValue: Double, level: Level) -> [ TaggedAudioPath :  Volume ] {
    
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        interploateCompassHighLevel(paths, compassValue: compassValue, level: level).forEach() { ret[$0] = $1 }
        
        interploateCompassMiddleLevel(paths, compassValue: compassValue, level: level).forEach() { ret[$0] = $1 }
        
        interploateCompassLowLevel(paths, compassValue: compassValue, level: level).forEach() { ret[$0] = $1 }
        
        return ret
    }
    
    private static func interploateCompassHighLevel(paths:Set<TaggedAudioPath>, compassValue: Double, level: Level) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        let n_high = paths.filter() { contains_alt($0.tags, .High) && contains_com($0.tags, .North) }
        
        let s_high = paths.filter() { contains_alt($0.tags, .High) && contains_com($0.tags, .South) }
        
        guard level == .High else {
            
            n_high.forEach() { ret[$0] = 0 }
            s_high.forEach() { ret[$0] = 0 }
            return ret
        }
        
        /* Interpolate between 360 == 0, 180 == 1, 90 == 0.5, 270 == 0.5 */
        
        let compass_transform = (1 - abs(compassValue - 180) / 180)
        
        n_high.forEach() { ret[$0] =  Float( (1 - compass_transform)) }
        
        s_high.forEach() { ret[$0] =  Float( compass_transform) }
        
        
        return ret
    }
    
    private static func interploateCompassMiddleLevel(paths:Set<TaggedAudioPath>, compassValue: Double, level: Level) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        let n_mid = paths.filter() { contains_alt($0.tags, .Middle) && contains_com($0.tags, .North) }
        
        let s_mid = paths.filter() { contains_alt($0.tags, .Middle) && contains_com($0.tags, .South) }
        
        /* Interpolate between 360 == 0, 180 == 1, 90 == 0.5, 270 == 0.5 */
        
        let compass_transform = (1 - abs(compassValue - 180) / 180)
        
        n_mid.forEach() { ret[$0] =  Float(1 - compass_transform) }
        
        s_mid.forEach() { ret[$0] = Float(compass_transform) }
        
        return ret
    }
    
    private static func interploateCompassLowLevel(paths:Set<TaggedAudioPath>, compassValue: Double, level: Level) -> [ TaggedAudioPath :  Volume ] {
        
        var ret: [TaggedAudioPath : Volume] = [ : ]
        
        let n_low = paths.filter() { contains_alt($0.tags, .Low) && contains_com($0.tags, .North) }
        
        let s_low = paths.filter() { contains_alt($0.tags, .Low) && contains_com($0.tags, .South) }
        
        guard level == .Low else {
            
            n_low.forEach() { ret[$0] = 0 }
            s_low.forEach() { ret[$0] = 0 }
            return ret
        }
        
        /* Interpolate between 360 == 0, 180 == 1, 90 == 0.5, 270 == 0.5 */
        
        let compass_transform = (1 - abs(compassValue - 180) / 180)
        
        n_low.forEach() { ret[$0] =  Float(1 - compass_transform) }
        
        s_low.forEach() { ret[$0] =  Float(compass_transform) }
        
        return ret
    }
}

