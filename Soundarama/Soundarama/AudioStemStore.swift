//
//  AudioStemStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class AudioStemStore {
    
    private var audioStemCache: [String : AudioStem]!
    
    func audioStem(reference: String) -> AudioStem? {
        
        if audioStemCache == nil {
            cacheAllStems()
        }
        
        return audioStemCache[reference]
    }
    
    func cacheAllStems() -> [String : AudioStem] {
        
        var map: [String : AudioStem] = [ : ]
        for s in fetchAllStems() {
            map[s.reference] = s
        }
        return map
    }
    
    func fetchAllStems() -> [AudioStem] {
        
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
            return AudioStem(name: name, colour: colour, category: category, reference: reference)
        }
        else {
            return nil
        }
    }
}
