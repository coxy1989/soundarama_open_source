//
//  Folders.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 26/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

/**
 Returns the user Caches folder if exists.
 
 - returns: The user Caches folder or nil if it doesn't exists.
 */
public func userCachesFolder() -> NSURL? {
    
    return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first
}
