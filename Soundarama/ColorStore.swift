//
//  ColorStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 28/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class ColorStore {
    
    private static let purple = [   UIColor(red: 229/255, green: 192/255, blue: 240/255, alpha: 100),
                                    UIColor(red: 197/255, green: 125/255, blue: 212/255, alpha: 100),
                                    UIColor(red: 73/255, green: 24/255, blue: 77/255, alpha: 100),
                                    UIColor(red: 133/255, green: 73/255, blue: 142/255, alpha: 100)]
    
    private static let red = [      UIColor(red: 240/255, green: 164/255, blue: 156/255, alpha: 100),
                                    UIColor(red: 217/255, green: 104/255, blue: 87/255, alpha: 100),
                                    UIColor(red: 89/255, green: 24/255, blue: 9/255, alpha: 100),
                                    UIColor(red: 153/255, green: 68/255, blue: 53/255, alpha: 100)]
    
    private static let blue = [     UIColor(red: 191/255, green: 235/255, blue: 240/255, alpha: 100),
                                    UIColor(red: 27/255, green: 169/255, blue: 190/255, alpha: 100),
                                    UIColor(red: 9/255, green: 75/255, blue: 89/255, alpha: 100),
                                    UIColor(red: 17/255, green: 116/255, blue: 133/255, alpha: 100)]
    
    private static let green = [    UIColor(red: 194/255, green: 240/255, blue: 180/255, alpha: 100),
                                    UIColor(red: 139/255, green: 212/255, blue: 125/255, alpha: 100),
                                    UIColor(red: 20/255, green: 77/255, blue: 16/255, alpha: 100),
                                    UIColor(red: 84/255, green: 136/255, blue: 76/255, alpha: 100)]
    
    private static let gray = [     UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 100),
                                    UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 100),
                                    UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 100),
                                    UIColor(red: 116/255, green: 116/255, blue: 116/255, alpha: 100)]
    
    private static let pg = purple + green
    
    private static let rb = red + blue
    
    private static let br = blue + red
    
    private static let gp = green + purple
    
    private static let color_map: [String : [UIColor]] = [
    
        "V-kick" : gp,

        "V-percus" : br,
        
        "V-rhodes" : br,
        
        "V-synth" : pg,
        
        "V-tom" : rb
    ]
    
    static let categoryKeyColors: [String : UIColor] = [
    
        "All" : UIColor.whiteColor(),
        
        "Synth" : purple.first!,
        
        "Bass" : red.first!,
        
        "Hats" : blue.first!,
        
        "Kick" : green.first!
    ]
    
    static func nullColors() -> [UIColor] {
        
        return gray + gray
    }
    
    static func colors(reference: String) -> [UIColor] {
        
        return color_map[reference]!
    }
}
