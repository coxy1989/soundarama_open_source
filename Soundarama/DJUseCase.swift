//
//  DJUseCase.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CoreGraphics

protocol DJInput: class {
    
    func start()
    
    func stop()
    
    func getAudioStems() -> Set<UIAudioStem>
    
    func requestToggleMuteInWorkspace(workspaceID: WorkspaceID)
    
    func requestToggleSoloInWorkspace(workspaceID: WorkspaceID)
    
    func requestAudioStemInWorkspace(audioStemID: AudioStemID, workspaceID: WorkspaceID)
    
    func requestMovePerformer(performer: Performer, translation: CGPoint)
    
    func requestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID)
    
    func requestRemovePerformerFromWorkspace(performer: Performer)
    
    func requestSelectPerformer(performer: Performer)
    
    func requestDeselectPerformer(performer: Performer)
    
    func requestToggleGroupingMode()
    
    func requestStartLassoo(atPoint: CGPoint)
    
    func requestContinueLasoo(toPoint: CGPoint)
    
    func requestEndLasoo(atPoint: CGPoint)
    
    func requestCreateGroup(performers: Set<Performer>, groupIDs: Set<GroupID>)
    
    func requestDestroyGroup(groupID: GroupID)
    
    func requestSelectGroup(groupID: GroupID)
    
    func requestDeselectGroup(groupID: GroupID)
    
    func requestMoveGroup(groupID: GroupID, translation: CGPoint)
    
    func requestAddGroupToWorkspace(groupID: GroupID, workspaceID: WorkspaceID)
    
    func requestRemoveGroupFromWorkspace(groupID: GroupID)
}

protocol DJOutput: class {

    func setUISuite(uiSuite: UISuite)
    
    func addPerformer(performer: Performer)
    
    func removePerformer(performer: Performer)
    
    func selectPerformer(performer: Performer)
    
    func deselectPerformer(performer: Performer)
    
    func movePerformer(performer: Performer, translation: CGPoint)
    
    func setGroupingMode(on: Bool)
    
    func startLassoo(atPoint: CGPoint)
    
    func continueLasoo(toPoint: CGPoint)
    
    func endLasoo(atPoint: CGPoint)
    
    func createGroup(groupID: GroupID, groupSize: UInt, sourcePerformers: Set<Performer>, sourceGroupIDs: Set<GroupID>)
    
    func destroyGroup(groupID: GroupID, intoPerformers: Set<Performer>)
    
    func selectGroup(groupID: GroupID)
    
    func deselectGroup(groupID: GroupID)
    
    func moveGroup(groupID: GroupID, translation: CGPoint)
}
