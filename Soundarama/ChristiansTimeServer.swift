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
    
    func syncronise(address: String, endpoint: Endpoint) -> SignalProducer<(String, Endpoint), ReceptiveHandshakeError> {
        
        let handler = ChristiansSocketHandler()
        socketHandlers.append(handler)
        return handler.syncronise(address, endpoint: endpoint)
    }
}

private class ChristiansSocketHandler {
    
    private var endpoint: Endpoint!
    
    private var address: String!
    
    private var trips = 0
    
    private var success: (() -> ())?
    
    func syncronise(address: String, endpoint: Endpoint) -> SignalProducer<(String, Endpoint), ReceptiveHandshakeError> {
        
        self.endpoint = endpoint
        self.address = address
        endpoint.readableDelegate = self
        
        let sync = SignalProducer<(String, Endpoint), ReceptiveHandshakeError> { [weak self] o, d in
            
            self?.success = {
                
                o.sendNext((address, endpoint))
                o.sendCompleted()
            }
            
            endpoint.readData(Serialisation.terminator)
        }
            
        return sync
                .timeoutWithError(.SyncTimeout, afterInterval: 5, onScheduler: QueueScheduler(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)))
                .on(failed: {[weak self] _ in debugPrint("FAILED") ; self?.endpoint.disconnect() })
    }
}

extension ChristiansSocketHandler: ReadableDelegate {
    
    func didReadData(data: NSData) {
        
        switch TimeProcessSyncMessageDeserializer.deserialize(data) {
            
            case .Success(let m): handleMessage(m)
            
            case .Failure(let e): debugPrint("Failed to deserialize sync message: \(e)")
        }
        
        endpoint.readData(Serialisation.terminator)
    }
}

extension ChristiansSocketHandler {
    
    private func handleMessage(message: TimeProcessSyncMessage) {
        
        switch message.type {
            
            case .Start:
            
                debugPrint("Recieved Start Message")
                sendMessage(TimeServerSyncTimeMessage(timestamp: NSDate().timeIntervalSince1970))
            
            case .Acknowledge:
            
                debugPrint("Recieved Ack Message")
                trips = trips + 1
                
                if  trips == ChristiansConstants.numberOfTrips {
                    
                    debugPrint("Sending done message")
                    sendMessage(TimeServerSyncStopMessage())
                }
                    
                else {
                    
                    debugPrint("Sending Time Message")
                    sendMessage(TimeServerSyncTimeMessage(timestamp: NSDate().timeIntervalSince1970))
                    success?()
                }
        }
    }
    
    private func sendMessage(message: TimeServerSyncMessage) {
        
        endpoint.writeData(TimeServerSyncMessageSerializer.serialize(message))
    }
}
