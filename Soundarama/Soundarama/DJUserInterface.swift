//
//  DJUserInterface.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

protocol DJUserInterface: class {
    
    weak var delegate: DJUserInterfaceDelegate! { get set }
    
    var audioStems:[AudioStem]! { get set }
    
    func setSuite(suite: Suite)
    
    // TODO: setPerformers(from:Set<> to: Set<>)
    func addPerformer(performer: Performer)
    func removePerformer(performer: Performer)
    //---
    
    func enterGroupingMode()
    
    func exitGroupingMode()
    
    func changeGroups(fromGroups: Set<Group>, toGroups: Set<Group>)
}

protocol DJUserInterfaceDelegate: class {
    
    // TODO: Use Touchpress kit ViewController Methods
    func ready()
    func didRequestTravelBack()
    //------------
    
    func didRequestToggleMuteInWorkspace(workspaceID: WorkspaceID)
    
    func didRequestToggleSoloInWorkspace(workspaceID: WorkspaceID)
    
    func didRequestAudioStemInWorkspace(audioStem: AudioStem, workspaceID: WorkspaceID)
    
    func didRequestAddPerformer(performer: Performer, workspaceID: WorkspaceID)
    
    func didRequestRemovePerformer(performer: Performer, workspaceID: WorkspaceID)
    
    func didRequestAddGroup(group: Group, workspaceID: WorkspaceID)
    
    func didRequestRemoveGroup(group: Group, workspaceID: WorkspaceID)
    
    func didRequestCreateGroup(performers: Set<Performer>, groups: Set<Group>)
    
    func didRequestDestroyGroup(group: Group)
    
    func didRequestToggleGroupingMode()

}

struct Group: Hashable {
    
    let members: Set<Performer>
    
    func id() -> Int{
        
        return hashValue
    }
    
    var hashValue: Int {
    
        return members.sort({ $0 > $1 }).reduce("") { i, p in return i + p }.hashValue
    }
}

func == (lhs: Group, rhs: Group) -> Bool {
    
    return lhs.id() == rhs.id()
}
