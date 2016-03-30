//
//  TaggedAudioPathStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct TaggedAudioPathStore {
    
    static func taggedAudioPaths(reference: String) -> Set<TaggedAudioPath> {
        
        let altitude = ["HIGH", "MIDDLE", "LOW"]
        let direction = ["NORTH", "SOUTH"]
        
        let north = (0...altitude.count).map() { _ in (name: reference + "_\(direction[0])", tags: Set(["Compass:\(direction[0])"])) }
        let south = (0...altitude.count).map() { _ in (name: reference + "_\(direction[1])", tags: Set(["Compass:\(direction[1])"])) }
        
        let north_altitude = zip(north, altitude).map() { (name: $0.0 + "_\($1)", tags: $0.1.union(["Level:\($1)"])) }
        let south_altitude = zip(south, altitude).map() { (name: $0.0 + "_\($1)", tags: $0.1.union(["Level:\($1)"])) }
        let direction_altitude = north_altitude + south_altitude
        
        let tags_paths = direction_altitude.map() { (path: NSBundle.mainBundle().pathForResource($0, ofType: "wav", inDirectory: "Sounds")!, tags: $1)}
        
        
        return Set(tags_paths.map() { TaggedAudioPath(tags: $0.tags, path: $0.path, loopLength: 1.9512195122) })
    }
}
