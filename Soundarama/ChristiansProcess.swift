//
//  ChristiansProcess.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Christian's Algorithm: https://en.wikipedia.org/wiki/Cristian%27s_algorithm */

protocol ChristiansProcessDelegate: class {
    
    func christiansProcessDidSynchronise(endpoint: Endpoint, local: NSTimeInterval, remote: NSTimeInterval)
}

class ChristiansProcess {
    
    static private let numberOfTrips = 100
    
    weak var delegate: ChristiansProcessDelegate!
    
    private let endpoint: Endpoint
    
    private struct RoundTrip {

        let requestStamp: NSTimeInterval
        
        var responseStamp: NSTimeInterval!
        
        var timestamp: NSTimeInterval!
        
        func latency() -> NSTimeInterval {
            return responseStamp - requestStamp
        }
    }
    
    private var currentTrip: RoundTrip?
    
    private var trips: [RoundTrip] = []
    
    init (endpoint: Endpoint) {
        
        self.endpoint = endpoint
        endpoint.readableDelegate = self
        endpoint.writeableDelegate = self
    }
    
    func syncronise() {
    
        takeTrip()
    }
}

extension ChristiansProcess {
    
    private func takeTrip() {
        
        endpoint.writeData(Serialisation.terminator)
        endpoint.readData(Serialisation.terminator)
    }
    
    private func takeTripIfNeeded() {
        
        trips.count < ChristiansProcess.numberOfTrips ? takeTrip() : end()
    }
    
    private func end() {
    
        let result = calculateResult()
        delegate?.christiansProcessDidSynchronise(endpoint, local: result.local, remote: result.remote)
    }
    
    private func calculateResult() -> (local: NSTimeInterval, remote: NSTimeInterval) {
        
        let sortedTrips = trips.sort() { $0.latency() < $1.latency() }
        let shortestTrip = sortedTrips.first!
        let longestTrip = sortedTrips.last!
        
        debugPrint("------------ Longest Trip ------------")
        debugPrint(" Latency: \(longestTrip.latency()) \n Master Clock: \(longestTrip.timestamp) \n Request: \(longestTrip.requestStamp) \n Response: \(longestTrip.responseStamp)")
        debugPrint("------------ Shortest Trip ------------")
        debugPrint(" Latency: \(shortestTrip.latency()) \n Master Clock: \(shortestTrip.timestamp) \n Request: \(shortestTrip.requestStamp) \n Response: \(shortestTrip.responseStamp)")
        debugPrint("---------------------------------------")
        
        let remote = shortestTrip.timestamp + (shortestTrip.latency() * 0.5)
        let local = shortestTrip.responseStamp
        
        return (local, remote)
    }
    
}

extension ChristiansProcess: WriteableDelegate {
    
    func didWriteData() {
        
        debugPrint("Christian's process wrote data")
        currentTrip = RoundTrip(requestStamp: NSDate().timeIntervalSince1970, responseStamp: nil, timestamp:nil)
    }
}

extension ChristiansProcess: ReadableDelegate {
    
    func didReadData(data: NSData, address: Address) {

        if let d = getTimestamp(data) {
            
            debugPrint("Christian's process read data")
            
            currentTrip!.responseStamp = NSDate().timeIntervalSince1970
            currentTrip!.timestamp = d
            debugPrint(d)
            trips.append(currentTrip!)
        }
        else {
            
                debugPrint("Christian's process FAILED to read data")
        }
        
        takeTripIfNeeded()
    }
}

extension ChristiansProcess {
    
    func getTimestamp(data: NSData) -> NSTimeInterval? {
        
        let dat = Serialisation.getPayload(data)
        
        guard let dic = NSKeyedUnarchiver.unarchiveObjectWithData(dat) else {
            
            return nil
        }
        
        guard let t = dic["timestamp"] as? Double else {
                
            return nil
        }
        
        return t
    }
}
