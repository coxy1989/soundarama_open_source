//
//  UISuiteTransformer.swift
//  Soundarama
//
//  Created by Jamie Cox on 02/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class UISuiteTransformer {
    
    static func transform(suite: Suite) -> UISuite {
    
        let uiSuite = suite.map(){ ws in
            UIWorkspace(workspaceID: ws.identifier, title: ws.audioStem?.name, muteSelected: ws.isMuted, soloSelected: ws.isSolo, antiSoloSelected: ws.isAntiSolo, hasAudio: ws.audioStem != nil, color: ws.audioStem?.colour)
        }
        
        return Set(uiSuite)
    }
}