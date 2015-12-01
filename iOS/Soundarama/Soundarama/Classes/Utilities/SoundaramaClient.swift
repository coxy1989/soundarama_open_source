//
//  SoundaramaClient.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

class SoundaramaClient: NSObject
{
    private var serviceBrowser: NSNetServiceBrowser
    private var service: NSNetService?
    
    private var clientSocket: AsyncSocket
    
    override init()
    {
        self.serviceBrowser = NSNetServiceBrowser()
        
        self.clientSocket = AsyncSocket()
        
        super.init()
        
        self.serviceBrowser.delegate = self
        self.clientSocket.setDelegate(self)
    }
    
    func connectToServer()
    {
        serviceBrowser.searchForServicesOfType("_soundarama._tcp.", inDomain: "local")
    }
    
    private func connectToHost(hostName: String, port: Int)
    {
        do
        {
            try self.clientSocket.connectToHost(hostName, onPort: UInt16(port))
            print("Connected to server!")
        }
        catch
        {
            print("Failed connecting to server...")
        }
    }
}

extension SoundaramaClient: NSNetServiceBrowserDelegate
{
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser)
    {
        print("Searching")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool)
    {
        print("Found new service. Resolving...")
        self.service = service
        self.service?.delegate = self
        self.service?.resolveWithTimeout(5)
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool)
    {
        print("Service removed")
    }
}

extension SoundaramaClient: NSNetServiceDelegate
{
    func netServiceDidResolveAddress(service: NSNetService)
    {
        print("Resolved: \(service.domain), \(service.hostName), \(service.addresses), \(service.port)")
        if let hostName = service.hostName
        {
            connectToHost(hostName, port: service.port)
        }
    }
}