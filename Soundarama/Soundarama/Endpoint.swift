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
    weak var writeableDelegate: WriteableDelegate?
    
    static let portTCP: UInt16 = 6565
    
    static let portUDP: UInt16 = 6568
    
    lazy var socket: AsyncSocket = {
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
}

extension SocketEndpoint: Connectable {
    
    func connect() {
        
        /* Abstract */
        assert(false, "This is an abstract method")
    }
    
}

extension SocketEndpoint: Readable {
    
    func readData(terminator: NSData) {
        
        /* Abstract */
        assert(false, "This is an abstract method")
    }
    
    func readData(terminator: NSData, address: Address) {
        
        /* Abstract */
        assert(false, "This is an abstract method")
    }
}

extension SocketEndpoint: Writeable {
    
    func writeData(data: NSData) {
        
        socket.writeData(data, withTimeout: -1, tag: 0)
        writeableDelegate?.didWriteData(data)
    }
    
    func writeData(data: NSData, address: Address) { /* Abstract */ }
}

extension SocketEndpoint: AsyncSocketDelegate {

    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        readableDelegate.didReadData(data, address: sock.connectedHost())
    }
}
