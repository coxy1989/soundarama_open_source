//
//  UIAudioStemTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 07/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

struct UIAudioStemTransformer {
    
    static func transform(audioStems: Set<AudioStem>, color: Reference -> [UIColor] ) -> Set<UIAudioStem> {
        
        let uiStems = audioStems.map() { UIAudioStem(title: $0.name, subtitle: $0.category, audioStemID: $0.reference, colour: color($0.reference).first!) }
     
        return Set(uiStems)
    }
}
