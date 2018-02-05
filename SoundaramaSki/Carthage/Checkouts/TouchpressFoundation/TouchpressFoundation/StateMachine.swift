//
//  StateMachine.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 26/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

// MARK: - StateType

public protocol StateType {
    
    func shouldTransition(toState toState: Self) -> Bool
}

// MARK: - StateMachine

public struct StateMachine<T: StateType>: Observable {
    
    public typealias Transition = (oldState: T, newState: T) -> Void
    
    public init(initialState: T, observer: Transition? = nil) {
        
        _state = Value(initialValue: initialState, observer: observer)
    }
    
    private var _state: Value<T>
    
    public var state: T {
        get {
            return _state.value
        }
        set {
            if shouldSet(newState: newValue) {
                _state.value = newValue
            }
        }
    }
    
    private func shouldSet(newState newState: T) -> Bool {
        
        return _state.value.shouldTransition(toState: newState)
    }
        
    public func addObserver(observer: Transition) -> String {
        
        return _state.addObserver(observer)
    }
    
    public func removeObserver(observerId observerId: String) {
        
        return _state.removeObserver(observerId: observerId)
    }
}
