//
//  ChristiansTimeServer.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Christian's Algorithm: https://en.wikipedia.org/wiki/Cristian%27s_algorithm */

class ChristiansTimeServer {
    
    static let timestamp = NSDate().timeIntervalSince1970
    
    private let endpoint: Endpoint
    
    init(endpoint: Endpoint) {
        
        self.endpoint = endpoint
        endpoint.readableDelegate = self
    }
}

extension ChristiansTimeServer: ReadableDelegate {
    
    func didReadData(data: NSData, address: Address) {
        
        endpoint.writeData(setTimestamp(), address: address)
        endpoint.readData(Serialisation.terminator, address: address)
    }
}


extension ChristiansTimeServer {
    
    func setTimestamp() -> NSData {
        
        let d = ["timestamp" : NSDate().timeIntervalSince1970]
        let dat = Serialisation.setPayload(d)
        return dat
    }
}