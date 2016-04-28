//
//  ChristiansTimeServer.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Christian's Algorithm: https://en.wikipedia.org/wiki/Cristian%27s_algorithm */

import ReactiveCocoa

class ChristiansTimeServer {
    
    static let timestamp = NSDate().timeIntervalSince1970
    
    private var socketHandlers: [ChristiansSocketHandler] = []
    
    func syncronise(address: String, endpoint: Endpoint) -> SignalProducer<(String, Endpoint), ChristiansTimeServerError> {
        
        let handler = ChristiansSocketHandler()
        socketHandlers.append(handler)
        return handler.syncronise(address, endpoint: endpoint).on(completed: { [weak self] in self?.removeHandler(address) })
    }
    
    func stop() {
        
        socketHandlers.forEach() { $0.stop() }
        socketHandlers.removeAll()
    }
    
    private func removeHandler(address: String) {
        
        socketHandlers = socketHandlers.filter() { $0.address != address }
    }
}

private class ChristiansSocketHandler {
    
    private var endpoint: Endpoint!
    
    private var address: String!
    
    private var trips = 0
    
    private var success: (() -> ())?
    
    private var cancel: (() -> ())?
    
    func syncronise(address: String, endpoint: Endpoint) -> SignalProducer<(String, Endpoint), ChristiansTimeServerError> {
        
        self.endpoint = endpoint
        self.address = address
        endpoint.readableDelegate = self
        
        let scheduler = QueueScheduler(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        
        let sync = SignalProducer<(String, Endpoint), ChristiansTimeServerError> { [weak self] o, d in
            
            self?.success = {
                
                o.sendNext((address, endpoint))
                o.sendCompleted()
            }
            
            self?.cancel = {
                
                o.sendFailed(.Cancelled(endpoint))
            }
            
            debugPrint("Christians sync start for address: \(address)")
            endpoint.readData(Serialization.terminator)
            
        }.delay(0, onScheduler: scheduler)
        
        return sync
                .timeoutWithError(.Timeout(endpoint), afterInterval: NetworkConfiguration.christiansTimeServerTimeout, onScheduler: scheduler)
                .on(completed: { debugPrint("Christians signal completed")})
                .on(failed: { e in debugPrint("Christians signal failed: \(e)")})
                .on(disposed: { debugPrint("Chritians signal disposed")})
    }
    
    func stop() {
        
        cancel?()
    }
}

extension ChristiansSocketHandler: ReadableDelegate {
    
    func didReadData(data: NSData) {
        
        switch TimeProcessSyncMessageDeserializer.deserialize(data) {
            
            case .Success(let m): handleMessage(m)
            
            case .Failure(let e): debugPrint("Failed to deserialize sync message: \(e)")
        }
        
        endpoint.readData(Serialization.terminator)
    }
}

extension ChristiansSocketHandler: WriteableDelegate {
    
    private func didWriteData() {
        
        /* NB: This delegate must only be set after sync has happened. */
        debugPrint("Successfully wrote done message")
        success?()
    }
}

extension ChristiansSocketHandler {
    
    private func handleMessage(message: TimeProcessSyncMessage) {
        
        switch message.type {
            
            case .Start:
            
                //debugPrint("Recieved Start Message")
                sendMessage(TimeServerSyncTimeMessage(timestamp: NSDate().timeIntervalSince1970))
            
            case .Acknowledge:
            
                //debugPrint("Recieved Ack Message")
                trips = trips + 1
                reply()
            
            case .Repeat:
            
                //debugPrint("Recieved Repeat Message")
                reply()
        }
    }
    
    private func reply() {
        
        if  trips == ChristiansConstants.numberOfTrips {
            
            //debugPrint("Sending stop message")
            endpoint.writeableDelegate = self
            sendMessage(TimeServerSyncStopMessage())
        }
            
        else {
            
            //debugPrint("Sending Time Message")
            sendMessage(TimeServerSyncTimeMessage(timestamp: NSDate().timeIntervalSince1970))
        }
    }
    
    private func sendMessage(message: TimeServerSyncMessage) {
        
        endpoint.writeData(TimeServerSyncMessageSerializer.serialize(message))
    }
}
