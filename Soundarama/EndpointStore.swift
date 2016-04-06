//
//  EndpointStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 05/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class EndpointStore {
    
    private var endpoints: [String : DisconnectableEndpoint] = [ : ]
    
    func getEndpoint(address: String) -> DisconnectableEndpoint {
        
        return endpoints[address]!
    }
    
    func addEndpoint(address: String, endpoint: DisconnectableEndpoint) {
        
        endpoints[address] = endpoint
    }
    
    func removeEndpoint(address: String) {
        
        endpoints.removeValueForKey(address)
    }
    
    func getEndpoints() -> [DisconnectableEndpoint] {
        
        return endpoints.map() { $0.1 }
    }
}