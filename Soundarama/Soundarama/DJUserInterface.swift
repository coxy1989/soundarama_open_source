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
    
    var audioStems:[AudioStem]! { get set }
    
    func setUISuite(uiSuite: UISuite)
    
    func addPerformer(performer: Performer)
    
    func removePerformer(performer: Performer)
    
    func selectPerformer(performer: Performer)
    
    func deselectPerformer(performer: Performer)
    
    func movePerformer(performer: Performer, translation: CGPoint) 
    
    func setGroupingMode(on: Bool)
    
    func createGroup(groupID: GroupID, sourcePerformers: Set<Performer>, sourceGroupIDs: Set<GroupID>) 
    
  //  func createGroup(groupID: GroupID, performers: Set<Performer>, groupIDs: Set<GroupID>)
    
//    func destroyGroup(groupID: GroupID, intoPerformers: Set<Performer>)
    
    //func changeGroups(fromGroups: Set<Group>, toGroups: Set<Group>)
}

protocol DJUserInterfaceDelegate: class {
    
    // TODO: Use Touchpress kit ViewController Methods
    func ready()
    func didRequestTravelBack()
    //------------
    
    func didRequestToggleMuteInWorkspace(workspaceID: WorkspaceID)
    
    func didRequestToggleSoloInWorkspace(workspaceID: WorkspaceID)
    
    func didRequestAudioStemInWorkspace(audioStem: AudioStem, workspaceID: WorkspaceID)
    
    func didRequestMovePerformer(performer: Performer, translation: CGPoint)
    
    func didRequestAddPerformer(performer: Performer, workspaceID: WorkspaceID)
    
    func didRequestRemovePerformer(performer: Performer)
    
    func didRequestSelectPerformer(performer: Performer)
    
    func didRequestDeselectPerformer(performer: Performer)
    
    func didRequestToggleGroupingMode()
    
    func didRequestCreateGroup(performers: Set<Performer>, groupIDs: Set<GroupID>)
    
//    func didRequestAddGroup(group: GroupID, workspaceID: WorkspaceID)
    
 //   func didRequestRemoveGroup(group: GroupID, workspaceID: WorkspaceID)
    
  //  func didRequestCreateGroup(performers: Set<Performer>, groups: Set<GroupID>)
    
  //  func didRequestDestroyGroup(group: GroupID)
    

}

typealias GroupID = Int

struct Group: Hashable {
    
    let members: Set<Performer>
    
    func id() -> GroupID {
        
        return hashValue
    }
    
    var hashValue: Int {
    
        return members.sort({ $0 > $1 }).reduce("") { i, p in return i + p }.hashValue
    }
}

func == (lhs: Group, rhs: Group) -> Bool {
    
    return lhs.id() == rhs.id()
}
