//
//  AudioStemStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class AudioStemStore {
    
    var index: [String : Set<AudioStem>]!
    
    static let keys = [union] + categories
    
    static let colors = ["All" : UIColor.redColor(),
                        "Bass" : UIColor.greenColor(),
                        "Instrument" : UIColor.blueColor(),
                        "Lead" : UIColor.yellowColor(),
                        "Pad" : UIColor.orangeColor(),
                        "Rhythm" : UIColor.purpleColor()]
    
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
    
    private func indexStems(stems: [AudioStem]) -> [String : Set<AudioStem>] {
        
        var idx: [String : Set<AudioStem>] = [ : ]
        idx[AudioStemStore.union] = Set(stems)
        AudioStemStore.categories.forEach() { k in idx[k] = Set(stems.filter({ $0.category == k })) }
        return idx
    }
    
    private func cacheStems(stems: [AudioStem]) -> [String : AudioStem] {
        
        var map: [String : AudioStem] = [ : ]
        stems.forEach() { s in map[s.reference] = s }
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
