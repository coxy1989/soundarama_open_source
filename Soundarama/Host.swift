//
//  Host.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class Host {
 
    private let hostSocket: AsyncSocket
    
    private var clientSockets: [Address : AsyncSocket] = [ : ]
    
    private init(hostSocket: AsyncSocket) {
        
        self.hostSocket = hostSocket
    }
    
    static func aceptingOnPort(port: UInt16) -> Host? {
        
        let s = AsyncSocket()
        s.setDelegate(self)
        do {
            try s.acceptOnPort(port)
            print("Accepting on port \(port)...")
            return Host(hostSocket: s)
            
        } catch {
            print("Failed to publish service")
            return nil
        }
    }
    
    func disconnect() {
        
        hostSocket.disconnect()
        for s in clientSockets.values {
            s.disconnect()
        }
    }

    func writeData(data: NSData, address: Address) {
        
        if let pair = clientSockets.filter({$0.0 == address}).first {
            pair.1.writeData(data, withTimeout: -1, tag: 0)
        }
        else {
            print("No socket for writing: \(address)")
        }
    }
    
    func readData(terminator: NSData, address: Address) {
        
        if let socket = clientSockets[address] {
            socket.readDataToData(terminator, withTimeout: -1, tag: 0)
        } else {
            print("No socket for reading: \(address)")
        }
    }
}

extension Host: AsyncSocketDelegate {
    
    @objc func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!) {
        
        let address = newSocket.connectedHost()
        clientSockets[address] = newSocket
        //connectionDelegate.didConnectToAddress(address)
        //newSocket.readDataToData(Serialisation.terminator, withTimeout: -1, tag:0)
        print("Accepted socket: \(address)")
    }
    
    @objc func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        print("Socket did disconnect")
        let filter = clientSockets.filter({$0.1 == sock})
        if let pair = filter.first {
            print("removing socket: \(pair.0)")
            clientSockets[pair.0] = nil
            //connectionDelegate.didDisconnectFromAddress(pair.0)
        }
    }
    
    @objc func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        var unix: Double = NSDate().timeIntervalSince1970
        let data = NSData(bytes: &unix, length: sizeof(Double))
        let dat = data.mutableCopy()
        dat.appendData(Serialisation.terminator)
        //readableDelegate.didReadData(data, address: sock.connectedHost())
    }
}
