//
//  ChristiansProcess.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Christian's Algorithm: https://en.wikipedia.org/wiki/Cristian%27s_algorithm */

import Result
import ReactiveCocoa

struct ChristiansMap {
    
    let local: NSTimeInterval
    
    let remote: NSTimeInterval
}

private struct RoundTrip {
    
    let requestStamp: NSTimeInterval
    
    var responseStamp: NSTimeInterval!
    
    var timestamp: NSTimeInterval!
    
    func latency() -> NSTimeInterval {
        
        return responseStamp - requestStamp
    }
}

class ChristiansProcess {
    
    private var endpoint: Endpoint?
    
    private var currentTrip: RoundTrip?
    
    private var trips: [RoundTrip] = []
    
    private var success: (ChristiansMap -> ())?
    
    private var failed: (() -> ())?
    
    private var cancelled: (() -> ())?
    
    private var startUnix: NSTimeInterval!

    func syncronise(endpoint: Endpoint) -> SignalProducer<(Endpoint, ChristiansMap), HandshakeError> {
        
        self.endpoint = endpoint
        endpoint.readableDelegate = self
        endpoint.writeableDelegate = self
        
        
        let sync = SignalProducer<(Endpoint, ChristiansMap), HandshakeError> { [weak self] o, d in
            
            self?.success = {
                
                o.sendNext((endpoint, $0))
                o.sendCompleted()
            }
            
            self?.failed = {
                
               self?.endpoint?.disconnect()
                o.sendFailed(.SyncFailed)
            }
            
            self?.cancelled = {
                
                o.sendFailed(.Cancelled)
            }
            
            self?.startUnix = NSDate().timeIntervalSince1970
            
            debugPrint("Christian's process started")
            self?.start()
        }
        
        return sync
                .timeoutWithError(.SyncFailed, afterInterval: 5, onScheduler: QueueScheduler(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)))
                .on(failed: {[weak self] _ in debugPrint("FAILED") ; self?.endpoint?.disconnect() })
    }
    
    func cancel() {
        
        endpoint?.disconnect()
        cancelled?()
    }
}

extension ChristiansProcess {
    
    func start() {
        
        endpoint?.readData(Serialisation.terminator)
        sendMessage(TimeProcessSyncStartMessage())
    }
}

extension ChristiansProcess: WriteableDelegate {
    
    func didWriteData() {
        
       // debugPrint("Christian's process wrote data")
        currentTrip = RoundTrip(requestStamp: NSDate().timeIntervalSince1970, responseStamp: nil, timestamp:nil)
    }
}

extension ChristiansProcess: ReadableDelegate {
    
    func didReadData(data: NSData) {
        
        switch TimeServerSyncMessageDeserializer.deserialize(data) {
            
            case .Success(let m):
                
                handleMessage(m)
            
            case .Failure(let e):
                
                failed?()
                debugPrint("Christian's process failed to deserialize data: \(e)")
        }
    
        endpoint?.readData(Serialisation.terminator)
        //debugPrint("Christian's process read data")
    }
}

extension ChristiansProcess {
    
    func handleMessage(message: TimeServerSyncMessage) {
        
        switch message.type {
            
            case .Time:
                
                debugPrint("TIME MESSAGE")
                handleTimeMessage(message as! TimeServerSyncTimeMessage)
            
            
            case .Stop:
               
                success?(calculateResult())
                debugPrint("STOP MESSAGE")
        }
    }
    
    func handleTimeMessage(message: TimeServerSyncTimeMessage) {
        
        guard var trip = currentTrip else {
            
            // TODO: End the process with error
            debugPrint("WIERD STATE")
            return
        }
        
      //  debugPrint("Made Trip")
        trip.responseStamp = NSDate().timeIntervalSince1970
        trip.timestamp = message.timestamp
        trips.append(trip)
        sendMessage(TimeProcessSyncAcknowledgeMessage())
        
    }
    
    func sendMessage(message: TimeProcessSyncMessage) {
        
        endpoint?.writeData(TimeProcessSyncMessageSerializer.serialize(message))
    }
}

extension ChristiansProcess {
    
    private func calculateResult() -> (ChristiansMap) {
        
        let sortedTrips = trips.sort() { $0.latency() < $1.latency() }
        let shortestTrip = sortedTrips.first!
        let longestTrip = sortedTrips.last!
        let remote = shortestTrip.timestamp + (shortestTrip.latency() * 0.5)
        let local = shortestTrip.responseStamp
        
        debugPrint("------------ Longest Trip ------------")
        debugPrint(" Latency: \(longestTrip.latency()) \n Master Clock: \(longestTrip.timestamp) \n Request: \(longestTrip.requestStamp) \n Response: \(longestTrip.responseStamp)")
        debugPrint("------------ Shortest Trip ------------")
        debugPrint(" Latency: \(shortestTrip.latency()) \n Master Clock: \(shortestTrip.timestamp) \n Request: \(shortestTrip.requestStamp) \n Response: \(shortestTrip.responseStamp)")
        debugPrint("---------------------------------------")
        
        return ChristiansMap(local: local, remote: remote)
    }
}

/*
extension ChristiansProcess {
    
    private func takeTrip() {
        
        endpoint?.writeData(Serialisation.terminator)
        endpoint?.readData(Serialisation.terminator)
    }
    
    private func takeTripIfNeeded() {
        
        
        guard NSDate().timeIntervalSince1970 - startUnix < NetworkConfiguration.syncTimeout else {
            
            endpoint?.disconnect()
            failed?()
            return
        }
        
        debugPrint("\(trips.count)")
        trips.count < ChristiansConstants.numberOfTrips ? takeTrip() : success?(calculateResult())
    }

    private func calculateResult() -> (ChristiansMap) {
        
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
        
        return ChristiansMap(local: local, remote: remote)
    }
    
}

extension ChristiansProcess: WriteableDelegate {
    
    func didWriteData() {
        
         debugPrint("Christian's process wrote data")
        currentTrip = RoundTrip(requestStamp: NSDate().timeIntervalSince1970, responseStamp: nil, timestamp:nil)
    }
}

extension ChristiansProcess: ReadableDelegate {
    
    func didReadData(data: NSData) {

        if let d = getTimestamp(data) {
            
            debugPrint("Christian's process read data")
            currentTrip!.responseStamp = NSDate().timeIntervalSince1970
            currentTrip!.timestamp = d
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
        
        guard let obj = NSKeyedUnarchiver.unarchiveObjectWithData(dat) else {
            
            return nil
        }
        
        guard let dic = obj as? [String : Double] else {
            
            return nil
        }
        
        let value = dic["timestamp"]
        
        return value
    }
}
*/