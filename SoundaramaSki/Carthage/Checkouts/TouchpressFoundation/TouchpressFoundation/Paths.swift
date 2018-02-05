//
//  Paths.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 21/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit

public extension UIBezierPath {
    
    // Note: You must declare PathElement as @convention(block), because
    // if you don't, you get "fatal error: can't unsafeBitCast between
    // types of different sizes" at runtime, on Mac OS X at least.
    public typealias PathElement = @convention(block) (UnsafePointer<CGPathElement>) -> Void
    
    public func forEach(body: PathElement) {
        
        let callback: @convention(c) (UnsafeMutablePointer<Void>, UnsafePointer<CGPathElement>) -> Void = { info, element in
            let block = unsafeBitCast(info, PathElement.self)
            block(element)
        }
        
        CGPathApply(CGPath, unsafeBitCast(body, UnsafeMutablePointer<Void>.self), unsafeBitCast(callback, CGPathApplierFunction.self))
    }
}
