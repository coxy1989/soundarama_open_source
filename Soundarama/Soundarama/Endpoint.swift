//
//  Endpoint.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CocoaAsyncSocket

class SocketEndpoint: NSObject, Endpoint {
    
    weak var connectionDelegate: ConnectableDelegate!
    weak var readableDelegate: ReadableDelegate!
    
    private static let portTCP: UInt16 = 6565
    
    private static let portUDP: UInt16 = 6568
    
    private var strategy: NSObject!
    
    private lazy var socket: AsyncSocket = {
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
    private var sockets: [Address : AsyncSocket] = [ : ]
    
    private func connectToHost(hostName: String, port: Int) {
        
        print("Connecting to host \(hostName)")
        do {
            try socket.connectToHost(hostName, onPort: UInt16(port))
        }
        catch {
            print("Failed to connect to host")
        }
    }
    
    private func search() {
        
        let s = SearchStrategy()
        s.delegate = self
        s.search()
        self.strategy = s
    }
    
    private func broadcast() {
        
        let b = BroadcastStrategy(tcpPort: Int32(SocketEndpoint.portTCP))
        self.strategy = b
        do {
            try socket.acceptOnPort(SocketEndpoint.portTCP)
            print("Accepting on port \(SocketEndpoint.portTCP)...")
            b.broadcast()
        } catch {
            print("Failed to publish service")
        }
    }
}

extension SocketEndpoint: Connectable {
    
    func connect(strategy: ConnectableStrategy) {
        
        if strategy == .Search {
            search()
        } else if strategy == .Broadcast {
            broadcast()
        }
    }
}

extension SocketEndpoint: Readable {
    
    func readData(terminator: NSData) {
        
    }
}

extension SocketEndpoint: Writeable {
    
    func writeData(data: NSData, address: Address) {
    
    }
}

extension SocketEndpoint: SearchStrategyDelegate {
    
    func searchStrategyDidFindHost(strategy: SearchStrategy, host: String, port: Int) {
            connectToHost(host, port: port)
    }
}


extension SocketEndpoint: AsyncSocketDelegate {
    
    /* Broadcast Strategy - we are accepting a socket */
    
    func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!) {
        
        let address = newSocket.connectedHost()
        sockets[address] = newSocket
        connectionDelegate.didConnectToAddress(address)
        print("Accepted socket: \(address)")
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {

        if let address = sockets.keys.filter({$0 == sock.connectedHost()}).first {
            print("removing socket: \(address)")
            sockets[address] = nil
            connectionDelegate.didDisconnectFromAddress(address)
        }
        print("Socket did disconnect")
    }
    
    /* Search Strategy - we have been accepted */
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        
        connectionDelegate.didConnectToAddress(host)
        print("Connected to host: \(host)")
    }
    
    /* Both Strategies */
    
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        readableDelegate.didReadData(data)
        print("Did read data")
    }
    
}
