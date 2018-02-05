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
    
    init(resolvable: Resolvable) {
        
        self.resolvable = resolvable
    }
    
    func producer() -> SignalProducer<(Endpoint, ChristiansMap), HandshakeError> {
        
        let christiansProcess = ChristiansProcess()
        self.christiansProcess = christiansProcess
        
        let socketConnector = SocketConnector()
        self.socketConnector = socketConnector
        
        let connect = resolvable.resolve()
            .flatMap(.Concat, transform: socketConnector.connect)
            .flatMap(.Concat, transform: christiansProcess.syncronise)
            .take(1)
        
        return connect
            .on(next: { debugPrint("Handshake signal sent next: \($0)")})
            .on(failed: { debugPrint("Handshake signal failed: \($0)")})
            .on(disposed: { debugPrint("Handshake signal disposed")})
    }
    
    func cancel() {
        
        resolvable.cancel()
        christiansProcess?.cancel()
        socketConnector?.cancel()
    }
}
