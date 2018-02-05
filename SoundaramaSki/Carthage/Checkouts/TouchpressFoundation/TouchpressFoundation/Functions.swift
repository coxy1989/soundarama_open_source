//
//  Functions.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 26/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

/**
 Execute a closure after a delay on the main thread.
 
 - parameter delay:   How long before the closure should be exectured.
 - parameter closure: The closure to execute.
 */
public func executeAfterDelay(delay: NSTimeInterval, closure: Void -> Void) {
    
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSTimeInterval(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}


public typealias dispatch_cancelable_closure = (cancel: Bool) -> Void

public func delay_closure(delay delay: NSTimeInterval, closure: Void -> Void) -> dispatch_cancelable_closure? {
    
    func dispatch_later(closure: Void -> Void) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    var originalClosure: dispatch_block_t? = closure // Copy.
    var cancelableClosure: dispatch_cancelable_closure?
    
    let delayedClosure: dispatch_cancelable_closure = { cancel in
        if let closure = originalClosure where !cancel {
            dispatch_async(dispatch_get_main_queue(), closure)
        }
        originalClosure = nil
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatch_later {
        if let delayedClosure = cancelableClosure {
            delayedClosure(cancel: false)
        }
    }
    
    return cancelableClosure
}

public func cancel_delayed_closure(closure: dispatch_cancelable_closure) {
    
    closure(cancel: true)
}

