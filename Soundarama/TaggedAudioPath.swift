//
//  TaggedAudioPath.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct TaggedAudioPath: Hashable {
    
    let tags: Set<String>
    let path: String
    let loopLength: NSTimeInterval
    
    var hashValue: Int {
        
        return tags.hashValue ^ path.hashValue ^ loopLength.hashValue
    }
}

func == (lhs: TaggedAudioPath, rhs: TaggedAudioPath) -> Bool {
    
    return lhs.tags == rhs.tags &&
            lhs.path == rhs.path &&
            lhs.loopLength == rhs.loopLength
}
