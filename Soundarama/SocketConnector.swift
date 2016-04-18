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
    
    private var onConnected: (Endpoint -> ())!
    
    private var onDisconnected: (() -> ())!
    
    private lazy var socket: AsyncSocket = {
        
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
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
                
                try self?.socket.connectToHost(host, onPort: port, withTimeout: NetworkConfiguration.connectTimeout)
            }
            
            catch {
                
                let result = Result<Endpoint, ConnectionError>.Failure(ConnectionError.ConnectFailed)
                let promise = Promise<Result<Endpoint, ConnectionError>>(result)
                execute(promise)
            }
        }
    }
}


extension SocketConnector: AsyncSocketDelegate {
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        
        debugPrint("Socket connector connected socket")
        onConnected(NetworkEndpoint(socket: sock))
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        debugPrint("Socket connector disconnected socket")
        onDisconnected()
    }
}
