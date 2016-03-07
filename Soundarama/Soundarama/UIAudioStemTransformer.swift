//
//  UIAudioStemTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 07/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct UIAudioStemTransformer {
    
    static func transform(audioStems: Set<AudioStem>) -> Set<UIAudioStem> {
        
        let uiStems = audioStems.map() {
            UIAudioStem(title: $0.name, subtitle: $0.category, audioStemID: $0.reference)
        }
     
        return Set(uiStems)
    }
}