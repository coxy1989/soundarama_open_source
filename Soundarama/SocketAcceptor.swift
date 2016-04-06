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

/*
 if sock == socket {
 // Stopped handler
 print("Acceptor disconnect")
 }
 else {
 
 print("Socket disconnect")
 let endpoint = socket_endpoints[sock]!
 lost(endpoint.0, endpoint.1)
 }
 */
/*
 if sock == socket {
 
 print("Disconnected acceptor socket")
 }
 
 else {
 print("Disconnected accepted socket")
 }
 */
//print("Disconnected a socket")

/*
 guard sock != socket else {
 
 print("WE ARE DOWN")
 stopped()
 return
 }
 
 print("disconnect from socket")
 
 */

//print("Socket did disconnect")
//let filter = sockets.filter({$0.1 == sock})
//  if let pair = filter.first {
//  print("removing socket: \(pair.0)")
//   sockets[pair.0] = nil
//    lost(pair.0)
// }

/*
 var unix: Double = NSDate().timeIntervalSince1970
 let data = NSData(bytes: &unix, length: sizeof(Double))
 let dat = data.mutableCopy()
 dat.appendData(Serialisation.terminator)
 //readableDelegate.didReadData(data, address: sock.connectedHost())
 */


/*
 newSocket.readDataToData(Serialisation.terminator, withTimeout: -1, tag: 0)
 newSocket.setDelegate(self)
 
 */
//let address = newSocket.connectedHost()
// sockets[address] = newSocket
//accepted(address)
//newSocket.readDataToData(Serialisation.terminator, withTimeout: -1, tag:0)
//print("Accepted socket: \(address)")

// TODO:
/*
    - socket acceptor to calback with NetworkEndpoint disconnects and connects
    - DJInteractor needs an endpoint store
    - Endpoints need to handle christian sync and writing messages.
 */