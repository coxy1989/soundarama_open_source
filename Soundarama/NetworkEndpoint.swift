//
//  NetworkEndpoint.swift
//  Soundarama
//
//  Created by Jamie Cox on 07/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

import CocoaAsyncSocket

class NetworkEndpoint: NSObject, Endpoint {
    
    weak var readableDelegate: ReadableDelegate?
    
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
        
        /* debugPrint("Socket wrote data") */
        writeableDelegate?.didWriteData()
    }
    
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        /* debugPrint("Socket read data") */
        readableDelegate?.didReadData(data)
    }
    
    
    func onSocket(sock: AsyncSocket!, willDisconnectWithError err: NSError!) {
        
        /* debugPrint("Socket will disconnect: \(err)") */
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        debugPrint("Socket did disconnect")
        handlers.forEach() { $0() }
    }
}
