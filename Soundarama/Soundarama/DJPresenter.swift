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
}

extension DJPresenter: DJUserInterfaceDelegate {
    
    func ready() {
        
        input.start()
    }
    
    
    func didRequestTravelBack() {
        
        navigationController.popViewControllerAnimated(true)
        input.stop()
    }
    
    func didRequestToggleMuteInWorkspace(workspace: Workspace) {
        
        input.requestToggleMuteInWorkspace(workspace)
    }
    
    func didRequestToggleSoloInWorkspace(workspace: Workspace) {
        
        input.requestToggleSoloInWorkspace(workspace)
    }
    
    func didRequestAudioStemInWorkspace(audioStem: AudioStem, workspace: Workspace) {
        
        input.requestAudioStemInWorkspace(audioStem, workspace: workspace)
    }
    
    func didRequestAddPerformer(performer: Performer, workspace: Workspace) {
        
        input.requestAddPerformerToWorkspace(performer, workspace: workspace)
    }
    
    func didRequestRemovePerformer(performer: Performer, workspace: Workspace) {
        
        input.requestRemovePerformerFromWorkspace(performer,workspace: workspace)
    }
}

