//
//  SocketAcceptor.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CocoaAsyncSocket

class SocketAcceptor {
    
    private var accepted: (String -> ())!
    
    private var lost: (String -> ())!
    
    private var sockets: [Address : AsyncSocket] = [ : ]
    
    lazy var socket: AsyncSocket = {
        
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
    func stop() {
        
        socket.disconnect()
    }
    
    static func accepting(port: UInt16, accepted: String -> (), lost: String -> ()) -> SocketAcceptor? {
        
        let acceptor = SocketAcceptor()
        acceptor.accepted = accepted
        acceptor.lost = lost
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
        
        let address = newSocket.connectedHost()
        sockets[address] = newSocket
        accepted(address)
        newSocket.readDataToData(Serialisation.terminator, withTimeout: -1, tag:0)
        print("Accepted socket: \(address)")
    }
    
    @objc func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        print("Socket did disconnect")
        let filter = sockets.filter({$0.1 == sock})
        if let pair = filter.first {
            print("removing socket: \(pair.0)")
            sockets[pair.0] = nil
            lost(pair.0)
        }
    }
    
    @objc func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        /*
         var unix: Double = NSDate().timeIntervalSince1970
         let data = NSData(bytes: &unix, length: sizeof(Double))
         let dat = data.mutableCopy()
         dat.appendData(Serialisation.terminator)
         readableDelegate.didReadData(data, address: sock.connectedHost())
         */
    }
}