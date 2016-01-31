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
    
    func setSuite(suite: Suite)
    
    func addPerformer(performer: Performer)
    
    func removePerformer(performer: Performer)
}

protocol DJUserInterfaceDelegate: class {
    
    // TODO: Use Touchpress kit ViewController Methods
    func ready()
    func didRequestTravelBack()
    
    func didRequestToggleMuteInWorkspace(workspace: Workspace)
    
    func didRequestToggleSoloInWorkspace(workspace: Workspace)
    
    func didRequestAudioStemInWorkspace(audioStem: AudioStem, workspace: Workspace)
    
    func didRequestAddPerformer(performer: Performer, workspace: Workspace)
    
    func didRequestRemovePerformer(performer: Performer, workspace: Workspace)
    
    
    //func didSelectAudioStemForPerformer(audioStem: AudioStem, performer: Performer, muted: Bool)
    
    //func didDeselectAudioStemForPerformer(performer: Performer)
    
    //func didChangeMuteState(isMute: Bool, performer: Performer)
    
}

/*
protocol DJUserInterfaceDataSource: class {
    
    func numberOfAudioStems() -> Int
    
    func audioStemAtIndex(index: Int) -> AudioStem
}
*/