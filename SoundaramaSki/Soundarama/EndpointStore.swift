//
//  EndpointStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 05/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class EndpointStore {
    
    private let lock = NSRecursiveLock()
    
    private var endpoints: [String : Endpoint] = [ : ]
    
    func getEndpoint(address: String) -> Endpoint {
        
        return endpoints[address]!
    }
    
    func addEndpoint(address: String, endpoint: Endpoint) {
        
        lock.lock()
        endpoints[address] = endpoint
        lock.unlock()
    }
    
    func removeEndpoint(address: String) {
        
        lock.lock()
        endpoints.removeValueForKey(address)
        lock.unlock()
    }
    
    func getEndpoints() -> [String : Endpoint] {
        
        return endpoints
    }
}
