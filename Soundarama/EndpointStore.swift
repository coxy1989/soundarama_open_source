//
//  EndpointStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 05/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class EndpointStore {
    
    private var endpoints: [String : Endpoint] = [ : ]
    
    func getEndpoint(address: String) -> Endpoint {
        
        return endpoints[address]!
    }
    
    func addEndpoint(address: String, endpoint: Endpoint) {
        
        endpoints[address] = endpoint
    }
    
    func removeEndpoint(address: String) {
        
        endpoints.removeValueForKey(address)
    }
    
    func getEndpoints() -> [Endpoint] {
        
        return endpoints.map() { $0.1 }
    }
}