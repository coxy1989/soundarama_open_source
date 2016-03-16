//
//  AudioStemStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

typealias CategoryKey = String

typealias SongKey = String

class AudioStemStore {
    
    var index: [CategoryKey : [SongKey : Set<AudioStem>]]!
    
    static let firstKey = union
    
    static let keys = [union] + categories
    
    static let colors = ["All" : UIColor.whiteColor(),
                        "Bass" : UIColor(rgba: "#6DAABD"),
                        "Instrument" : UIColor(rgba: "#BD8371"),
                        "Lead" : UIColor(rgba: "#71BD83"),
                        "Pad" : UIColor(rgba: "#BD71A2"),
                        "Rhythm" : UIColor(rgba: "#8371BD")]
    
    private static let union = "All"
    
    private static let categories = ["Bass", "Instrument", "Lead", "Pad", "Rhythm"]
    
    private var cache: [String : AudioStem]!
    
    init() {
        
        let stems = fetchStems()
        cache = cacheStems(stems)
        index = indexStems(stems)
    }
    
    func audioStem(reference: String) -> AudioStem? {
        
        return cache[reference]
    }
}

extension AudioStemStore {
    
    private func indexStems(stems: [AudioStem]) -> [CategoryKey : [SongKey : Set<AudioStem>]] {
        
        var idx: [String : [String : Set<AudioStem>]] = [ : ]
        let songMap = fetchSongs()
        
        var songidx: [SongKey : Set<AudioStem>] = [ : ]
        songMap.forEach() { s, ids in
            
            let stems = ids.map() { cache[$0]! }
            songidx[s] = Set(stems)
        }
        
        idx[AudioStemStore.union] = songidx
        
        AudioStemStore.categories.forEach() { c in
            
            var songidx: [SongKey : Set<AudioStem>] = [ : ]
            songMap.forEach() { s, ids in
                
                let stems = ids.map() { cache[$0]! }.filter() { $0.category == c }
                songidx[s] = Set(stems)
            }
            
            idx[c] = songidx
        }
        
        return idx
    }
    
    private func cacheStems(stems: [AudioStem]) -> [String : AudioStem] {
        
        var map: [String : AudioStem] = [ : ]
        stems.forEach() { s in map[s.reference] = s }
        return map
    }
    
    private func fetchSongs() -> [String : Set<AudioStemID>] {
        
        var map: [String : Set<AudioStemID>] = [ : ]
        let jsonPath = NSBundle.mainBundle().pathForResource("AudioStems", ofType: "json", inDirectory: "Sounds")!
        let data = NSData(contentsOfFile: jsonPath)!
        let json = JSON(data: data)
        let songJSON = json["Songs"].dictionary!
        songJSON.keys.forEach() { k in map[k] = Set(songJSON[k]!.array!.map() { return $0.string! }) }
        return map
    }
    
    private func fetchStems() -> [AudioStem] {
        
        let jsonPath = NSBundle.mainBundle().pathForResource("AudioStems", ofType: "json", inDirectory: "Sounds")!
        let data = NSData(contentsOfFile: jsonPath)!
        let json = JSON(data: data)
        return fetchAllStemsWithJSON(json)
    }
    
    private func fetchAllStemsWithJSON(json: JSON) -> [AudioStem] {
        
        var audioStems: [AudioStem] = []
        let audioStemJsons = json["AudioStems"].array!
        for audioStemJson in audioStemJsons {
            let stem = audioStem(audioStemJson)!
            audioStems.append(stem)
        }
        return audioStems
    }
    
    private func audioStem(json: JSON) -> AudioStem? {
        
        if let  name = json["Name"].string, colourString = json["Colour"].string, category = json["Category"].string, reference = json["Ref"].string {
            let colour = UIColor(rgba: colourString, defaultColor: UIColor.grayColor())
            return AudioStem(name: name, colour: colour, category: category, reference: reference, loopLength: 1.875)
        }
        else {
            return nil
        }
    }
}
