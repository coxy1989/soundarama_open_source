//
//  Publisher.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CocoaAsyncSocket

class Publisher: NSObject {
    
    typealias Address = String
    
    static let portTCP: UInt16 = 6565
    
    static let portUDP: UInt16 = 6568
    
    private lazy var socket: AsyncSocket = {
        let s = AsyncSocket()
        s.setDelegate(self)
        return s
    }()
    
    private lazy var service: NSNetService = {
        let s = NSNetService(domain: "local", type: "_soundarama._tcp.", name: "", port: Int32(Publisher.portTCP))
        s.delegate = self
        return s
    }()
    
    func connect() {
        
        do {
            try socket.acceptOnPort(Publisher.portTCP)
            print("Accepting on port \(Publisher.portTCP)...")
            service.publish()
        } catch {
            print("Failed to publish service")
        }
    }
    
    func publish(data: NSData) {
        /*
            for (_, s) in activeSockets
            {
                s.writeData(message.data(), withTimeout: -1, tag: 0)
            }
        */
        
    }
    
    func publish(data: NSData, address: Address) {
        /*
            print("send message to performer")
            for (address, s) in activeSockets where address == performerAddress
            {
                s.writeData(message.data(), withTimeout: -1, tag: 0)
            }
        */
        
    }
}

extension Publisher: NSNetServiceDelegate {
    
    func netServiceWillPublish(sender: NSNetService) {
        
        print("Net service will publish")
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        
        print("Net service published...")
    }
    
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        
        print("Net service failed to publish")
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        
        print("Net service did not resolve address")
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        print("Net service did not resolve \(errorDict)")
    }
    
    func netServiceDidStop(sender: NSNetService) {
        
        print("Net service did stop")
    }
    
    func netServiceWillResolve(sender: NSNetService) {
        
        print("Net service will resolve")
    }
}

extension Publisher: AsyncSocketDelegate
{
    func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!) {
        
        print("New socket: \(newSocket.connectedHost())")
    }
    
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        print("Socket Did Read Data")
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        print("Socket did disconnect")
    }
}
