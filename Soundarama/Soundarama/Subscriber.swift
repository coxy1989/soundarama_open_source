//
//  Subscriber.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CocoaAsyncSocket

protocol SubscriberDelegate {
    
    func didRecieveData(data: NSData)
}

class Subscriber: NSObject {
    
    var delegate: SubscriberDelegate!
    
    private lazy var serviceBrowser: NSNetServiceBrowser = {
        let b = NSNetServiceBrowser()
        b.delegate = self
        return b
    }()
    
    private var service: NSNetService?
    
    private var socket: AsyncSocket?
    
    func subscribe() {
        
        serviceBrowser.searchForServicesOfType("_soundarama._tcp.", inDomain: "local")
    }
    
    private func connectToHost(hostName: String, port: Int) {
        
        print("Connecting to host")
        socket = AsyncSocket()
        socket!.setDelegate(self)
        do {
            try socket!.connectToHost(hostName, onPort: UInt16(port))
            print("Connected to host")
        }
        catch {
            print("Failed to connect to host")
        }
    }
}

extension Subscriber: NSNetServiceBrowserDelegate {
    
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        
        print("Browser will search")
    }
    
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        
        print("Browser stopped searching")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        
        print("Browser did find domian \(domainString)")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        
        print("Browser did not search")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        
        print("Browser did remove domain")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        
        print("Browser found service")
        self.service = service
        self.service?.delegate = self
        self.service?.resolveWithTimeout(5)
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        
        print("Browser removed service")
        /* keep retrying if we lose the service */
        subscribe()
    }
}

extension Subscriber: NSNetServiceDelegate {
    
    func netServiceDidResolveAddress(service: NSNetService) {
        
        print("Resolved host: \(service.domain), \(service.hostName), \(service.addresses), \(service.port)")
        if let hostName = service.hostName {
            connectToHost(hostName, port: service.port)
        }
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        print("Failed to resolve service")
        /* keep retrying if we encounter a failure */
        service?.resolveWithTimeout(5)
    }
}

extension Subscriber: AsyncSocketDelegate {
    
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        print("received message")
        delegate.didRecieveData(data)
    }
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        
        print("connected to host: \(host)")
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        
        print("disconnected from host, retrying..")
    }
    
    func onSocket(sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
        
        print("Wrote data with tag \(tag)")
    }
}
