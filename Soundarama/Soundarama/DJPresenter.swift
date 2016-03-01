//
//  DJPresenter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJPresenter: DJModule {
    
    weak var djWireframe: DJWireframe!
    weak var ui: DJUserInterface!
    weak var input: DJInput!
    
    weak var navigationController: UINavigationController!
    
    func start(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        let ui = djWireframe.djUserInterface()
        navigationController.pushViewController((ui as! UIViewController), animated: true)
    }
}

extension DJPresenter: DJOutput {
    
    func setAudioStems(audioStems: [AudioStem]) {
        
        ui.audioStems = audioStems
    }
    
    func setSuite(suite: Suite) {
        
         ui.setSuite(suite)
    }
    
    func addPerformer(performer: Performer) {
        
        ui.addPerformer(performer)
    }
    
    func removePerformer(performer: Performer) {
        
        ui.removePerformer(performer)
    }
    
    func changeGroups(fromGroups: Set<Group>, toGroups: Set<Group>) {
        
        ui.changeGroups(fromGroups, toGroups: toGroups)
    }
}

extension DJPresenter: DJUserInterfaceDelegate {
    
    func ready() {
        
        input.start()
        
        ui.addPerformer("x")
        ui.addPerformer("y")
        ui.addPerformer("z")
//        ui.addPerformer("b")
  //      ui.addPerformer("m")
    //    ui.addPerformer("1")
      //  ui.addPerformer("2")
    }
    
    
    func didRequestTravelBack() {
        
        navigationController.popViewControllerAnimated(true)
        input.stop()
    }
    
    func didRequestToggleMuteInWorkspace(workspaceID: WorkspaceID) {
        
        input.requestToggleMuteInWorkspace(workspaceID)
    }
    
    func didRequestToggleSoloInWorkspace(workspaceID: WorkspaceID) {
        
        input.requestToggleSoloInWorkspace(workspaceID)
    }
    
    func didRequestAudioStemInWorkspace(audioStem: AudioStem, workspaceID: WorkspaceID) {
        
        input.requestAudioStemInWorkspace(audioStem, workspaceID: workspaceID)
    }
    
    func didRequestAddPerformer(performer: Performer, workspaceID: WorkspaceID) {
        
        input.requestAddPerformerToWorkspace(performer, workspaceID: workspaceID)
    }
    
    func didRequestRemovePerformer(performer: Performer, workspaceID: WorkspaceID) {
        
        input.requestRemovePerformerFromWorkspace(performer, workspaceID: workspaceID)
    }
    
    func didRequestAddGroup(group: Group, workspaceID: WorkspaceID) {
        
        input.didRequestAddGroup(group, workspaceID: workspaceID)
    }
    
    func didRequestRemoveGroup(group: Group, workspaceID: WorkspaceID) {
        
        input.didRequestRemoveGroup(group, workspaceID: workspaceID)
    }
    
    func didRequestCreateGroup(performers: Set<Performer>, groups: Set<Group>) {
        
        input.requestCreateGroup(performers, groups: groups)
    }
    
    func didRequestToggleGroupingMode() {
        
    }
    
    func didRequestDestroyGroup(group: Group) {
        
    }
}

