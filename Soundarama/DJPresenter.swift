//
//  DJPresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class DJPresenter {
    
    weak var djWireframe: DJWireframe!
    
    weak var djUI: DJUserInterface!
    
    weak var djAudioStemPickerUI: DJAudioStemPickerUserInterface!
    
    weak var djInput: DJInput!
    
    weak var djAudioStemPickerInput: DJAudioStemPickerInput!
    
    private var close: (() -> ())!
    
    func start(navigationController: UINavigationController, close: () -> ()) {
        
        djWireframe.presentDJUserInterface(navigationController)
        self.close = close
    }
}

extension DJPresenter: DJOutput {
    
    func setUISuite(uiSuite: UISuite) {
        
         djUI.setUISuite(uiSuite)
    }
    
    func movePerformer(performer: Performer, translation: CGPoint) {
        
        djUI.movePerformer(performer, translation: translation)
    }
    
    func addPerformer(performer: Performer) {
        
        djUI.addPerformer(performer)
    }
    
    func removePerformer(performer: Performer) {
        
        djUI.removePerformer(performer)
    }
    
    func selectPerformer(performer: Performer) {
        
        djUI.selectPerformer(performer)
    }
    
    func deselectPerformer(performer: Performer) {
        
        djUI.deselectPerformer(performer)
    }
    
    func setGroupingMode(on: Bool) {
        
        djUI.setGroupingMode(on)
    }
    
    func startLassoo(atPoint: CGPoint) {
        
        djUI.startLassoo(atPoint)
    }
    
    func continueLasoo(toPoint: CGPoint) {
        
        djUI.continueLasoo(toPoint)
    }
    
    func endLasoo(atPoint: CGPoint) {
        
        djUI.endLasoo(atPoint)
    }
    
    func cancelLasoo() {
        
        djUI.cancelLasoo()
    }
    
    func createGroup(groupID: GroupID, groupSize: UInt, sourcePerformers: Set<Performer>, sourceGroupIDs: Set<GroupID>) {
     
        djUI.createGroup(groupID, groupSize: groupSize, sourcePerformers: sourcePerformers, sourceGroupIDs: sourceGroupIDs)
    }
    
    func destroyGroup(groupID: GroupID, intoPerformers: Set<Performer>) {
        
        djUI.destroyGroup(groupID, intoPerformers: intoPerformers)
    }
    
    func selectGroup(groupID: GroupID) {
        
        djUI.selectGroup(groupID)
    }
    
    func deselectGroup(groupID: GroupID) {
        
        djUI.deselectGroup(groupID)
    }
    
    func moveGroup(groupID: GroupID, translation: CGPoint) {
        
        djUI.moveGroup(groupID, translation: translation)
    }
}

extension DJPresenter: UserInterfaceDelegate {
    
    func userInterfaceDidLoad(userInterface: UserInterface) {
        
        if userInterface === djUI {
            
            djInput.startDJ()
        }
        
        else if userInterface === djAudioStemPickerUI {
            
            djAudioStemPickerInput.startDJAudioStemPicker()
        }
        
            /*
        else if userInterface === djBroadcastConfigurationUI {
         
            djBroadcastConfigurationInput.startBroadcastConfiguration()
        }
 */
    }
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface) {
        
        if userInterface === djUI {
            
            djWireframe.dismissDJUserInterface()
            djInput.stopDJ()
            close()
        }
        
        else if userInterface === djAudioStemPickerUI {
         
            djWireframe.dismissAudioStemPickerUserInterface(djAudioStemPickerUI)
        }
    }
    
    func userInterfaceWillAppear(userInterface: UserInterface) {}
    
    func userInterfaceDidAppear(userInterface: UserInterface) {}
}

extension DJPresenter: DJUserInterfaceDelegate {
    
    /*
    func didRequestConfigureBroadcast() {
        
       djWireframe.presentBroadcastConfigurationUserInterface()
    }
 */
    
