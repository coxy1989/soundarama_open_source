//
//  UISuiteTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 02/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class UISuiteTransformer {
    
    typealias Reference = String
    typealias Name = String
    
    static func transform(suite: Suite, name: Reference -> Name, colors: Reference -> [UIColor]) -> UISuite {
    
        let uiSuite = suite.map(){ ws in
            UIWorkspace(workspaceID: ws.identifier, title: ws.audioStem.map(name), muteSelected: ws.isMuted, soloSelected: ws.isSolo, antiSoloSelected: ws.isAntiSolo, hasAudio: ws.audioStem != nil, colors: ws.audioStem.map(colors))
        }
        
        return Set(uiSuite)
    }
}
