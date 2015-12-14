//
//  AudioStem.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

struct AudioStem
{
    let name: String
    let colour: UIColor
    let category: String
    let reference: String
    
    var audioFilePath: String?
    {
        if let path = NSBundle.mainBundle().pathForResource(self.reference, ofType: "m4a", inDirectory: "Sounds")
        {
            return path
        }
        
        return nil
    }
    
    init?(json: JSON)
    {
        if let name = json["Name"].string,
            colourString = json["Colour"].string,
                category = json["Category"].string,
                    reference = json["Ref"].string
        {
            self.name = name
            self.colour = UIColor(rgba: colourString, defaultColor: UIColor.grayColor())
            self.category = category
            self.reference = reference
        }
        else
        {
            return nil
        }
    }
}

extension JSON
{
    static func audioStemsFromDisk() -> [AudioStem]
    {
        var audioStems = [AudioStem]()
        
        if let jsonPath = NSBundle.mainBundle().pathForResource("AudioStems", ofType: "json", inDirectory: "Sounds")
        {
            if let data = NSData(contentsOfFile: jsonPath)
            {
                let json = JSON(data: data)
                if let audioStemJsons = json["AudioStems"].array
                {
                    for audioStemJson in audioStemJsons
                    {
                        if let audioStem = AudioStem(json: audioStemJson)
                        {
                            audioStems.append(audioStem)
                        }
                    }
                }
            }
        }
        
        return audioStems
    }
}