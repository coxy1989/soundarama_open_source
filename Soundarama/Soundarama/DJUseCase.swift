//
//  DJUseCase.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

//hmmm...
import CoreGraphics

protocol DJInput: class {
    
    func start()
    
    func stop()
    
    func requestToggleMuteInWorkspace(workspaceID: WorkspaceID)
    
    func requestToggleSoloInWorkspace(workspaceID: WorkspaceID)
    
    func requestAudioStemInWorkspace(audioStem: AudioStem, workspaceID: WorkspaceID)
    
    func requestMovePerformer(performer: Performer, translation: CGPoint)
    
    func requestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID)
    
    func requestRemovePerformerFromWorkspace(performer: Performer)
    
    func requestSelectPerformer(performer: Performer)
    
    func requestDeselectPerformer(performer: Performer)
    
    func requestToggleGroupingMode()
    
    func requestCreateGroup(performers: Set<Performer>, groupIDs: Set<GroupID>)
    
//    func requestAddGroup(group: Group, workspaceID: WorkspaceID)
    
//    func requestRemoveGroup(group: Group, workspaceID: WorkspaceID)
    
    
//    func requestDestroyGroup(group: Group)

}

protocol DJOutput: class {

    func setUISuite(uiSuite: UISuite)
    
    func setAudioStems(audioStems: [AudioStem])
    
    func addPerformer(performer: Performer)
    
    func removePerformer(performer: Performer)
    
    func selectPerformer(performer: Performer)
    
    func deselectPerformer(performer: Performer)
    
    func movePerformer(performer: Performer, translation: CGPoint)
    
    func setGroupingMode(on: Bool)
    
    func createGroup(groupID: GroupID, sourcePerformers: Set<Performer>, sourceGroupIDs: Set<GroupID>)
    
//    func destroyGroup(group: Group)
    
//    func changeGroups(fromGroups: Set<Group>, toGroups: Set<Group>)
}
