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