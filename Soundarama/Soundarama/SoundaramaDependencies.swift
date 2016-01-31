//
//  SoundaramaDependencies.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Dependency Inversion */

struct SoundaramaDependencies {
    
    func broadcastingEndpoint() -> Endpoint {
        
        return BroadcastSocketEndpoint()
    }
    
    func searchingEndpoint() -> Endpoint {
        
        return SearchSocketEndpoint()
    }
}