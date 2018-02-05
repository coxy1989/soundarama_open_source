//
//  Observable.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 26/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

// MARK: Observable

/**
*  An Observable will call Transition when it changes.
*/
public protocol Observable {
    
    associatedtype Transition
    
    associatedtype ObserverId
    
    func addObserver(observer: Transition) -> ObserverId
    
    func removeObserver(observerId observerId: ObserverId)
}

// MARK: - ValueObserver

public class ValueObserver<T>: Observable {
    
    public typealias Transition = (oldValue: T, newValue: T) -> Void
    
    public init(initialValue: T, observer: Transition? = nil) {
        
        _value = initialValue
        if let observer = observer {
            addObserver(observer)
        }
    }
    
    private var _value: T
    
    public var value: T {
        get {
            return _value
        }
        set {
            let oldValue = value
            _value = newValue
            for (_, observer) in _observers {
                observer(oldValue: oldValue, newValue: newValue)
            }
        }
    }
    
    private var _observers = [String : Transition]()
    
    public func addObserver(observer: Transition) -> String {
        
        let id = NSUUID().UUIDString
        _observers[id] = observer
        return id
    }
    
    public func removeObserver(observerId observerId: String) {
        
        _observers.removeValueForKey(observerId)
    }
    
    public func copy() -> ValueObserver<T> {
        
        let copy = ValueObserver<T>(initialValue: value)
        copy._observers = _observers
        return copy
    }
}

// MARK: - Value

public struct Value<T>: Observable {
    
    public typealias Transition = (oldValue: T, newValue: T) -> Void
    
    public init(initialValue: T, observer: Transition? = nil) {
        
        valueObserver = ValueObserver(initialValue: initialValue, observer: observer)
        if let observer = observer {
            addObserver(observer)
        }
    }
    
    private var valueObserver: ValueObserver<T>
    
    private mutating func ensureUnique() {
        
        if !isUniquelyReferencedNonObjC(&valueObserver) {
            valueObserver = valueObserver.copy()
        }
    }
    
    public var value: T {
        get {
            return valueObserver.value
        }
        set {
            ensureUnique()
            valueObserver.value = newValue
        }
    }
    
    public func addObserver(observer: Transition) -> String {
        
        return valueObserver.addObserver(observer)
    }
    
    public func removeObserver(observerId observerId: String) {
        
        valueObserver.removeObserver(observerId: observerId)
    }
}
