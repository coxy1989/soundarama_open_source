//
//  SocketConnector.swift
//  Soundarama
//
//  Created by Jamie Cox on 04/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import Result
import ReactiveCocoa

class SocketConnector: NSObject {
    
    private var onConnected: (Endpoint -> ())?
    
    private var onDisconnected: (() -> ())?
    
    private var cancelled: (() -> ())?
    
    private lazy var socket: AsyncSocket = {
        
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
    func connect(host: String, port: UInt16) -> SignalProducer<Endpoint, HandshakeError> {
        
        return SignalProducer<Endpoint, HandshakeError> { [weak self ] o, d in
            
            self?.onConnected = { o.sendNext($0) }
            
            self?.onDisconnected = { o.sendFailed(.ConnectFailed) }
            
            self?.cancelled = { o.sendFailed(.Cancelled) }
            
            do {
                
                try self?.socket.connectToHost(host, onPort: port, withTimeout: NetworkConfiguration.connectTimeout)
                
            } catch {
                
                o.sendFailed(.ConnectFailed)
            }
        }
    }
    
    func cancel() {
        
        socket.disconnect()
        cancelled?()
    }
}


extension SocketConnector: AsyncSocketDelegate {
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        
        debugPrint("Socket connector connected socket")
        onConnected?(NetworkEndpoint(socket: sock))
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        debugPrint("Socket connector disconnected socket")
        onDisconnected?()
    }
}
