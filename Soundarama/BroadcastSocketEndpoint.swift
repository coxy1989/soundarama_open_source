//
//  BroadcastSocketEndpoint.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CocoaAsyncSocket

class BroadcastSocketEndpoint: SocketEndpoint {
    
    private var sockets: [Address : AsyncSocket] = [ : ]
    
    let strategy = BroadcastStrategy(tcpPort: Int32(SocketEndpoint.portTCP))
    
    override func connect() {
        
        do {
            try socket.acceptOnPort(SocketEndpoint.portTCP)
            print("Accepting on port \(SocketEndpoint.portTCP)...")
            strategy.broadcast()
        } catch {
            print("Failed to publish service")
        }
    }
    
    override func disconnect() {
        
        socket.disconnect()
        for s in sockets.values {
            s.disconnect()
        }
    }
    
    override func writeData(data: NSData, address: Address) {
        
        if let pair = sockets.filter({$0.0 == address}).first {
            pair.1.writeData(data, withTimeout: -1, tag: 0)
        }
        else {
            print("No socket for writing: \(address)")
        }
    }
    
    override func readData(terminator: NSData, address: Address) {
        
        if let socket = sockets[address] {
            socket.readDataToData(Serialisation.terminator, withTimeout: -1, tag: 0)
        } else {
            print("No socket for reading: \(address)")
        }
        
    }
}

extension BroadcastSocketEndpoint  {
    
    /* AsyncSocketDelegate from super */
    
    func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!) {
        
        let address = newSocket.connectedHost()
        sockets[address] = newSocket
        connectionDelegate.didConnectToAddress(address)
        newSocket.readDataToData(Serialisation.terminator, withTimeout: -1, tag:0)
        print("Accepted socket: \(address)")
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {

        print("Socket did disconnect")
        let filter = sockets.filter({$0.1 == sock})
        if let pair = filter.first {
            print("removing socket: \(pair.0)")
            sockets[pair.0] = nil
            connectionDelegate.didDisconnectFromAddress(pair.0)
        }
    }
    
    override func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        var unix: Double = NSDate().timeIntervalSince1970
        let data = NSData(bytes: &unix, length: sizeof(Double))
        let dat = data.mutableCopy()
        dat.appendData(Serialisation.terminator)
        readableDelegate.didReadData(data, address: sock.connectedHost())
    }
}
