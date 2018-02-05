//
//  UserInterface.swift
//  Music
//
//  Created by Karim Sallam on 27/10/2015.
//  Copyright © 2015 Touchpress. All rights reserved.
//

import Foundation
import TouchpressFoundation

public enum ViewState: StateType {
    
    case Invisible
    
    case WillBecomeVisible
    
    case Visible
    
    case WillBecomeInvisible
    
    public func shouldTransition(toState toState: ViewState) -> Bool {
        
        switch toState {
            case .Invisible:            return self == .WillBecomeInvisible
            case WillBecomeVisible:     return self == .Invisible
            case Visible:               return self == .WillBecomeInvisible
            case .WillBecomeInvisible:  return self == .Visible
        }
    }
}

public protocol UserInterface: class {
    
    weak var userInterfaceDelegate: UserInterfaceDelegate? { get set }
    
    var viewState: StateMachine<ViewState> { get }
    
    var catchMenuPressed: Bool { get set }
    
    func addMenuPressedOberver(observer: Void -> Void) -> String
    
    func removeMenuPressedObserver(observerId observerId: String)
    
    var hidden: Bool { get set }
    
    func prepareForReuse()
}

public protocol UserInterfaceDelegate: class {
    
    func userInterfaceDidLoad(userInterface: UserInterface)
    
    func userInterfaceWillAppear(userInterface: UserInterface)
    
    func userInterfaceDidAppear(userInterface: UserInterface)
    
    func userInterfaceDidNavigateBack(userInterface: UserInterface)
}