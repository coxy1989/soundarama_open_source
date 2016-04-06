//
//  Endpoint.swift
//  Soundarama
//
//  Created by Jamie Cox on 05/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

protocol  DisconnectableEndpoint: Disconnectable, Endpoint { }

protocol Disconnectable {
    
    func disconnect()
    
    func onDisconnect(handler: () -> ())
}

protocol Endpoint: Readable, Writeable { }

typealias Address = String

protocol ReadableDelegate: class {
    
    func didReadData(data: NSData, address: Address)
}

protocol Readable: class {
    
    weak var readableDelegate: ReadableDelegate! { get set }
    
    func readData(terminator: NSData)
}

protocol WriteableDelegate: class {
    
    func didWriteData()
}

protocol Writeable: class  {
    
    weak var writeableDelegate: WriteableDelegate? { get set }
    
    func writeData(data: NSData)
}

import CocoaAsyncSocket

class NetworkEndpoint: NSObject, DisconnectableEndpoint {
    
    weak var readableDelegate: ReadableDelegate!
    
    weak var writeableDelegate: WriteableDelegate?
    
    private let socket: AsyncSocket
    
    private var handlers: [() -> ()] = []
    
    init(socket: AsyncSocket) {
        
        self.socket = socket
        super.init()
        socket.setDelegate(self)
    }
    
    func disconnect() {
        
        socket.disconnect()
    }
    
    func onDisconnect(handler: () -> ()) {
        
        handlers.append(handler)
    }
}

extension NetworkEndpoint: Readable {
    
    func readData(terminator: NSData) {
        
        socket.readDataToData(terminator, withTimeout: -1, tag: 1)
    }
}

extension NetworkEndpoint: Writeable {
    
    func writeData(data: NSData) {
        
        socket.writeData(data, withTimeout: -1, tag: 0)
    }
}

extension NetworkEndpoint: AsyncSocketDelegate {
 
    func onSocket(sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
        
        debugPrint("Socket wrote data")
        writeableDelegate?.didWriteData()
    }
    
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        debugPrint("Socket read data")
        readableDelegate.didReadData(data, address: sock.connectedHost())
    }
    
    
    func onSocket(sock: AsyncSocket!, willDisconnectWithError err: NSError!) {
        
        debugPrint("Socket will disconnect: \(err)")
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        debugPrint("Socket did disconnect")
        handlers.forEach() { $0() }
    }
}

