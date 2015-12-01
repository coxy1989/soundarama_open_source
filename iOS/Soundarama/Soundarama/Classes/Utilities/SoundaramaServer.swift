//
//  SoundaramaServer.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

class SoundaramaServer: NSObject
{
    struct Constants
    {
        static let portTCP: UInt16 = 6565
        static let portUDP: UInt16 = 6568
    }
    
    private var serverSocket: AsyncSocket
    private var service: NSNetService?
    
    override init()
    {
        self.serverSocket = AsyncSocket()
        
        super.init()
        
        self.serverSocket.setDelegate(self)
    }
    
    func publishService()
    {
        do
        {
            try self.serverSocket.acceptOnPort(Constants.portTCP)
            
            self.service = NSNetService(domain: "local", type: "_soundarama._tcp.", name: "", port: Int32(Constants.portTCP))
            self.service?.delegate = self
            self.service?.publish()
            
            print("Accepting connections...")
        }
        catch
        {
            print("Failed to publish service")
        }
    }
}

extension SoundaramaServer: AsyncSocketDelegate
{
    func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!)
    {
        print("New performer: \(newSocket.connectedHost())")
    }
}

extension SoundaramaServer: NSNetServiceDelegate
{
    func netServiceDidPublish(sender: NSNetService)
    {
        print("Soundarama service published...")
    }
    
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber])
    {
        print("Failed to publish soundarama service...")
    }
}

