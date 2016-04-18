//
//  SocketConnector.swift
//  Soundarama
//
//  Created by Jamie Cox on 04/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import PromiseK
import Result

class SocketConnector: NSObject {
    
//    private var connected: ((String, DisconnectableEndpoint) -> ())!
    
//    private var state = false
    
   // private let name: String
    
    private var onConnected: (Endpoint -> ())!
    
    private var onDisconnected: (() -> ())!
    
    private lazy var socket: AsyncSocket = {
        
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
    /*
    private init(name: String) {
        
        self.name = name
    }
 */
    
    func connect(host: String, port: UInt16) -> Promise<Result<Endpoint, ConnectionError>> {
    
        return Promise<Result<Endpoint, ConnectionError>> { [weak self] execute in
            
            self?.onConnected = { e in
                
                let result = Result<Endpoint, ConnectionError>.Success(e)
                let promise = Promise<Result<Endpoint, ConnectionError>>(result)
                execute(promise)
            }
            
            self?.onDisconnected = {
                
                let result = Result<Endpoint, ConnectionError>.Failure(ConnectionError.ConnectFailed)
                let promise = Promise<Result<Endpoint, ConnectionError>>(result)
                execute(promise)
            }
            
            do {
                
                try self?.socket.connectToHost(host, onPort: port)
            }
            
            catch {
                
                let result = Result<Endpoint, ConnectionError>.Failure(ConnectionError.ConnectFailed)
                let promise = Promise<Result<Endpoint, ConnectionError>>(result)
                execute(promise)
            }
            
        }
    }
    
    /*
    
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
 */
}


extension SocketConnector: AsyncSocketDelegate {
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        
        debugPrint("Socket connector connected socket")
        //state = true
       // connected(name, NetworkEndpoint(socket: sock))
        onConnected(NetworkEndpoint(socket: sock))
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        debugPrint("Socket connector disconnected socket")
        onDisconnected()
    }
}
