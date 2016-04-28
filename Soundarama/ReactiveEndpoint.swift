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
    
    var endpoint: Endpoint!
    
    var readHandler: (NSData -> ())?
    
    var stopHandler: (() -> ())?
    
    func producer(endpoint: Endpoint, resolvable: Resolvable) -> SignalProducer<NSData, EndpointError> {
        
        self.endpoint = endpoint
        endpoint.readableDelegate = self
        
        return SignalProducer<NSData, EndpointError> { [weak self] observer, disposable in
            
            self?.readHandler = {
                
                observer.sendNext($0)
            }
            
            self?.stopHandler = {
                
                observer.sendCompleted()
            }
            
            self?.endpoint.onDisconnect() {
                
                observer.sendFailed(.Disconnected(resolvable))
            }
            
            self?.endpoint.readData(Serialization.terminator)
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
        endpoint.readData(Serialization.terminator)
    }
}