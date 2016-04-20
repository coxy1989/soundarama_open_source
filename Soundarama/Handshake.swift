//
//  Handshake.swift
//  Soundarama
//
//  Created by Jamie Cox on 20/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa

class Handshake {
  
    private let resolvable: Resolvable
    
    private var christiansProcess: ChristiansProcess?
    
    private var socketConnector: SocketConnector?
    
    private var cancelled: (() -> ())?
    
    init(resolvable: Resolvable) {
        
        self.resolvable = resolvable
    }
    
    func producer() -> SignalProducer<(Endpoint, ChristiansMap), HandshakeError> {
        
        let christiansProcess = ChristiansProcess()
        self.christiansProcess = christiansProcess
        
        let socketConnector = SocketConnector()
        self.socketConnector = socketConnector
        
        let connect = resolvable.resolve()
            .flatMap(.Latest, transform: socketConnector.connect)
            .flatMap(.Latest, transform: christiansProcess.syncronise)
        
        let cancel = SignalProducer<(Endpoint, ChristiansMap), HandshakeError> { [weak self] o, _ in self?.cancelled = { o.sendFailed(.Cancelled) } }
        
        return SignalProducer(values: [connect, cancel]).flatten(.Merge)
    }
    
    func cancel() {
        
        resolvable.cancel()
        christiansProcess?.cancel()
        socketConnector?.cancel()
        cancelled?()
    }
}

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
            .flatMap(.Latest) { _ in hs.producer()} }
            .on(failed: {e in debugPrint("Failed reconnect attempt: \(e)")})
            .retry(NetworkConfiguration.reconnectAttempts - 1)
            .take(1)
            .on(completed: { debugPrint("Done")}, disposed: { debugPrint("Disposed") })
        
        return SignalProducer(values: [reconnect, cancel]).flatten(.Merge)
    }
    
    func cancel() {
        
        cancelled?()
    }
}
