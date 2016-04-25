//
//  SocketAcceptor.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CocoaAsyncSocket
import ReactiveCocoa

class SocketAcceptor {
    
    private var accepted: ((String, Endpoint) -> ())?
    
    private var stopped: (() -> ())?
    
    private var disconnected: (() -> ())?
    
    lazy var socket: AsyncSocket = {
        
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
    func stop() {
        
        stopped?()
        socket.disconnect()
    }
    
    func accept(port: UInt16) -> SignalProducer<(String, Endpoint), SocketAcceptorError> {
        
        return SignalProducer<(String, Endpoint), SocketAcceptorError> { [weak self] o, d in
            
            self?.accepted = {
                
                o.sendNext($0)
            }
            
            self?.stopped = {
                
                o.sendCompleted()
            }
            
            self?.disconnected = {
                
                o.sendFailed(.Disconnected)
            }
            
            do {
                
                try self?.socket.acceptOnPort(port)
                debugPrint("Accepting on port: \(port)")
            }
                
            catch {
                
                debugPrint("Failed to accept on port: \(port)")
                o.sendFailed(.Failed)
            }
        }
    }
    
    static func accepting(port: UInt16, accepted: (String, Endpoint) -> (), stopped: () -> ()) -> SocketAcceptor? {
        
        let acceptor = SocketAcceptor()
        acceptor.accepted = accepted
        acceptor.stopped = stopped
        return acceptor.start(port) ?? nil
    }
}

extension SocketAcceptor {
    
    private func start(port: UInt16) -> SocketAcceptor? {
        
        do {
            try socket.acceptOnPort(port)
            debugPrint("Accepting on port \(port)...")
            return self
        }
            
        catch {
            debugPrint("Failed to accept on port \(port)...")
            return nil
        }
    }
}

extension SocketAcceptor: AsyncSocketDelegate {
    
    @objc func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!) {
        
        debugPrint("Accepted socket: \(newSocket.connectedHost())")
        
        accepted?(newSocket.connectedHost(), NetworkEndpoint(socket: newSocket))
    }
    
    @objc func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        debugPrint("Socket acceptor disconnected")
        disconnected?()
    }
}
