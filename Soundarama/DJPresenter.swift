//
//  DJPresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class DJPresenter: DJModule {
    
    weak var djWireframe: DJWireframe!
    weak var ui: DJUserInterface!
    weak var input: DJInput!
    
    func start(navigationController: UINavigationController) {
        
        djWireframe.presentDJUserInterface(navigationController)
    }
}

extension DJPresenter: DJOutput {
        
    func setUISuite(uiSuite: UISuite) {
        
         ui.setUISuite(uiSuite)
    }
    
    func movePerformer(performer: Performer, translation: CGPoint) {
        
        ui.movePerformer(performer, translation: translation)
    }
    
    func addPerformer(performer: Performer) {
        
        ui.addPerformer(performer)
    }
    
    func removePerformer(performer: Performer) {
        
        ui.removePerformer(performer)
    }
    
    func selectPerformer(performer: Performer) {
        
        ui.selectPerformer(performer)
    }
    
    func deselectPerformer(performer: Performer) {
        
        ui.deselectPerformer(performer)
    }
    
    func setGroupingMode(on: Bool) {
        
        ui.setGroupingMode(on)
    }
    
    func startLassoo(atPoint: CGPoint) {
        
        ui.startLassoo(atPoint)
    }
    
    func continueLasoo(toPoint: CGPoint) {
        
        ui.continueLasoo(toPoint)
    }
    
    func endLasoo(atPoint: CGPoint) {
        
        ui.endLasoo(atPoint)
    }
    
    func createGroup(groupID: GroupID, groupSize: UInt, sourcePerformers: Set<Performer>, sourceGroupIDs: Set<GroupID>) {
     
        ui.createGroup(groupID, groupSize: groupSize, sourcePerformers: sourcePerformers, sourceGroupIDs: sourceGroupIDs)
    }
    
    func destroyGroup(groupID: GroupID, intoPerformers: Set<Performer>) {
        
        ui.destroyGroup(groupID, intoPerformers: intoPerformers)
    }
    
    func selectGroup(groupID: GroupID) {
        
        ui.selectGroup(groupID)
    }
    
    func deselectGroup(groupID: GroupID) {
        
        ui.deselectGroup(groupID)
    }
    
    func moveGroup(groupID: GroupID, translation: CGPoint) {
        
        ui.moveGroup(groupID, translation: translation)
    }
}

extension DJPresenter: UserInterfaceDelegate {
    
    func userInterfaceDidLoad(userInterface: UserInterface) {
        
        input.start()
        ui.addPerformer("x")
        ui.addPerformer("y")
        ui.addPerformer("z")
        ui.addPerformer("b")
        ui.addPerformer("m")
        ui.addPerformer("1")
        ui.addPerformer("2")
    }
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface) {
        
        djWireframe.dismissDJUserInterface()
        input.stop()
    }
    
    func userInterfaceWillAppear(userInterface: UserInterface) {}
    
    func userInterfaceDidAppear(userInterface: UserInterface) {}
}

extension DJPresenter: DJUserInterfaceDelegate {
    
    func didRequestToggleMuteInWorkspace(workspaceID: WorkspaceID) {
        
        input.requestToggleMuteInWorkspace(workspaceID)
    }
    
    func didRequestToggleSoloInWorkspace(workspaceID: WorkspaceID) {
        
        input.requestToggleSoloInWorkspace(workspaceID)
    }
    
    func didRequestAudioStemChangeInWorkspace(workspaceID: WorkspaceID) {
        
        let audioStemPickerUI = djWireframe.djAudioStemPickerUserInterface()
        audioStemPickerUI.colors = input.getStemKeyColors()
        audioStemPickerUI.keys = input.getStemKeys()
        audioStemPickerUI.stemsIndex = input.getStemsIndex()
        audioStemPickerUI.delegate = self
        audioStemPickerUI.identifier = workspaceID
        djWireframe.presentAudioStemPickerUserInterface(audioStemPickerUI)
    }
    
    func didRequestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID) {
        
        input.requestAddPerformerToWorkspace(performer, workspaceID: workspaceID)
    }
    
    func didRequestRemovePerformerFromWorkspace(performer: Performer) {
        
        input.requestRemovePerformerFromWorkspace(performer)
    }
    
    func didRequestMovePerformer(performer: Performer, translation: CGPoint) {
        
        input.requestMovePerformer(performer, translation: translation)
    }
    
    func didRequestSelectPerformer(performer: Performer) {
        
        input.requestSelectPerformer(performer)
    }
    
    func didRequestDeselectPerformer(performer: Performer) {
        
        input.requestDeselectPerformer(performer)
    }
    
    func didRequestToggleGroupingMode() {
        
        input.requestToggleGroupingMode()
    }
    
    func didRequestStartLassoo(atPoint: CGPoint) {
        
        input.requestStartLassoo(atPoint)
    }
    
    func didRequestContinueLasoo(toPoint: CGPoint) {
        
        input.requestContinueLasoo(toPoint)
    }
    
    func didRequestEndLasoo(atPoint: CGPoint) {
        
        input.requestEndLasoo(atPoint)
    }
    
    func didRequestCreateGroup(performers: Set<Performer>, groupIDs: Set<GroupID>) {
        
        input.requestCreateGroup(performers, groupIDs: groupIDs)
    }
    
    func didRequestSelectGroup(groupID: GroupID) {
     
        input.requestSelectGroup(groupID)
    }
    
    func didRequestDestroyGroup(groupID: GroupID) {
        
        input.requestDestroyGroup(groupID)
    }
    
    func didRequestDeselectGroup(groupID: GroupID) {
        
        input.requestDeselectGroup(groupID)
    }
    
    func didRequestMoveGroup(groupID: GroupID, translation: CGPoint) {
        
        input.requestMoveGroup(groupID, translation: translation)
    }
    
    func didRequestAddGroupToWorkspace(groupID: GroupID, workspaceID: WorkspaceID) {
     
        input.requestAddGroupToWorkspace(groupID, workspaceID: workspaceID)
    }
    
    func didRequestRemoveGroupFromWorkspace(groupID: GroupID) {
        
        input.requestRemoveGroupFromWorkspace(groupID)
    }
}

extension DJPresenter: DJAudioStemPickerUserInterfaceDelegate {
    
    func djAudioStemsUserInterfaceDidSelectStem(audioStemUI: DJAudioStemPickerUserInterface, audioStemID: AudioStemID) {
        
        djWireframe.dismissAudioStemPickerUserInterface(audioStemUI)
        input.requestAudioStemInWorkspace(audioStemID, workspaceID: audioStemUI.identifier)
    }
}

