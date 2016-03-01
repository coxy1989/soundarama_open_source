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
    
    func requestToggleMuteInWorkspace(workspaceID: WorkspaceID)
    
    func requestToggleSoloInWorkspace(workspaceID: WorkspaceID)
    
    func requestAudioStemInWorkspace(audioStem: AudioStem, workspaceID: WorkspaceID)
    
    func requestAddPerformerToWorkspace(performer: Performer, workspaceID: WorkspaceID)
    
    func requestRemovePerformerFromWorkspace(performer: Performer, workspaceID: WorkspaceID)
    
    func didRequestAddGroup(group: Group, workspaceID: WorkspaceID)
    
    func didRequestRemoveGroup(group: Group, workspaceID: WorkspaceID)
    
    func requestCreateGroup(performers: Set<Performer>, groups: Set<Group>)
    
    //func requestDestroyGroup(group: Group)
    
    //func requestGroupPerformers(performers: Set<Performer>)
}

protocol DJOutput: class {

    func setSuite(suite: Suite)
    
    func setAudioStems(audioStems: [AudioStem])
    
    func addPerformer(performer: Performer)
    
    func removePerformer(performer: Performer)
    
//    func groupPerformers(performers: Set<Performer>)
    
    func changeGroups(fromGroups: Set<Group>, toGroups: Set<Group>)
}
