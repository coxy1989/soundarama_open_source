//
//  ViewController.swift
//  Music
//
//  Created by Karim Sallam on 27/10/2015.
//  Copyright © 2015 Touchpress. All rights reserved.
//

import UIKit
import TouchpressFoundation


public class ViewController: UIViewController, UserInterface {
    
    weak public var userInterfaceDelegate: UserInterfaceDelegate?
    
    public var viewState: StateMachine<ViewState> {
        
        return _viewState
    }
    
    private var _viewState: StateMachine<ViewState> = StateMachine(initialState: .Invisible)
    
    private typealias MenuPressedClosure = Void -> Void
    
    private var _menuPressedObservers = [String : MenuPressedClosure]()
    
    @available(tvOS 9.0, *)
    public var catchMenuPressed = false {
        didSet {
            didSetCatchMenuPressed(catchMenuPressed)
        }
    }
    
    private weak var menuPressed: UITapGestureRecognizer?
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        if #available(iOS 9.0, *) {
            didSetCatchMenuPressed(catchMenuPressed)
        }
        
        userInterfaceDelegate?.userInterfaceDidLoad(self)
        didSetHidden(hidden)
    }
    
    @available(tvOS 9.0, *)
    private func didSetCatchMenuPressed(catchMenuPressed: Bool) {
        
        if isViewLoaded() {
            catchMenuPressed ? addMenuPressedRecognizer() : removeMenuPressedRecognizer()
        }
    }
    
    @available(tvOS 9.0, *)
    private func addMenuPressedRecognizer() {
        
        let menuPressed = UITapGestureRecognizer(target: self, action: "menuPressed:")
        if #available(iOS 9.0, *) {
            menuPressed.allowedPressTypes = [UIPressType.Menu.rawValue]
        }
        view.addGestureRecognizer(menuPressed)
        self.menuPressed = menuPressed
    }
    
    private func removeMenuPressedRecognizer() {
        
        guard let menuPressed = self.menuPressed else { return }
        view.removeGestureRecognizer(menuPressed)
    }
    
    public override func viewWillAppear(animated: Bool) {
        
        userInterfaceDelegate?.userInterfaceWillAppear(self)
        _viewState.state = .WillBecomeVisible
    }
    
    override public func viewDidAppear(animated: Bool) {
        
        userInterfaceDelegate?.userInterfaceDidAppear(self)
        _viewState.state = .Visible
    }
    
    public override func viewWillDisappear(animated: Bool) {
        
        _viewState.state = .WillBecomeInvisible
    }
    
    public override func viewDidDisappear(animated: Bool) {
        
        _viewState.state = .Invisible
    }
    
    public func addMenuPressedOberver(observer: Void -> Void) -> String {
        
        let id = NSUUID().UUIDString
        _menuPressedObservers[id] = observer
        return id
    }
    
    public func removeMenuPressedObserver(observerId observerId: String) {
        
        _menuPressedObservers.removeValueForKey(observerId)
    }
    
    @objc private func menuPressed(sender: UITapGestureRecognizer) {
        
        for (_, menuPressedObserver) in _menuPressedObservers {
            menuPressedObserver()
        }
    }
    
    // MARK: - hidden
    
    public var hidden = false {
        didSet {
            didSetHidden(hidden)
        }
    }
    
    private func didSetHidden(hidden: Bool) {
        
        if isViewLoaded() {
            view.hidden = hidden
        }
    }
    
    
    public func prepareForReuse() {
        
    }
}
