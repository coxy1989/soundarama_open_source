//
//  DJUseCase.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol DJInput: class {
    
    func start()
    
    func stop()
    
    func requestToggleMuteInWorkspace(workspace: Workspace)
    
    func requestToggleSoloInWorkspace(workspace: Workspace)
    
    func requestAudioStemInWorkspace(audioStem: AudioStem, workspace: Workspace)
    
    func requestAddPerformerToWorkspace(performer: Performer, workspace: Workspace)
    
    func requestRemovePerformerFromWorkspace(performer: Performer, workspace: Workspace)
}

protocol DJOutput: class {

    func setSuite(suite: Suite)
    
    func setAudioStems(audioStems: [AudioStem])
    
    func addPerformer(performer: Performer)
    
    func removePerformer(performer: Performer)
}
