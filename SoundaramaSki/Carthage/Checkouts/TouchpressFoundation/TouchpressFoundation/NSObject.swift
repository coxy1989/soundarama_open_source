//
//  NSObject.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 26/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

public extension NSObject {
    
    /**
     Retrieves an array of property names found on the current object using Objective-C runtime functions for introspection.
     
     - returns: An array of property names or nil if no property names are found.
     */
    public func propertyNames() -> [String]? {
        
        var propertyNames = [String]()
        
        // Retrieve the properties via the class_copyPropertyList function.
        // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
        var count: UInt32 = 0
        let myClass: AnyClass = self.classForCoder
        let properties = class_copyPropertyList(myClass, &count)
        
        for i: UInt32 in 0 ..< count {
            let property = properties[Int(i)]
            
            // Retrieve the property name by calling property_getName function.
            let cname = property_getName(property)
            
            // Covert the C String into a Swift String.
            guard let name = String.fromCString(cname) else { continue }
            propertyNames.append(name)
        }
        
        // Release objc_property_t.
        free(properties)
        
        return propertyNames.count > 0 ? propertyNames : nil
    }
}
