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
    
    static let port: UInt16 = 6565
    
    static let resolveTimeout: NSTimeInterval = 5
}