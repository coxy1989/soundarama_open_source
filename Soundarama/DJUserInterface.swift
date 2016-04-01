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
    
    func setUISuite(uiSuite: UISuite)
    
    func setBroadcastingIdentifier(identifier: String)
    
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

protocol DJUserInterfaceDelegate: class {
    
    func didRequestConfigureBroadcast()
    
    func didRequestToggleMuteInWorkspace(workspaceID: WorkspaceID)
    
    func didRequestToggleSoloInWorkspace(workspaceID: WorkspaceID)
    
    func didRequestAudioStemChangeInWorkspace(workspaceID: WorkspaceID)
    
    func didRequestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID)
    
    func didRequestRemovePerformerFromWorkspace(performer: Performer)
    
    func didRequestSelectPerformer(performer: Performer)
    
    func didRequestDeselectPerformer(performer: Performer)
    
    func didRequestMovePerformer(performer: Performer, translation: CGPoint)
    
    func didRequestToggleGroupingMode()
    
    func didRequestStartLassoo(atPoint: CGPoint)
    
    func didRequestContinueLasoo(toPoint: CGPoint)
    
    func didRequestEndLasoo(atPoint: CGPoint)
    
    func didRequestCreateGroup(performers: Set<Performer>, groupIDs: Set<GroupID>)
    
    func didRequestDestroyGroup(groupID: GroupID)
    
    func didRequestSelectGroup(groupID: GroupID)
    
    func didRequestDeselectGroup(groupID: GroupID)
    
    func didRequestMoveGroup(groupID: GroupID, translation: CGPoint)
    
    func didRequestAddGroupToWorkspace(groupID: GroupID, workspaceID: WorkspaceID)
    
    func didRequestRemoveGroupFromWorkspace(groupID: GroupID)
    
}