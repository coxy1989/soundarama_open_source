//
//  SearchSocketEndpoint.swift
//  Soundarama
//
//  Created by Jamie Cox on 26/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CocoaAsyncSocket

class SearchSocketEndpoint: SocketEndpoint {
    
    private lazy var strategy: SearchStrategy = {
        let s = SearchStrategy()
        s.delegate = self
        return s
    }()
    
    override func connect() {
        
        strategy.search()
    }
    
    override func disconnect() {
        
        socket.disconnect()
    }
    
    override func readData(terminator: NSData) {
        
        socket.readDataToData(terminator, withTimeout: -1, tag: 1)
    }
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        
        print("Connected to host: \(host)")
        connectionDelegate.didConnectToAddress(host)
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {

        print("Socket did disconnect")
        connectionDelegate.didDisconnectFromAddress("")
    }
}

extension SearchSocketEndpoint {
    
    private func connectToHost(hostName: String, port: Int) {
        
        print("Connecting to host \(hostName)")
        do {
            try socket.connectToHost(hostName, onPort: UInt16(port))
        }
        catch {
            print("Failed to connect to host")
        }
    }
}

extension SearchSocketEndpoint: SearchStrategyDelegate {
    
    func searchStrategyDidFindHost(strategy: SearchStrategy, host: String, port: Int) {
        
        connectToHost(host, port: port)
    }
}
