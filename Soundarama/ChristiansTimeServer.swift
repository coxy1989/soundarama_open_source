//
//  ChristiansTimeServer.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Christian's Algorithm: https://en.wikipedia.org/wiki/Cristian%27s_algorithm */

protocol ChristiansTimeServerDelegate {
    
    func christiansTimeServerDidSyncronise(timeServer: ChristiansTimeServer, endpoint: (String, Endpoint))
}

class ChristiansTimeServer {
    
    static let timestamp = NSDate().timeIntervalSince1970
    
    var delegate: ChristiansTimeServerDelegate!
    
    private let endpoint: (String, Endpoint)
    
    private var trips = 0
    
    init(address: String, endpoint: Endpoint) {
        
        self.endpoint = (address, endpoint)
        endpoint.readableDelegate = self
        endpoint.readData(Serialisation.terminator)
    }
}

extension ChristiansTimeServer: ReadableDelegate {
    
    func didReadData(data: NSData) {
        
        endpoint.1.writeData(setTimestamp())
        endpoint.1.readData(Serialisation.terminator)
        trips = trips + 1
        
        if trips == ChristiansConstants.numberOfTrips {
            
            delegate.christiansTimeServerDidSyncronise(self, endpoint: endpoint)
        }
    }
}

extension ChristiansTimeServer {
    
    func setTimestamp() -> NSData {
        
        let d = ["timestamp" : NSDate().timeIntervalSince1970]
        let dat = Serialisation.setPayload(d)
        return dat
    }
}
