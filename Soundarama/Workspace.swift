//
//  Workspace.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

typealias WorkspaceID = String

struct Workspace: Hashable {
    
    let identifier: WorkspaceID
    let audioStem: AudioStemID?
    let performers: Set<Performer>
    let isMuted: Bool
    let isSolo: Bool
    let isAntiSolo: Bool
    
    var hashValue: Int {
        
        return identifier.hash
    }
}

struct UIWorkspace: Hashable {
    
    let workspaceID: WorkspaceID
    let title: String?
    let muteSelected: Bool
    let soloSelected: Bool
    let antiSoloSelected: Bool
    let hasAudio: Bool
    let color: UIColor?
    
    var hashValue: Int {
        
        return workspaceID.hash
    }
}

func == (lhs: UIWorkspace, rhs: UIWorkspace) -> Bool {
    
    return lhs.workspaceID == rhs.workspaceID
}

func == (lhs: Workspace, rhs: Workspace) -> Bool {
    
    return lhs.identifier == rhs.identifier
}
