//
//  SuiteStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class SuiteStore {
    
    var suite: Suite!
    
    init(number: Int) {
        
        suite = emptyWorkspaces(number)
    }
    
    func addPerformer(performer: Performer, workspaceID: WorkspaceID) {
        
        /* This function enforces the invariant that a given performer may only exist in one workspace at a time */
        
        guard let workspace = suite.filter({ $0.identifier == workspaceID }).first else {
            
            assert(false, "This is a logical error")
        }
        
        let prev = suite.filter({ $0 != workspace && $0.performers.contains(performer)})
        assert(prev.count <= 1, "Unrecoverable state violation. A performer can only exist in one workspace")
        if prev.count == 1 {
            removePerformer(performer)
        }
        
        let nextWorkspace = workspaceWithAdditionalPerformer(workspace, performer: performer)
        suite.remove(workspace)
        suite.insert(nextWorkspace)
    }
    
    func removePerformer(performer: Performer) {
        
        guard let workspace = suite.filter({ $0.performers.contains(performer)}).first else {
            
            print("performer has no workspace to be removed from")
            return
        }
        
        let nextWorkspace = workspaceWithoutPerformer(workspace, performer: performer)
        suite.remove(workspace)
        suite.insert(nextWorkspace)
    }
    
    func setAudioStem(audioStem: AudioStem, workspaceID: WorkspaceID) {
        
        guard let workspace = suite.filter({ $0.identifier == workspaceID }).first else {
            
            assert(false, "This is a logical error")
        }
        
        let nextWorkspace = workspaceWithAudioStem(workspace, audioStem: audioStem)
        suite.remove(workspace)
        suite.insert(nextWorkspace)
    }
    
    func toggleMute(workspaceID: WorkspaceID) {
        
        guard let workspace = suite.filter({ $0.identifier == workspaceID }).first else {
            
            assert(false, "This is a logical error")
        }
        
        let nextWorkspace = workspaceWithMuteState(workspace, muteState: !workspace.isMuted)
        suite.remove(workspace)
        suite.insert(nextWorkspace)
    }
    
    func toggleSolo(workspaceID: WorkspaceID) {
        
        /*  This function enforces the invariant that a given workspace with a solo state equal to false has an antiSolo
            state equal to true if there is another workspace in the suite with a solo state of true. */
        
        guard let workspace = suite.filter({ $0.identifier == workspaceID }).first else {
            
            assert(false, "This is a logical error")
        }
        
        let otherSolos = suite.filter({ $0 != workspace && $0.isSolo })
        
        guard !workspace.isSolo else {
            
            print("Turned off a solo")
            guard otherSolos.count != 0 else {
                
                print("Turned off the only solo")
                 suite = Set(suite.map({ workspaceWithSoloState($0, soloState: false, antiSoloState: false) }))
                return
            }
            
            print("Turned off a solo, but there is at least one other solo")
            let nextWorkspace = workspaceWithSoloState(workspace, soloState: false, antiSoloState: otherSolos.count > 0)
            suite.remove(workspace)
            suite.insert(nextWorkspace)
            return
        }
        
        print("Turned on a solo")
        guard otherSolos.count != 0 else {
            
            print("Turned on the only solo")
            suite = Set(suite.map({ workspaceWithSoloState($0, soloState: false, antiSoloState: true) }))
            let nextWorkspace = workspaceWithSoloState(workspace, soloState: true, antiSoloState: false)
            suite.remove(workspace)
            suite.insert(nextWorkspace)
            return
        }
        
        print("Turned on a solo, but there is at least one other solo")
        let nextWorkspace = workspaceWithSoloState(workspace, soloState: true, antiSoloState: false)
        suite.remove(workspace)
        suite.insert(nextWorkspace)
    }
}

extension SuiteStore {
    
    private func emptyWorkspaces(number: Int) -> Set<Workspace> {
        
        return Set((0..<number).map( { _ in Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: [], isMuted: false, isSolo: false, isAntiSolo: false) }))
    }
}

extension SuiteStore {
    
    private func workspaceWithAdditionalPerformer(workspace: Workspace, performer: Performer) -> Workspace {
        
        var performers = workspace.performers
        performers.insert(performer)
        return Workspace(identifier: workspace.identifier, audioStem: workspace.audioStem, performers: performers, isMuted: workspace.isMuted, isSolo: workspace.isSolo, isAntiSolo: workspace.isAntiSolo)
    }
    
    private func workspaceWithoutPerformer(workspace: Workspace, performer: Performer) -> Workspace {
        
        var performers = workspace.performers
        performers.remove(performer)
        return Workspace(identifier: workspace.identifier, audioStem: workspace.audioStem, performers: performers, isMuted: workspace.isMuted, isSolo: workspace.isSolo, isAntiSolo: workspace.isAntiSolo)
    }
    
    private func workspaceWithAudioStem(workspace: Workspace, audioStem: AudioStem) -> Workspace {
        
        return Workspace(identifier: workspace.identifier, audioStem: audioStem, performers: workspace.performers, isMuted: workspace.isMuted, isSolo: workspace.isSolo, isAntiSolo: workspace.isAntiSolo)
    }
    
    private func workspaceWithMuteState(workspace: Workspace, muteState: Bool) -> Workspace {
        
        return Workspace(identifier: workspace.identifier, audioStem: workspace.audioStem, performers: workspace.performers, isMuted: muteState, isSolo: workspace.isSolo, isAntiSolo: workspace.isAntiSolo)
    }
    
    
    private func workspaceWithSoloState(workspace: Workspace, soloState: Bool, antiSoloState: Bool) -> Workspace {
        
        return Workspace(identifier: workspace.identifier, audioStem: workspace.audioStem, performers: workspace.performers, isMuted: workspace.isMuted, isSolo: soloState, isAntiSolo: antiSoloState)
    }
}
