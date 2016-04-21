//
//  Reshake.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa

class Reshake {
    
    private let resolvable: Resolvable
    
    private var handshake: Handshake?
    
    private var cancelled: (() -> ())?
    
    init(resolvable: Resolvable) {
        
        self.resolvable = resolvable
    }
    
    func producer() -> SignalProducer<(Endpoint, ChristiansMap), HandshakeError> {
        
        let scheduler = QueueScheduler(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        let hs = Handshake(resolvable: resolvable)
        handshake = hs
        
        let cancel = SignalProducer<(Endpoint, ChristiansMap), HandshakeError> { [weak self] o,_ in self?.cancelled = { o.sendFailed(.Cancelled) } }
        
        let reconnect = handshake!.producer()
            .flatMapError() { _ in timer(NetworkConfiguration.reconnectDelay, onScheduler: scheduler)
                .promoteErrors(HandshakeError)
                .flatMap(.Latest) { _ in hs.producer()}
            }
            .on(failed: {e in debugPrint("Failed reconnect attempt: \(e)")})
            .retry(NetworkConfiguration.reconnectAttempts - 1)
            .take(1)
        
        return SignalProducer(values: [reconnect, cancel]).flatten(.Merge)
    }
    
    func cancel() {
        
        cancelled?()
    }
}
