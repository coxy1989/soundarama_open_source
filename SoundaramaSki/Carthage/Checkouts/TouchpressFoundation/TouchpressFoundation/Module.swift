//
//  Module.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 08/02/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

// MARK: - Interactor

// MARK: InteractorProtocol

public protocol InteractorProtocol: class {
    
}

// MARK: - Presenter

// MARK: PresenterProtocol

public protocol PresenterProtocol: class {
    
    weak var wireframe: WireframeProtocol? { get set }
}

// MARK: PresenterEventHandler

public protocol PresenterEventHandler: class {
    
    func didSucceed()
    
    func wasCanceled()
    
    func didFail()
}

// MARK: Presenter

public class Presenter: PresenterProtocol {
    
    public weak var presenterEventHandler: PresenterEventHandler?

    public weak var wireframe: WireframeProtocol?
    
    public func start() {
        
    }
}

// MARK: - Wireframe

// MARK: WireframeProtocol

public protocol WireframeProtocol: class {
    
    weak var presenter: PresenterProtocol? { get set }
}

// MARK: - Module

// MARK: ModuleProtocol

public protocol ModuleProtocol: class {
    
    weak var moduleEventHandler: ModuleEventHandler? { get set }

    var interactor: InteractorProtocol? { get }
    
    var presenter: PresenterProtocol? { get }
    
    var wireframe: WireframeProtocol? { get }
}

// MARK: ModuleEventHandler

public protocol ModuleEventHandler: class {
    
    func moduleDidEnd(module: ModuleProtocol)
}

// MARK: Module

public class Module: ModuleProtocol {
    
    public weak var moduleEventHandler: ModuleEventHandler?
    
    public var interactor: InteractorProtocol? {
        
        return nil
    }
    
    public var presenter: PresenterProtocol? {

        return nil
    }
    
    public var wireframe: WireframeProtocol? {
        
        return nil
    }
 
    public init() {
        
        presenter?.wireframe = wireframe
        
        wireframe?.presenter = presenter
    }
    
    deinit {
        
        debugPrint("\(NSStringFromClass(self.dynamicType)) is gone.")
    }
}
