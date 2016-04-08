//
//  SocketAcceptor.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CocoaAsyncSocket

class SocketAcceptor {
    
    private var accepted: ((String, DisconnectableEndpoint) -> ())!
    
    private var stopped: (() -> ())!
    
    lazy var socket: AsyncSocket = {
        
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
    func stop() {
        
        socket.disconnect()
    }
    
    static func accepting(port: UInt16, accepted: (String, DisconnectableEndpoint) -> (), stopped: () -> ()) -> SocketAcceptor? {
        
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
            print("Accepting on port \(port)...")
            return self
        }
            
        catch {
            print("Failed to accept on port \(port)...")
            return nil
        }
    }
}

extension SocketAcceptor: AsyncSocketDelegate {
    
    @objc func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!) {
        
        print("Sock: \(sock.connectedHost()) Accepted Socket: \(newSocket.connectedHost())")
        
        accepted(newSocket.connectedHost(), NetworkEndpoint(socket: newSocket))
    }
    
    @objc func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        print("Socket acceptor disconnected")
        stopped()
        
    }
}