    func didRequestToggleMuteInWorkspace(workspaceID: WorkspaceID) {
        
        djInput.requestToggleMuteInWorkspace(workspaceID)
    }
    
    func didRequestToggleSoloInWorkspace(workspaceID: WorkspaceID) {
        
        djInput.requestToggleSoloInWorkspace(workspaceID)
    }
    
    func didRequestAudioStemChangeInWorkspace(workspaceID: WorkspaceID) {
        
        let audioStemPickerUI = djWireframe.djAudioStemPickerUserInterface()
        audioStemPickerUI.colors = djInput.getCategoryKeyColors()
        audioStemPickerUI.keys = djInput.getCategoryKeys()
        audioStemPickerUI.stemsIndex = djInput.getStemsIndex()
        audioStemPickerUI.identifier = workspaceID
        djWireframe.presentAudioStemPickerUserInterface(audioStemPickerUI)
    }
    
    func didRequestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID) {
        
        djInput.requestAddPerformerToWorkspace(performer, workspaceID: workspaceID)
    }
    
    func didRequestRemovePerformerFromWorkspace(performer: Performer) {
        
        djInput.requestRemovePerformerFromWorkspace(performer)
    }
    
    func didRequestMovePerformer(performer: Performer, translation: CGPoint) {
        
        djInput.requestMovePerformer(performer, translation: translation)
    }
    
    func didRequestSelectPerformer(performer: Performer) {
        
        djInput.requestSelectPerformer(performer)
    }
    
    func didRequestDeselectPerformer(performer: Performer) {
        
        djInput.requestDeselectPerformer(performer)
    }
    
    func didRequestToggleGroupingMode() {
        
        djInput.requestToggleGroupingMode()
    }
    
    func didRequestStartLassoo(atPoint: CGPoint) {
        
        djInput.requestStartLassoo(atPoint)
    }
    
    func didRequestContinueLasoo(toPoint: CGPoint) {
        
        djInput.requestContinueLasoo(toPoint)
    }
    
    func didRequestEndLasoo(atPoint: CGPoint) {
        
        djInput.requestEndLasoo(atPoint)
    }
    
    func didRequestCreateGroup(performers: Set<Performer>, groupIDs: Set<GroupID>) {
        
        djInput.requestCreateGroup(performers, groupIDs: groupIDs)
    }
    
    func didRequestSelectGroup(groupID: GroupID) {
     
        djInput.requestSelectGroup(groupID)
    }
    
    func didRequestDestroyGroup(groupID: GroupID) {
        
        djInput.requestDestroyGroup(groupID)
    }
    
    func didRequestDeselectGroup(groupID: GroupID) {
        
        djInput.requestDeselectGroup(groupID)
    }
    
    func didRequestMoveGroup(groupID: GroupID, translation: CGPoint) {
        
        djInput.requestMoveGroup(groupID, translation: translation)
    }
    
    func didRequestAddGroupToWorkspace(groupID: GroupID, workspaceID: WorkspaceID) {
     
        djInput.requestAddGroupToWorkspace(groupID, workspaceID: workspaceID)
    }
    
    func didRequestRemoveGroupFromWorkspace(groupID: GroupID) {
        
        djInput.requestRemoveGroupFromWorkspace(groupID)
    }
}

extension DJPresenter: DJAudioStemPickerUserInterfaceDelegate {
    
    func didRequestSelectStem(ui: DJAudioStemPickerUserInterface, audioStemID: AudioStemID) {
        
        djWireframe.dismissAudioStemPickerUserInterface(ui)
        djInput.requestAudioStemInWorkspace(audioStemID, workspaceID: ui.identifier)
    }
    
    func didRequestSetSelectedKey(ui: DJAudioStemPickerUserInterface, key: String) {
        
        ui.setSelectedKey(key)
    }
}

extension DJPresenter: DJAudioStemPickerOutput {
    
    func setSelectedKey(key: String) {
        
        djAudioStemPickerUI.setSelectedKey(key)
    }
}
