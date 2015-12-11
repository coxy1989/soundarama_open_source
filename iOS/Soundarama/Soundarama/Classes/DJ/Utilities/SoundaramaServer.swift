//
//  SoundaramaServer.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

protocol SoundaramaServerDelegate: class
{
    func soundaramaServerDidConnectToPerformer(soundaramaServer: SoundaramaServer, id: String)
    func soundaramaServerDidDisconnectFromPerformer(soundaramaServer: SoundaramaServer, id: String)
}

class SoundaramaServer: NSObject
{
    struct Constants
    {
        static let portTCP: UInt16 = 6565
        static let portUDP: UInt16 = 6568
    }
    
    weak var delegate: SoundaramaServerDelegate?
    let sessionStamp: NSTimeInterval!
    
    private var serverSocket: AsyncSocket
    private var service: NSNetService?
    private var activeSockets: [AsyncSocket] = []
    
    override init()
    {
        self.serverSocket = AsyncSocket()
        sessionStamp = NSDate().timeIntervalSince1970
        
        super.init()
        
        self.serverSocket.setDelegate(self)
        
    }
    
    func publishService()
    {
        do
        {
            try self.serverSocket.acceptOnPort(Constants.portTCP)
            
            service = NSNetService(domain: "local", type: "_soundarama._tcp.", name: "", port: Int32(Constants.portTCP))
            service?.delegate = self
            service?.publish()
            
            print("Accepting on port \(Constants.portTCP)...")
        }
        catch
        {
            print("Failed to publish service")
        }
    }
    
    private var previousSocketId = 0
    func nextSocketId() -> Int
    {
        let socketId = self.previousSocketId
        self.previousSocketId++
        return socketId
    }
}

extension SoundaramaServer: AsyncSocketDelegate
{
    func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!)
    {
        print("New performer: \(newSocket.connectedHost())")
        self.activeSockets.append(newSocket)
        newSocket.setUserData(self.nextSocketId())
        self.delegate?.soundaramaServerDidConnectToPerformer(self, id: "\(newSocket.userData())")
        newSocket?.readDataToData(MessageConstants.seperator, withTimeout: -1, tag: 0)
    }
    
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int)
    {
        var unix: Double = NSDate().timeIntervalSince1970
        let data = NSData(bytes: &unix, length: sizeof(Double))
        let dat = data.mutableCopy()
        dat.appendData(MessageConstants.seperator)
        
        sock.writeData(dat as! NSData, withTimeout: -1, tag: 0)
        sock.readDataToData(MessageConstants.seperator, withTimeout: -1, tag: 0)
    }
    
//    func onSocket(sock: AsyncSocket!, didWriteDataWithTag tag: Int)
//    {
//        print("Wrote data with tag \(tag)")
//    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!)
    {
        if let socketIdx = self.activeSockets.indexOf(sock)
        {
            print("Socket disconnected")
            self.activeSockets.removeAtIndex(socketIdx)
            self.delegate?.soundaramaServerDidDisconnectFromPerformer(self, id: "\(sock.userData())")
        }
    }
}

extension SoundaramaServer: NSNetServiceDelegate
{
    
    func netServiceWillPublish(sender: NSNetService) {
        print("Net service will publish")
    }
    
    func netServiceDidPublish(sender: NSNetService)
    {
        print("Net service published...")
    }
    
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber])
    {
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

/* Experimenting */

extension SoundaramaServer
{
    func sendMessage(message: Message)
    {
        for s in activeSockets
        {
            s.writeData(message.data(), withTimeout: -1, tag: 0)
        }
    }
    
    func sendMessage(message: Message, performerID: String)
    {
        for s in activeSockets where s.userData() == Int(performerID)
        {
            s.writeData(message.data(), withTimeout: -1, tag: 0)
        }
    }
}
