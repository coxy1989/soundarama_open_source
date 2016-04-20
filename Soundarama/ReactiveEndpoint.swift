//
//  ReactiveEndpoint.swift
//  Soundarama
//
//  Created by Jamie Cox on 18/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import ReactiveCocoa
import enum Result.NoError

class ReactiveEndpoint {
    
    let endpoint: Endpoint
    
    var readHandler: (NSData -> ())?
    
    var stopHandler: (() -> ())?
    
    init(endpoint: Endpoint) {
        
        self.endpoint = endpoint
        endpoint.readableDelegate = self
    }
    
    static func start(reactiveEndpoint: ReactiveEndpoint, resolvable: Resolvable) -> SignalProducer<NSData, EndpointError> {
        
        return SignalProducer<NSData, EndpointError> { observer, disposable in
            
            reactiveEndpoint.readHandler = {
                
                observer.sendNext($0)
            }
            
            reactiveEndpoint.stopHandler = {
                
                observer.sendCompleted()
            }
            
            reactiveEndpoint.endpoint.onDisconnect() {
                
                observer.sendFailed(.Disconnected(resolvable))
            }
            
            reactiveEndpoint.endpoint.readData(Serialisation.terminator)
        }
    }
    
    func stop() {
        
        stopHandler?()
        endpoint.disconnect()
    }
}

extension ReactiveEndpoint: ReadableDelegate {
    
    func didReadData(data: NSData) {
        
        readHandler?(data)
        endpoint.readData(Serialisation.terminator)
    }
}