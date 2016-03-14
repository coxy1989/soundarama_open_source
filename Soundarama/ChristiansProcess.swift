//
//  ChristiansProcess.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Christian's Algorithm: https://en.wikipedia.org/wiki/Cristian%27s_algorithm */

protocol ChristiansProcessDelegate: class {
    
    func christiansProcessDidSynchronise(local: NSTimeInterval, remote: NSTimeInterval)
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
        
        endpoint.readData(Serialisation.terminator)
        endpoint.writeData(Serialisation.terminator)
    }
    
    private func takeTripIfNeeded() {
        
        trips.count < ChristiansProcess.numberOfTrips ? takeTrip() : end()
    }
    
    private func end() {
    
        let result = calculateResult()
        delegate?.christiansProcessDidSynchronise(result.local, remote: result.remote)
    }
    
    private func calculateResult() -> (local: NSTimeInterval, remote: NSTimeInterval) {
        
        let sortedTrips = trips.sort() { $0.latency() < $1.latency() }
        let shortestTrip = sortedTrips.first!
        let longestTrip = sortedTrips.last!
        
        print("------------ Longest Trip ------------")
        print(" Latency: \(longestTrip.latency()) \n Master Clock: \(longestTrip.timestamp) \n Request: \(longestTrip.requestStamp) \n Response: \(longestTrip.responseStamp)")
        print("------------ Shortest Trip ------------")
        print(" Latency: \(shortestTrip.latency()) \n Master Clock: \(shortestTrip.timestamp) \n Request: \(shortestTrip.requestStamp) \n Response: \(shortestTrip.responseStamp)")
        print("---------------------------------------")
        
        let remote = shortestTrip.timestamp + (shortestTrip.latency() * 0.5)
        let local = shortestTrip.responseStamp
        
        return (local, remote)
    }
    
}

extension ChristiansProcess: WriteableDelegate {
    
    func didWriteData(data: NSData) {
        
        currentTrip = RoundTrip(requestStamp: NSDate().timeIntervalSince1970, responseStamp: nil, timestamp:nil)
    }
}

extension ChristiansProcess: ReadableDelegate {
    
    func didReadData(data: NSData, address: Address) {

        if let d = getTimestamp(data) {
            currentTrip!.responseStamp = NSDate().timeIntervalSince1970
            currentTrip!.timestamp = d
            print(d)
            trips.append(currentTrip!)
        }
        
        takeTripIfNeeded()
    }
}

extension ChristiansProcess {
    
    func getTimestamp(data: NSData) -> NSTimeInterval? {
        
        let dat = Serialisation.getPayload(data)
        if let dic = NSKeyedUnarchiver.unarchiveObjectWithData(dat) {
            if let t = dic["timestamp"] as? Double {
                return t
            }
        }
        
        return nil
    }
}
