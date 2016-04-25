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
                
                o.sendFailed(.SyncFailed(endpoint))
            }
            
            self?.cancelled = {
                
                o.sendFailed(.SyncCancelled(endpoint))
            }
            
            self?.start()
        }
        
        return sync
                .timeoutWithError(.SyncFailed(endpoint), afterInterval: NetworkConfiguration.christiansProcessTimeout, onScheduler: QueueScheduler(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)))
                .on(failed: { debugPrint("Christians process failed: \($0)") })
                .on(disposed: { debugPrint("Christians signal disposed")})
    }
    
    func cancel() {
    
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
        
        currentTrip = RoundTrip(requestStamp: NSDate().timeIntervalSince1970, responseStamp: nil, timestamp:nil)
    }
}

extension ChristiansProcess: ReadableDelegate {
    
    func didReadData(data: NSData) {
        
        switch TimeServerSyncMessageDeserializer.deserialize(data) {
            
            case .Success(let m):
                
                handleMessage(m)
            
            case .Failure(let e):
                
                debugPrint("Christian's process failed to deserialize data: \(e)")
                sendMessage(TimeProcessSyncRepeatMessage())
        }
    
        endpoint?.readData(Serialisation.terminator)
    }
}

extension ChristiansProcess {
    
    func handleMessage(message: TimeServerSyncMessage) {
        
        switch message.type {
            
            case .Time: handleTimeMessage(message as! TimeServerSyncTimeMessage)
            
            case .Stop: success?(calculateResult())
        }
    }
    
    func handleTimeMessage(message: TimeServerSyncTimeMessage) {
        
        guard var trip = currentTrip else {
            
            /* This is a logical error */
            failed?()
            return
        }
        
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

