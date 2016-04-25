//
//  NetworkConfiguration.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct NetworkConfiguration {
    
    static let domain = "local"
    
    static let type = "_soundarama_coxy._tcp."
    
    static let port16: UInt16 = 6565
    
    static let port32: Int32 = 6565
    
    static let resolveTimeout: NSTimeInterval = 5
    
    static let connectTimeout: NSTimeInterval = 5
    
    static let christiansTimeServerTimeout: NSTimeInterval = 5
    
    static let christiansProcessTimeout: NSTimeInterval = 5
    
    static let syncTimeout: NSTimeInterval = 5
    
    static let reconnectAttempts: Int = 3
    
    static let reconnectDelay: NSTimeInterval = 5
}