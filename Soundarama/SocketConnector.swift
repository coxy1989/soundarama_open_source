//
//  SocketConnector.swift
//  Soundarama
//
//  Created by Jamie Cox on 04/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

import CocoaAsyncSocket

class SocketConnector: NSObject {
    
    private var connected: ((String, DisconnectableEndpoint) -> ())!
    
    private var state = false
    
    private let name: String
    
    private lazy var socket: AsyncSocket = {
        
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
    private init(name: String) {
        
        self.name = name
    }
    
    static func connect(name: String, host: String, port: UInt16, connected: (String, DisconnectableEndpoint) -> ()) -> SocketConnector? {
        
        let connector = SocketConnector(name: name)
        connector.connected = connected
    
        do {
            
            try connector.socket.connectToHost(host, onPort: port)
            
        } catch {
            
            return nil
        }
        
        return connector
    }
    
    func isConnected() -> Bool {
        
        return state
    }
}


extension SocketConnector: AsyncSocketDelegate {
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        
        debugPrint("Socket connector connected socket")
        state = true
        connected(name, NetworkEndpoint(socket: sock))
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        debugPrint("Socket connector disconnected socket")
    }
}
